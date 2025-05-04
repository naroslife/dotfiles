#!/usr/bin/env bash

# --- Dockerfile Generation ---
generate_dockerfile() {
    local dockerfile_content
    # Ensure essential tools plus Go and Rust build environments are present
    # Add Node.js (npm) prerequisites
    read -r -d '' dockerfile_content <<EOF
FROM ${BASE_IMAGE}

# Set non-interactive frontend
ENV DEBIAN_FRONTEND=noninteractive

# Basic setup: Create user, install sudo and essential tools
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    sudo curl wget git build-essential software-properties-common \
    ca-certificates gnupg apt-transport-https lsb-release \
    python3-pip python3-dev ruby ruby-dev gem \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Go (using official Go image method as an alternative to snap/apt)
ARG GO_VERSION=1.21.5
RUN curl -fsSL "https://golang.org/dl/go\${GO_VERSION}.linux-amd64.tar.gz" | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:\$PATH"

# Install Rust (using rustup)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
ENV PATH="/root/.cargo/bin:\$PATH"

# Install Node.js (using NodeSource setup script)
ARG NODE_MAJOR=20
RUN apt-get update -qq && apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_\$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -qq && apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create target user and group
RUN groupadd -g ${TARGET_GID} ${TARGET_USER} || echo "Group ${TARGET_GID} exists"
RUN useradd -m -u ${TARGET_UID} -g ${TARGET_GID} -s /bin/bash ${TARGET_USER}
RUN echo "${TARGET_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to user
USER ${TARGET_USER}
WORKDIR ${TARGET_USER_HOME}

# Set up user's Cargo path
ENV PATH="${TARGET_USER_HOME}/.cargo/bin:\$PATH"
# Set up user's Go path if needed (Go installs might go to ~/go/bin)
ENV PATH="${TARGET_USER_HOME}/go/bin:\$PATH"

# Create cache directories owned by the user
RUN mkdir -p /cache/pip /cache/gem /cache/npm /cache/go_bin /cache/cargo_install /cache/cargo_registry
RUN sudo chown -R ${TARGET_USER}:${TARGET_USER} /cache

# Configure caches
ENV PIP_CACHE_DIR=/cache/pip
ENV GEM_HOME=/cache/gem
ENV GEM_PATH=/cache/gem
ENV npm_config_cache=/cache/npm
ENV CARGO_HOME=/cache/cargo_install
ENV CARGO_REGISTRY_CACHE=/cache/cargo_registry
ENV GOBIN=/cache/go_bin
ENV GOPATH=${TARGET_USER_HOME}/go # Default Go workspace

EOF

    local tmp_dockerfile=$(mktemp)
    echo "$dockerfile_content" > "$tmp_dockerfile"
    echo "$tmp_dockerfile" # Return the path to the temp file
}


