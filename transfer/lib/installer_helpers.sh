#!/usr/bin/env bash

generate_offline_installer() {
    local output_path="$1"
    # Make config arrays available
    local apt_packages_str="${APT_PACKAGES[*]}"
    local pip_packages_str="${PIP_PACKAGES[*]}"
    local gem_packages_str="${GEM_PACKAGES[*]}"
    local npm_packages_str="${NPM_PACKAGES[*]}"
    local snap_packages_str="${SNAP_PACKAGES[*]}"
    # Go/Cargo packages are installed via binaries copied from cache

    cat << EOF > "$output_path"
#!/usr/bin/env bash

set -e # Exit on error

echo "--- Starting Offline Installation ---"

# --- Configuration ---
OFFLINE_CACHE_ROOT="\$(dirname -- "\$(readlink -f -- "\$0")")/.." # Cache root relative to script
APT_CACHE_DIR="\$OFFLINE_CACHE_ROOT/apt_cache" # Contains Packages.gz and archives/
PIP_CACHE_DIR="\$OFFLINE_CACHE_ROOT/pip_cache"
GEM_CACHE_DIR="\$OFFLINE_CACHE_ROOT/gem_cache"
SNAP_CACHE_DIR="\$OFFLINE_CACHE_ROOT/snap_files"
NPM_CACHE_DIR="\$OFFLINE_CACHE_ROOT/npm_cache" # Note: Offline NPM is complex
GO_BIN_CACHE_DIR="\$OFFLINE_CACHE_ROOT/go_bin"
CARGO_BIN_CACHE_DIR="\$OFFLINE_CACHE_ROOT/cargo_bin"
ASDF_PLUGINS_CACHE_DIR="\$OFFLINE_CACHE_ROOT/asdf_plugins"
ARTIFACTS_CACHE_DIR="\$OFFLINE_CACHE_ROOT/artifacts"
BIN_CACHE_DIR="\$OFFLINE_CACHE_ROOT/bin"
FS_OVERLAY_DIR="\$OFFLINE_CACHE_ROOT/fs_overlay/fs" # Contains captured FS structure
DOTFILES_REPO_DIR="\$OFFLINE_CACHE_ROOT/dotfiles_repo"

# Target user details (should match config.sh used for capture)
TARGET_USER="${TARGET_USER}"
TARGET_UID="${TARGET_UID}"
TARGET_GID="${TARGET_GID}"
TARGET_USER_HOME="${TARGET_USER_HOME}"

# --- Helper Functions ---
ensure_dir() {
    if [ ! -d "\$1" ]; then
        echo "Creating directory: \$1"
        # Create directory with sudo, then attempt to chown
        sudo mkdir -p "\$1"
        sudo chown ${TARGET_UID}:${TARGET_GID} "\$1" || echo "Warning: Could not chown \$1 to ${TARGET_USER}"
    fi
}

# --- Installation Steps ---

# 1. Configure APT for Offline Cache
echo "--- Configuring Local APT Repository ---"
if [ -f "\$APT_CACHE_DIR/Packages.gz" ] && [ -d "\$APT_CACHE_DIR/archives" ]; then
    # Use file:// protocol for local directory repo
    echo "deb [trusted=yes] file://\$APT_CACHE_DIR ./" | sudo tee /etc/apt/sources.list.d/offline-cache.list
    sudo apt-get update -qq
else
    echo "Warning: Local APT cache index ('\$APT_CACHE_DIR/Packages.gz') or archives directory ('\$APT_CACHE_DIR/archives') not found. APT installs might fail."
fi

# 2. Install APT Packages
echo "--- Installing APT Packages ---"
if [ -n "$apt_packages_str" ]; then
    # Use options to prefer local cache and handle potential conflicts
    # Ensure the cache directory itself is specified correctly for apt to find debs
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
        --allow-downgrades --allow-remove-essential --allow-change-held-packages \
        -o Dir::Cache::archives="\$APT_CACHE_DIR/archives" \
        -o Debug::pkgAcquire=true \
        $apt_packages_str || echo "Warning: Some APT packages failed to install. Check /var/log/apt/term.log"
else
    echo "No APT packages specified in config."
fi

# 3. Overlay Captured Filesystem
echo "--- Overlaying Captured Filesystem ---"
if [ -d "\$FS_OVERLAY_DIR" ] && [ "\$(ls -A \$FS_OVERLAY_DIR)" ]; then
    echo "Using rsync to merge captured files into /"
    # Use -a (archive), -v (verbose for debugging), --chown if needed and possible
    # Exclude home directory initially, handle separately
    # Ensure trailing slash on source to copy contents
    sudo rsync -av --exclude='/home' "\$FS_OVERLAY_DIR/" / || echo "Warning: rsync overlay failed for root paths."

    # Handle home directory separately to ensure ownership
    if [ -d "\$FS_OVERLAY_DIR/home/$TARGET_USER" ]; then
        echo "Merging captured home directory for $TARGET_USER..."
        ensure_dir "$TARGET_USER_HOME"
        # Copy contents into target home, preserving relative paths
        # Ensure trailing slash on source
        sudo rsync -av "\$FS_OVERLAY_DIR/home/$TARGET_USER/" "$TARGET_USER_HOME/" || echo "Warning: rsync overlay failed for home directory."
        # Ensure ownership of the merged home directory contents
        echo "Setting ownership for $TARGET_USER_HOME..."
        sudo chown -R ${TARGET_UID}:${TARGET_GID} "$TARGET_USER_HOME" || echo "Warning: Failed to chown home directory."
    fi
else
    echo "Warning: Captured filesystem overlay directory ('\$FS_OVERLAY_DIR') is empty or missing."
fi

# 4. Install Pip Packages
echo "--- Installing Pip Packages ---"
if [ -n "$pip_packages_str" ] && [ -d "\$PIP_CACHE_DIR" ] && [ "\$(ls -A \$PIP_CACHE_DIR)" ]; then
    echo "Installing: $pip_packages_str"
    # Use sudo if installing system-wide, adjust if user install is intended
    sudo pip3 install --no-index --find-links="file://\$PIP_CACHE_DIR" $pip_packages_str || echo "Warning: Some Pip packages failed to install."
else
    echo "Pip cache ('\$PIP_CACHE_DIR') empty or no Pip packages specified."
fi

# 5. Install Gem Packages
echo "--- Installing Gem Packages ---"
if [ -n "$gem_packages_str" ] && [ -d "\$GEM_CACHE_DIR" ] && [ "\$(ls -A \$GEM_CACHE_DIR)" ]; then
    echo "Installing gems from \$GEM_CACHE_DIR"
    # Install all .gem files found in the cache
    # Use sudo if installing system-wide
    sudo gem install --local --no-document "\$GEM_CACHE_DIR"/*.gem || echo "Warning: Some Gem packages failed to install."
else
    echo "Gem cache ('\$GEM_CACHE_DIR') empty or no Gem packages specified."
fi

# 6. Install NPM Packages (Best Effort Offline)
echo "--- Installing NPM Packages (Best Effort) ---"
if [ -n "$npm_packages_str" ]; then
    echo "Attempting to install global NPM packages: $npm_packages_str"
    # This is tricky. The cache might not be sufficient.
    # Relying on the filesystem overlay might be more robust if /usr/local/lib/node_modules was captured.
    # If FS overlay worked, the packages might already be 'installed'.
    echo "Note: Verifying NPM packages relies heavily on the captured filesystem overlay (/usr/local/lib/node_modules or similar)."
    echo "If packages are missing, manual installation using 'npm install -g <package>' might be needed if network allows, or use 'npm pack' during capture."
else
    echo "No NPM packages specified."
fi


# 7. Install Go Binaries from Cache
echo "--- Installing Go Binaries ---"
if [ -d "\$GO_BIN_CACHE_DIR" ] && [ "\$(ls -A \$GO_BIN_CACHE_DIR)" ]; then
    echo "Copying Go binaries to /usr/local/bin..."
    sudo cp -v "\$GO_BIN_CACHE_DIR"/* /usr/local/bin/ || echo "Warning: Failed to copy some Go binaries."
    # Ensure executable permissions
    sudo chmod -v +x /usr/local/bin/* || true
else
    echo "Go binary cache ('\$GO_BIN_CACHE_DIR') empty or missing."
fi

# 8. Install Cargo Binaries from Cache
echo "--- Installing Cargo Binaries ---"
if [ -d "\$CARGO_BIN_CACHE_DIR" ] && [ "\$(ls -A \$CARGO_BIN_CACHE_DIR)" ]; then
    echo "Copying Cargo binaries to $TARGET_USER_HOME/.cargo/bin..."
    ensure_dir "$TARGET_USER_HOME/.cargo/bin"
    # Copy as target user
    sudo -u $TARGET_USER cp -v "\$CARGO_BIN_CACHE_DIR"/* "$TARGET_USER_HOME/.cargo/bin/" || echo "Warning: Failed to copy some Cargo binaries."
    # Ensure executable permissions
    sudo -u $TARGET_USER chmod -v +x "$TARGET_USER_HOME/.cargo/bin/"* || true
    echo "Make sure $TARGET_USER_HOME/.cargo/bin is in the PATH (usually handled by .profile/.bashrc)."
else
    echo "Cargo binary cache ('\$CARGO_BIN_CACHE_DIR') empty or missing."
fi

# 9. Install Direct Binaries from Cache
echo "--- Installing Direct Binaries ---"
if [ -d "\$BIN_CACHE_DIR" ] && [ "\$(ls -A \$BIN_CACHE_DIR)" ]; then
    echo "Copying direct binaries to /usr/local/bin..."
    sudo cp -v "\$BIN_CACHE_DIR"/* /usr/local/bin/ || echo "Warning: Failed to copy some direct binaries."
    # Ensure executable permissions (already done during capture, but double-check)
    sudo chmod -v +x /usr/local/bin/* || true
else
    echo "Direct binary cache ('\$BIN_CACHE_DIR') empty or missing."
fi

# 10. Install Direct Artifacts from Cache
echo "--- Installing Direct Artifacts ---"
if [ -d "\$ARTIFACTS_CACHE_DIR" ] && [ "\$(ls -A \$ARTIFACTS_CACHE_DIR)" ]; then
    echo "Processing artifacts..."
    # Add specific logic based on expected artifacts in config.sh
    if [ -f "\$ARTIFACTS_CACHE_DIR/elvish.tar.gz" ]; then
        echo "Installing Elvish from artifact..."
        # Extract directly into /usr/local, stripping the top-level dir from the tarball
        sudo tar -xzf "\$ARTIFACTS_CACHE_DIR/elvish.tar.gz" -C /usr/local --strip-components=1 || echo "Warning: Failed to install Elvish artifact."
        # Ensure elvish binary exists and is executable
         if [ -f "/usr/local/bin/elvish" ]; then sudo chmod +x /usr/local/bin/elvish; fi
    fi
    if [ -f "\$ARTIFACTS_CACHE_DIR/navi.tar.gz" ]; then
        echo "Installing Navi from artifact..."
        # Navi might need specific extraction path, e.g., /opt or /usr/local
        ensure_dir "/opt/navi"
        sudo tar -xzf "\$ARTIFACTS_CACHE_DIR/navi.tar.gz" -C /opt/navi || echo "Warning: Failed to extract Navi artifact."
        # Link navi binary to /usr/local/bin
        if [ -f "/opt/navi/navi" ]; then
             sudo ln -sf /opt/navi/navi /usr/local/bin/navi
             sudo chmod +x /usr/local/bin/navi
        fi
    fi
    # Add logic for other artifacts defined in DIRECT_DOWNLOADS
else
    echo "Artifacts cache ('\$ARTIFACTS_CACHE_DIR') empty or missing."
fi

# 11. Setup ASDF
echo "--- Setting up ASDF ---"
# Check if ASDF binary was installed (either via Go cache or FS overlay)
if command -v asdf &>/dev/null; then
    echo "ASDF binary found."
    # Link plugins from cache
    if [ -d "\$ASDF_PLUGINS_CACHE_DIR" ] && [ "\$(ls -A \$ASDF_PLUGINS_CACHE_DIR)" ]; then
        echo "Linking ASDF plugins..."
        ensure_dir "$TARGET_USER_HOME/.asdf/plugins"
        for plugin_dir in "\$ASDF_PLUGINS_CACHE_DIR"/*; do
            if [ -d "\$plugin_dir" ]; then
                plugin_name=\$(basename "\$plugin_dir")
                target_link="$TARGET_USER_HOME/.asdf/plugins/\$plugin_name"
                if [ ! -e "\$target_link" ]; then # Check if link/dir exists
                     echo "Linking plugin: \$plugin_name"
                     # Link as target user
                     sudo -u $TARGET_USER ln -s "\$plugin_dir" "\$target_link" || echo "Warning: Failed to link ASDF plugin \$plugin_name"
                else
                    echo "Plugin link for \$plugin_name already exists."
                fi

            fi
        done
        # Ensure correct ownership of the plugins directory
         sudo chown -R ${TARGET_UID}:${TARGET_GID} "$TARGET_USER_HOME/.asdf" || echo "Warning: Failed to chown .asdf directory."
    else
        echo "ASDF plugin cache directory ('\$ASDF_PLUGINS_CACHE_DIR') is empty or missing."
    fi
    echo "Note: ASDF tool versions need to be installed separately using 'asdf install'."
    echo "Ensure ASDF is sourced in your shell profile (e.g., .bashrc, .zshrc)."
    # Add sourcing if not present (example for bash)
    if [ -f "$TARGET_USER_HOME/.asdf/asdf.sh" ] && ! grep -q ".asdf.sh" "$TARGET_USER_HOME/.bashrc"; then
        echo "Adding ASDF sourcing to $TARGET_USER_HOME/.bashrc"
        echo -e "\n# ASDF Setup" | sudo -u $TARGET_USER tee -a "$TARGET_USER_HOME/.bashrc" > /dev/null
        echo ". \"\$HOME/.asdf/asdf.sh\"" | sudo -u $TARGET_USER tee -a "$TARGET_USER_HOME/.bashrc" > /dev/null
        echo ". \"\$HOME/.asdf/completions/asdf.bash\"" | sudo -u $TARGET_USER tee -a "$TARGET_USER_HOME/.bashrc" > /dev/null
    fi

else
    echo "Warning: ASDF binary not found after installation steps. Check previous steps (Go install, FS overlay)."
fi


# 12. Link Dotfiles
echo "--- Linking Dotfiles ---"
if [ -d "\$DOTFILES_REPO_DIR" ]; then
    echo "Using stow to link dotfiles from \$DOTFILES_REPO_DIR to \$TARGET_USER_HOME"
    ensure_dir "$TARGET_USER_HOME"
    # Run stow as the target user
    # Use -R (restow) to overwrite existing links if needed
    if command -v stow &>/dev/null; then
        # Change to dotfiles dir, run stow, change back
        (cd "\$DOTFILES_REPO_DIR" && sudo -u $TARGET_USER stow --verbose=1 --restow --target="$TARGET_USER_HOME" .) || echo "Warning: stow command failed. Manual linking might be needed. Check for conflicts."
    else
        echo "Warning: stow command not found. Cannot link dotfiles automatically."
        echo "Please link configuration files manually from \$DOTFILES_REPO_DIR"
    fi
    # Ensure ownership of linked files in home directory
    echo "Setting ownership for $TARGET_USER_HOME after stow..."
    sudo chown -R ${TARGET_UID}:${TARGET_GID} "$TARGET_USER_HOME" || echo "Warning: Failed to chown home directory after stow."

else
    echo "Warning: Dotfiles repository copy ('\$DOTFILES_REPO_DIR') not found in cache. Cannot link dotfiles."
fi

# 13. Manual Snap Package Installation
echo "--- Snap Package Installation (Manual Steps Required) ---"
if [ -n "$snap_packages_str" ] && [ -d "\$SNAP_CACHE_DIR" ] && [ "\$(ls -A \$SNAP_CACHE_DIR)" ]; then
    echo "Snap files (.snap, .assert) have been downloaded to: \$SNAP_CACHE_DIR"
    echo "Installation requires a working 'snapd' service on this target machine."
    echo "Install each snap manually using commands like the following:"
    echo ""
    snap_files=(\$SNAP_CACHE_DIR/*.snap)
    if [ \${#snap_files[@]} -gt 0 ] && [ "\${snap_files[0]}" != "\$SNAP_CACHE_DIR/*.snap" ]; then
        for snap_file in "\${snap_files[@]}"; do
            # Check if the corresponding .assert file exists
            assert_file="\${snap_file%.snap}.assert"
            if [ -f "\$assert_file" ]; then
                echo "# To install \$(basename "\$snap_file"): "
                echo "#   sudo snap ack \"\$assert_file\""
                echo "#   sudo snap install \"\$snap_file\""
                echo ""
            else
                # --dangerous is needed if assert file is missing
                echo "# To install \$(basename "\$snap_file") (use with caution if .assert is missing): "
                echo "#   sudo snap install --dangerous \"\$snap_file\""
                echo ""
            fi
        done
    else
        echo "No .snap files found in \$SNAP_CACHE_DIR, although directory exists."
    fi
    echo "NOTE: Run these commands manually after this script finishes."
else
    echo "No Snap packages specified or Snap cache directory ('\$SNAP_CACHE_DIR') is empty/missing."
fi

# 14. Final Setup Steps
echo "--- Running Final Setup Steps ---"
# Example: Add thefuck alias if not done by overlay/dotfiles
if command -v thefuck &>/dev/null && ! grep -q "thefuck --alias" $TARGET_USER_HOME/.bashrc; then
    echo "Adding thefuck alias to $TARGET_USER_HOME/.bashrc"
    echo -e '\n# The Fuck Alias\neval \$(thefuck --alias)' | sudo -u $TARGET_USER tee -a $TARGET_USER_HOME/.bashrc > /dev/null
fi
# Example: Set default pager if not done by overlay
if command -v most &>/dev/null; then
    echo "Setting default pager to 'most'..."
    sudo update-alternatives --set pager /usr/bin/most || true
fi
# Add other final commands from original setup.sh if needed

echo "--- Offline Installation Complete! ---"
echo "Please restart your shell or run 'source ~/.bashrc' or 'source ~/.profile'."
echo "Note: ASDF tool versions (Java, Python, Node, etc.) still need to be installed using 'asdf install <tool> <version>'."
echo "      The necessary ASDF plugins should be linked, but not the tools themselves."

EOF
    chmod +x "$output_path"
    echo "Generated offline installer script at: $output_path"
}