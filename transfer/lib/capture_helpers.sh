#!/usr/bin/env bash

# --- Capture Filesystem ---
capture_filesystem() {
    local container_name="$1"
    local fs_overlay_dir="$2"
    local fs_root="$fs_overlay_dir/fs" # Root for the captured overlay

    echo "Capturing filesystem overlay from container '$container_name' to '$fs_root'..."
    mkdir -p "$fs_root"

    if [ ${#CAPTURE_DIRS[@]} -eq 0 ]; then
        echo "  No capture directories specified in config.sh."
        return
    fi

    for dir_path in "${CAPTURE_DIRS[@]}"; do
        # Ensure target directory exists on host
        local target_host_path="$fs_root$dir_path"
        # Create parent directories if they don't exist
        mkdir -p "$(dirname "$target_host_path")"

        echo "Attempting to capture: $dir_path"
        # Use docker cp, ignore errors if source path doesn't exist in container
        # Copy the contents of the directory (.) to avoid creating the last dir component itself
        if docker cp "$container_name:$dir_path/." "$target_host_path/" >/dev/null 2>&1; then
             echo "  Successfully captured contents of $dir_path"
        else
             # Check if the directory exists at all in the container
             if docker exec "$container_name" test -d "$dir_path"; then
                 echo "  Warning: Captured $dir_path, but it might be empty or had copy errors."
             else
                 echo "  Info: Source path $dir_path not found in container, skipping."
             fi
        fi
    done
    echo "Filesystem capture finished."
}

# --- Capture Caches ---
capture_caches() {
    local container_name="$1"

    echo "Capturing package caches from container '$container_name'..."

    # APT Cache
    echo "Capturing APT cache..."
    # Ensure target exists
    mkdir -p "$APT_CACHE_DIR"
    # Copy contents of archives, ignore errors if empty
    if docker cp "$container_name:/var/cache/apt/archives/." "$APT_CACHE_DIR/" >/dev/null 2>&1; then
        echo "  APT cache files copied."
    else
        echo "  Info: APT cache in container might be empty or inaccessible."
    fi
    # Create the Packages.gz index for the local repo
    echo "Generating APT Packages index..."
    if [ -d "$OFFLINE_CACHE_BASE_DIR/apt_cache" ] && [ "$(ls -A "$APT_CACHE_DIR" 2>/dev/null)" ]; then
         (cd "$OFFLINE_CACHE_BASE_DIR/apt_cache" && dpkg-scanpackages archives /dev/null | gzip -9c > Packages.gz) || echo "  Warning: Failed to generate Packages.gz for APT cache."
         echo "  APT index generated."
    else
        echo "  Info: APT cache directory empty, skipping index generation."
    fi


    # Pip Cache (already mounted as volume, but ensure content exists)
    echo "Verifying Pip cache..."
    if [ ! "$(ls -A "$PIP_CACHE_DIR" 2>/dev/null)" ]; then
        echo "  Warning: Pip cache directory '$PIP_CACHE_DIR' appears empty."
    else
        echo "  Pip cache found at '$PIP_CACHE_DIR'."
    fi

    # Gem Cache (already mounted as volume)
    echo "Verifying Gem cache..."
     if [ ! "$(ls -A "$GEM_CACHE_DIR" 2>/dev/null)" ]; then
        echo "  Warning: Gem cache directory '$GEM_CACHE_DIR' appears empty."
    else
        echo "  Gem cache found at '$GEM_CACHE_DIR'."
    fi

    # NPM Cache (already mounted as volume)
    echo "Verifying NPM cache..."
     if [ ! "$(ls -A "$NPM_CACHE_DIR" 2>/dev/null)" ]; then
        echo "  Warning: NPM cache directory '$NPM_CACHE_DIR' appears empty."
    else
         echo "  NPM cache found at '$NPM_CACHE_DIR'."
    fi

    # Go Binaries (already mounted as volume)
    echo "Verifying Go binaries cache..."
     if [ ! "$(ls -A "$GO_BIN_CACHE_DIR" 2>/dev/null)" ]; then
        echo "  Warning: Go binaries cache directory '$GO_BIN_CACHE_DIR' appears empty."
    else
        echo "  Go binaries cache found at '$GO_BIN_CACHE_DIR'."
    fi

    # Cargo Binaries (already mounted as volume)
    echo "Verifying Cargo binaries cache..."
     if [ ! "$(ls -A "$CARGO_BIN_CACHE_DIR" 2>/dev/null)" ]; then
        echo "  Warning: Cargo binaries cache directory '$CARGO_BIN_CACHE_DIR' appears empty."
    else
        echo "  Cargo binaries cache found at '$CARGO_BIN_CACHE_DIR'."
    fi

    echo "Cache capture finished."
}


# --- Download Direct Artifacts ---
download_direct_artifacts() {
    echo "Downloading directly specified artifacts..."
    if [ ${#DIRECT_DOWNLOADS[@]} -eq 0 ]; then
        echo "  No direct downloads specified."
        return
    fi

    for item in "${DIRECT_DOWNLOADS[@]}"; do
        IFS='|' read -r url filename dest_subdir <<< "$item"
        local output_dir
        if [[ "$dest_subdir" == "bin" ]]; then
            output_dir="$BIN_CACHE_DIR"
            mkdir -p "$output_dir"
        else
            output_dir="$ARTIFACTS_CACHE_DIR"
            mkdir -p "$output_dir"
        fi
        local output_path="$output_dir/$filename"

        echo "  Downloading: $url -> $output_path"
        if curl -sSL --fail -o "$output_path" "$url"; then
            echo "    Success."
            # Make binaries executable
            if [[ "$dest_subdir" == "bin" ]]; then
                chmod +x "$output_path"
            fi
        else
            echo "    Error: Failed to download $url" >&2
            # Decide if this should be fatal
            # exit 1
        fi
    done
    echo "Direct artifact download finished."
}

# --- Download Snap Files ---
download_snap_files() {
    echo "Downloading specified Snap packages..."
    if ! command -v snap &> /dev/null; then
        echo "  Error: 'snap' command not found. Skipping snap downloads." >&2
        return 1
    fi

    if [ ${#SNAP_PACKAGES[@]} -eq 0 ]; then
        echo "  No Snap packages specified in config.sh."
        return
    fi

    mkdir -p "$SNAP_CACHE_DIR"
    local current_dir=$(pwd)
    cd "$SNAP_CACHE_DIR" || { echo "  Error: Could not change directory to $SNAP_CACHE_DIR" >&2; return 1; }

    local download_failed=0
    for package in "${SNAP_PACKAGES[@]}"; do
        # Remove --classic or other flags for download command if present
        local package_name=${package%% *}
        echo "  Attempting to download: $package_name"
        # snap download downloads to the current directory
        if snap download "$package_name"; then
            echo "    Success: Downloaded $package_name (.snap and .assert)"
        else
            echo "    Error: Failed to download snap package '$package_name'" >&2
            download_failed=1
        fi
    done

    cd "$current_dir" # Return to original directory
    if [ $download_failed -ne 0 ]; then
        echo "  Warning: One or more snap downloads failed."
        # Decide if this should be fatal
        # return 1
    fi
    echo "Snap file download finished."
    return 0
}

# --- Clone ASDF Plugins ---
clone_asdf_plugins() {
    echo "Cloning ASDF plugin repositories..."
     if [ ${#ASDF_PLUGINS[@]} -eq 0 ]; then
        echo "  No ASDF plugins specified."
        return
    fi

    mkdir -p "$ASDF_PLUGINS_CACHE_DIR"

    for item in "${ASDF_PLUGINS[@]}"; do
        IFS='|' read -r plugin_name repo_url <<< "$item"
        local target_dir="$ASDF_PLUGINS_CACHE_DIR/$plugin_name"

        if [ -d "$target_dir" ]; then
            echo "  Plugin '$plugin_name' already cloned, skipping."
            continue
        fi

        echo "  Cloning: $repo_url -> $target_dir"
        if git clone --depth 1 "$repo_url" "$target_dir"; then
             echo "    Success."
        else
             echo "    Error: Failed to clone $repo_url" >&2
             # Decide if this should be fatal
             # exit 1
        fi
    done
     echo "ASDF plugin cloning finished."
}