# --- Container Setup Script Generation ---
generate_container_setup_script() {
    local output_path="$1"
    # Ensure config variables are available inside the heredoc
    local apt_packages_str="${APT_PACKAGES[*]}"
    local pip_packages_str="${PIP_PACKAGES[*]}"
    local gem_packages_str="${GEM_PACKAGES[*]}"
    local npm_packages_str="${NPM_PACKAGES[*]}"
    local go_packages_str="${GO_PACKAGES[*]}"
    local cargo_packages_str="${CARGO_PACKAGES[*]}"

    cat << EOF > "$output_path"
#!/usr/bin/env bash
set -ex # Exit on error, print commands

echo "--- Starting Container Setup ---"

# Ensure environment is set up (PATH for Go/Rust/Node)
export PATH="/usr/local/go/bin:${TARGET_USER_HOME}/.cargo/bin:${TARGET_USER_HOME}/go/bin:\$PATH"
export PIP_CACHE_DIR=/cache/pip
export GEM_HOME=/cache/gem
export GEM_PATH=/cache/gem
export npm_config_cache=/cache/npm
export CARGO_HOME=/cache/cargo_install
export CARGO_REGISTRY_CACHE=/cache/cargo_registry
export GOBIN=/cache/go_bin
export GOPATH=${TARGET_USER_HOME}/go

# 0. Non-interactive frontend
export DEBIAN_FRONTEND=noninteractive

# 1. Update APT and Install APT Packages
echo "--- Installing APT Packages ---"
sudo apt-get update -qq
if [ -n "$apt_packages_str" ]; then
    sudo apt-get install -qq -y --no-install-recommends $apt_packages_str
fi

# 2. Install Pip Packages
echo "--- Installing Pip Packages ---"
if [ -n "$pip_packages_str" ]; then
    pip3 install --user $pip_packages_str # Install for user
    # Download for caching (might require sudo if installing system-wide)
    sudo pip3 download --disable-pip-version-check --dest /cache/pip $pip_packages_str || echo "Pip download failed, cache might be incomplete"
fi

# 3. Install Gem Packages
echo "--- Installing Gem Packages ---"
if [ -n "$gem_packages_str" ]; then
    gem install --user-install $gem_packages_str # Install for user
    # Download for caching (might require sudo if installing system-wide)
    sudo gem fetch --output /cache/gem/ $gem_packages_str || echo "Gem fetch failed, cache might be incomplete"
fi

# 4. Install NPM Packages
echo "--- Installing NPM Packages ---"
if [ -n "$npm_packages_str" ]; then
    # Ensure npm cache dir exists and is writable
    mkdir -p /cache/npm && sudo chown -R ${TARGET_USER}:${TARGET_USER} /cache/npm
    npm config set cache /cache/npm --global
    npm install -g $npm_packages_str
    # Note: Capturing npm cache for offline use is complex.
    # 'npm pack' might be needed for specific packages if offline install fails.
fi

# 5. Install Go Packages
echo "--- Installing Go Packages ---"
if [ -n "$go_packages_str" ]; then
    # Ensure GOBIN exists and is writable
    mkdir -p /cache/go_bin && sudo chown -R ${TARGET_USER}:${TARGET_USER} /cache/go_bin
    go install $go_packages_str
fi

# 6. Install Cargo Packages
echo "--- Installing Cargo Packages ---"
if [ -n "$cargo_packages_str" ]; then
    # Ensure CARGO_HOME exists and is writable
    mkdir -p /cache/cargo_install && sudo chown -R ${TARGET_USER}:${TARGET_USER} /cache/cargo_install
    cargo install --locked $cargo_packages_str
    # Binaries are installed in /cache/cargo_install/bin
    # Copy them to a predictable location if needed, e.g., /cache/cargo_bin
    mkdir -p /cache/cargo_bin
    cp /cache/cargo_install/bin/* /cache/cargo_bin/ || echo "No cargo binaries to copy"
fi

# 7. Optional: Run original setup.sh
if [ "$RUN_ORIGINAL_SETUP_SH" = "true" ] && [ -f "${TARGET_USER_HOME}/dotfiles_ro/$SETUP_SH_PATH" ]; then
    echo "--- Running Original setup.sh ---"
    # Copy dotfiles from RO mount if needed
    cp -a "${TARGET_USER_HOME}/dotfiles_ro" "${TARGET_USER_HOME}/dotfiles_temp"
    cd "${TARGET_USER_HOME}/dotfiles_temp"
    # Attempt to make setup.sh non-interactive (basic examples)
    sed -i 's/zenity --question/true || /g' "$SETUP_SH_PATH"
    sed -i 's/zenity --info/echo/g' "$SETUP_SH_PATH"
    sed -i 's/zenity --progress/cat > \/dev\/null \& /g' "$SETUP_SH_PATH"
    # Run the script
    bash "./$SETUP_SH_PATH" || echo "Original setup.sh failed, continuing..."
    cd "${TARGET_USER_HOME}"
    rm -rf "${TARGET_USER_HOME}/dotfiles_temp"
else
    echo "--- Skipping Original setup.sh ---"
fi

# 8. Final Cleanup inside container
echo "--- Cleaning up APT cache ---"
sudo apt-get clean

echo "--- Container Setup Finished ---"

EOF
    chmod +x "$output_path"
}


# --- Run Installation Container ---
run_installation_container() {
    local container_name="$1"
    local image_tag="$2"
    local setup_script_path="$3"

    echo "Running container $container_name from image $image_tag..."

    # Define volume mounts for caches
    # Mount setup script read-only
    # Mount dotfiles source read-only if needed by setup.sh
    local docker_run_cmd=(
        docker run --rm --name "$container_name" -it \
        -v "$PIP_CACHE_DIR:/cache/pip" \
        -v "$GEM_CACHE_DIR:/cache/gem" \
        -v "$NPM_CACHE_DIR:/cache/npm" \
        -v "$GO_BIN_CACHE_DIR:/cache/go_bin" \
        -v "$CARGO_BIN_CACHE_DIR:/cache/cargo_bin" \
        -v "$CARGO_BIN_CACHE_DIR/../cargo_install:/cache/cargo_install" \
        -v "$CARGO_BIN_CACHE_DIR/../cargo_registry:/cache/cargo_registry" \
        -v "$setup_script_path:/tmp/container_setup.sh:ro"
    )

    # Conditionally mount dotfiles source if original setup script is run
    if [ "$RUN_ORIGINAL_SETUP_SH" = "true" ]; then
        # Ensure DOTFILES_SRC_DIR is correctly resolved relative to where prepare_offline_env.sh is run
        local resolved_dotfiles_src_dir
        resolved_dotfiles_src_dir=$(realpath "$DOTFILES_SRC_DIR")
        docker_run_cmd+=("-v" "$resolved_dotfiles_src_dir:${TARGET_USER_HOME}/dotfiles_ro:ro")
    fi

    docker_run_cmd+=("$image_tag" /bin/bash /tmp/container_setup.sh)

    # Execute the command
    "${docker_run_cmd[@]}"
}