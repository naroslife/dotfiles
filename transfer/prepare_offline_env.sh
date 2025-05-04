#!/usr/bin/env bash

set -e # Exit on error

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
CONFIG_FILE="$SCRIPT_DIR/config.sh"

# --- Load Configuration ---
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"
echo "Configuration loaded from $CONFIG_FILE"

# --- Source Helper Scripts ---
source "$SCRIPT_DIR/lib/docker_helpers.sh"
source "$SCRIPT_DIR/lib/capture_helpers.sh"
source "$SCRIPT_DIR/lib/installer_helpers.sh"

# --- Validate Prerequisites ---
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker."
    exit 1
fi
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed. Please install Git."
    exit 1
fi
if ! command -v rsync &> /dev/null; then
    echo "Error: rsync is not installed. Please install rsync."
    exit 1
fi
if ! command -v snap &> /dev/null; then
    echo "Warning: 'snap' command not found. Cannot download snap packages."
    # Decide if this is fatal or just a warning
    # exit 1
fi


# --- Setup Cache Directory ---
echo "Setting up cache directory structure in $OFFLINE_CACHE_BASE_DIR..."
CACHE_DIRS=(
    "$OFFLINE_CACHE_BASE_DIR/fs_overlay"
    "$OFFLINE_CACHE_BASE_DIR/apt_cache/archives/partial" # For apt download
    "$OFFLINE_CACHE_BASE_DIR/pip_cache"
    "$OFFLINE_CACHE_BASE_DIR/gem_cache"
    "$OFFLINE_CACHE_BASE_DIR/npm_cache"
    "$OFFLINE_CACHE_BASE_DIR/go_bin"
    "$OFFLINE_CACHE_BASE_DIR/cargo_bin"
    "$OFFLINE_CACHE_BASE_DIR/asdf_plugins"
    "$OFFLINE_CACHE_BASE_DIR/artifacts"
    "$OFFLINE_CACHE_BASE_DIR/bin" # For directly downloaded/built binaries
    "$OFFLINE_CACHE_BASE_DIR/snap_files"
    "$OFFLINE_CACHE_BASE_DIR/scripts"
    "$OFFLINE_CACHE_BASE_DIR/dotfiles_repo"
)
for dir in "${CACHE_DIRS[@]}"; do
    mkdir -p "$dir"
done
# Define specific cache paths based on base dir
APT_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/apt_cache/archives"
PIP_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/pip_cache"
GEM_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/gem_cache"
NPM_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/npm_cache"
SNAP_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/snap_files"
GO_BIN_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/go_bin"
CARGO_BIN_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/cargo_bin"
ASDF_PLUGINS_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/asdf_plugins"
ARTIFACTS_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/artifacts"
BIN_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/bin"
FS_OVERLAY_DIR="$OFFLINE_CACHE_BASE_DIR/fs_overlay"
SCRIPTS_DIR="$OFFLINE_CACHE_BASE_DIR/scripts"
DOTFILES_REPO_CACHE_DIR="$OFFLINE_CACHE_BASE_DIR/dotfiles_repo"


# --- Generate Dockerfile ---
echo "Generating Dockerfile..."
DOCKERFILE_PATH=$(generate_dockerfile) # Function from docker_helpers.sh
echo "Dockerfile generated at $DOCKERFILE_PATH"

# --- Build Base Image ---
echo "Building base Docker image..."
BASE_IMG_TAG="dotfiles-base-img:latest"
docker build -t "$BASE_IMG_TAG" -f "$DOCKERFILE_PATH" .
rm "$DOCKERFILE_PATH" # Clean up temporary Dockerfile

# --- Prepare Container Setup Script ---
echo "Preparing container setup script..."
CONTAINER_SETUP_SCRIPT_PATH="$SCRIPTS_DIR/container_setup.sh"
generate_container_setup_script "$CONTAINER_SETUP_SCRIPT_PATH" # Function from docker_helpers.sh

# --- Run Container for Installation ---
CONTAINER_NAME="dotfiles-capture-$(date +%s)"
echo "Running installation in container: $CONTAINER_NAME"
run_installation_container "$CONTAINER_NAME" "$BASE_IMG_TAG" "$CONTAINER_SETUP_SCRIPT_PATH" # Function from docker_helpers.sh

# --- Capture Filesystem and Caches ---
echo "Capturing filesystem changes and caches..."
capture_filesystem "$CONTAINER_NAME" "$FS_OVERLAY_DIR" # Function from capture_helpers.sh
capture_caches "$CONTAINER_NAME" # Function from capture_helpers.sh

# --- Download Direct Artifacts and ASDF Plugins ---
echo "Downloading direct artifacts..."
download_direct_artifacts # Function from capture_helpers.sh (uses config)

echo "Cloning ASDF plugin repositories..."
clone_asdf_plugins # Function from capture_helpers.sh (uses config)

# --- Download Snap Files ---
echo "Downloading Snap files..."
download_snap_files # Function from capture_helpers.sh (uses config)


echo "Capturing Snap files..."
capture_snap_files "$CONTAINER_NAME" "$SNAP_CACHE_DIR"

# --- Cleanup Container ---
echo "Cleaning up container..."
docker rm "$CONTAINER_NAME"
# Optional: docker rmi "$BASE_IMG_TAG"

# --- Generate Offline Installer Script ---
echo "Generating offline installer script..."
INSTALLER_SCRIPT_PATH="$SCRIPTS_DIR/install_offline.sh"
generate_offline_installer "$INSTALLER_SCRIPT_PATH" # Function from installer_helpers.sh

# --- Copy Dotfiles Repo ---
echo "Copying dotfiles repository to cache..."
rsync -a --exclude='.git' --exclude='offline_cache*' --exclude="$(basename "$OFFLINE_CACHE_BASE_DIR")" \
    "$DOTFILES_SRC_DIR/" "$DOTFILES_REPO_CACHE_DIR/"

# --- Package Cache ---
PACKAGE_NAME="offline_env_$(date +%Y%m%d).tar.gz"
echo "Packaging cache into $PACKAGE_NAME..."
tar czf "$HOME/$PACKAGE_NAME" -C "$HOME" "$(basename "$OFFLINE_CACHE_BASE_DIR")"

echo "-----------------------------------------------------"
echo "Offline environment package created: $HOME/$PACKAGE_NAME"
echo "Review $INSTALLER_SCRIPT_PATH before use on the restricted machine."
echo "-----------------------------------------------------"
