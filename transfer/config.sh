#!/usr/bin/env bash

# --- Target System Configuration ---
TARGET_USER="user"      # Username on the target restricted machine
TARGET_UID="1000"       # User ID on the target restricted machine
TARGET_GID="1000"       # Group ID on the target restricted machine
TARGET_USER_HOME="/home/$TARGET_USER"
BASE_IMAGE="ubuntu:22.04" # Base Docker image (match target OS)

# --- Cache Configuration ---
OFFLINE_CACHE_BASE_DIR="$HOME/offline_env_$(date +%Y%m%d)"
# Subdirectories will be created automatically:
# fs_overlay, apt_cache, pip_cache, gem_cache, npm_cache, go_bin, cargo_bin, scripts, dotfiles_repo

# --- Dotfiles Source ---
# Assumes the scripts are run from within the dotfiles directory structure
DOTFILES_SRC_DIR="$(dirname -- "$(readlink -f -- "$0")")"

# --- Package Lists ---
APT_PACKAGES=(
    # Essentials & Build Tools
    sudo curl wget git build-essential software-properties-common ca-certificates gnupg apt-transport-https lsb-release
    # Shells & Terminal Tools
    tmux fzf most zsh # Add zsh if needed
    # Dev Tools
    git-lfs python3-dev python3-pip ruby ruby-dev gem default-jdk maven gradle
    # C/C++
    gdb cmake ninja-build clang clang-format clang-tidy lldb cppcheck valgrind libboost-all-dev
    # Documentation & Utils
    doxygen graphviz stow tree jq bat # Add bat if desired
    # Add other apt packages needed by setup.sh or desired tools
    snapd # If needed for specific snaps like go
)

PIP_PACKAGES=(
    thefuck
    pep8
    # Add other global pip packages
)

GEM_PACKAGES=(
    tmuxinator
    # Add other global gem packages
)

GO_PACKAGES=(
    # Go packages to install globally using 'go install'
    # Example: github.com/junegunn/fzf@latest # If not using apt version
    github.com/asdf-vm/asdf/cmd/asdf@v0.16.0 # Install ASDF via go
)

CARGO_PACKAGES=(
    # Rust crates to install globally using 'cargo install'
    eza
    # navi # Navi might be better via direct binary download if install script is complex
    # tldr # Consider apt version or other clients
    # Add other global cargo crates
)

NPM_PACKAGES=(
    # Node.js packages to install globally using 'npm install -g'
    # Example: yarn
    # Example: typescript
)

SNAP_PACKAGES=(
    # Add desired snap packages here
    # Example:
    # code # VS Code
    # go --classic # Go compiler (alternative to apt/manual)
    # helm --classic
)

# --- Direct Downloads / Custom Install Scripts ---
# Define URLs for tools not easily handled by package managers above
# Format: "URL|TARGET_FILENAME|DEST_SUBDIR"
# Dest subdirs: artifacts, bin (for executables)
DIRECT_DOWNLOADS=(
    "https://dl.elv.sh/linux-amd64/elvish-v0.21.0.tar.gz|elvish.tar.gz|artifacts"
    "https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install|navi_install.sh|artifacts" # Keep script if needed offline
    "https://github.com/denisidoro/navi/releases/latest/download/navi-x86_64-unknown-linux-musl.tar.gz|navi.tar.gz|artifacts" # Navi binary archive
    # Add other specific downloads if setup.sh uses them and they aren't covered above
)

# --- ASDF Plugins ---
# Format: "plugin_name|git_repo_url"
ASDF_PLUGINS=(
    "java|https://github.com/halcyon/asdf-java.git"
    "gradle|https://github.com/rfrancis/asdf-gradle.git"
    "maven|https://github.com/halcyon/asdf-maven.git"
    "python|https://github.com/asdf-community/asdf-python.git"
    "nodejs|https://github.com/asdf-vm/asdf-nodejs.git"
    "golang|https://github.com/asdf-community/asdf-golang.git"
    "rust|https://github.com/asdf-community/asdf-rust.git"
)

# --- Optional: Run Original setup.sh ---
# Set to true if setup.sh performs actions beyond package installation
# that need to be captured (e.g., complex system config, service setup).
# If true, ensure setup.sh is compatible with non-interactive execution.
RUN_ORIGINAL_SETUP_SH="true"
SETUP_SH_PATH="setup.sh" # Relative path to setup.sh from DOTFILES_SRC_DIR

# --- Filesystem Capture Targets ---
# Directories within the container to capture after installation
# Use paths relative to root ('/')
CAPTURE_DIRS=(
    "/usr/local/bin"
    "/usr/local/lib"
    "/usr/local/sbin"
    "/usr/local/share"
    "/opt" # Common location for manual installs
    "/etc/bash_completion.d" # For completions
    # Capture relevant parts of the user's home, adjust TARGET_USER if needed
    "/home/$TARGET_USER/.local/bin"
    "/home/$TARGET_USER/.local/share"
    "/home/$TARGET_USER/.cargo/bin" # Cargo installs here by default
    "/home/$TARGET_USER/.config"
    "/home/$TARGET_USER/.asdf" # Capture ASDF shims and installed versions
    "/home/$TARGET_USER/.npm" # NPM global installs might go here too
    # Add other specific directories modified by your tools/setup
)