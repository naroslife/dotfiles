#!/usr/bin/env bash

# --- Configuration ---
OFFLINE_CACHE_DIR="$HOME/offline_cache_$(date +%Y%m%d)"
URL_MAP_FILE="$OFFLINE_CACHE_DIR/url_map.txt"
PIP_CACHE="$OFFLINE_CACHE_DIR/pip"
GEM_CACHE="$OFFLINE_CACHE_DIR/gem"
ASDF_PLUGINS_CACHE="$OFFLINE_CACHE_DIR/asdf-plugins"
BIN_CACHE="$OFFLINE_CACHE_DIR/bin"
SCRIPT_CACHE="$OFFLINE_CACHE_DIR/scripts"
ARCHIVE_CACHE="$OFFLINE_CACHE_DIR/archives"
REPO_CACHE="$OFFLINE_CACHE_DIR/repos" # For git clones if needed

# --- Setup ---
mkdir -p "$OFFLINE_CACHE_DIR" "$PIP_CACHE" "$GEM_CACHE" "$ASDF_PLUGINS_CACHE" "$BIN_CACHE" "$SCRIPT_CACHE" "$ARCHIVE_CACHE" "$REPO_CACHE"
touch "$URL_MAP_FILE"
echo "Offline cache directory: $OFFLINE_CACHE_DIR"

# --- Helper Function ---
download_artifact() {
    local url="$1"
    local output_path="$2"
    local cache_subdir="$3"
    local filename=$(basename "$output_path")
    local full_path="$cache_subdir/$filename"

    echo "Downloading: $url -> $full_path"
    if curl -sSL --fail -o "$full_path" "$url"; then
        echo "$url $full_path" >> "$URL_MAP_FILE"
        echo "Success."
    else
        echo "Error downloading $url" >&2
        # exit 1 # Or handle error differently
    fi
}

# --- Download Resources from setup.sh ---

echo "Downloading installer scripts..."
download_artifact "https://dl.elv.sh/linux-amd64/elvish-v0.21.0.tar.gz" "elvish-v0.21.0.tar.gz" "$ARCHIVE_CACHE"
download_artifact "https://sh.rustup.rs" "rustup-init.sh" "$SCRIPT_CACHE"
# Note: rustup-init.sh itself downloads components. Offline install needs more work.
# Consider pre-installing rust fully and copying ~/.rustup and ~/.cargo, or using apt.

download_artifact "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh" "zoxide_install.sh" "$SCRIPT_CACHE"
# Need the binary zoxide downloads: Check zoxide_install.sh for the actual binary URL (might depend on arch)
# Example (assuming x86_64-linux):
download_artifact "https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-x86_64-unknown-linux-musl" "zoxide-bin" "$BIN_CACHE"

download_artifact "https://starship.rs/install.sh" "starship_install.sh" "$SCRIPT_CACHE"
# Need the binary starship downloads: Check starship_install.sh
# Example (assuming x86_64-linux-musl):
download_artifact "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-musl.tar.gz" "starship.tar.gz" "$ARCHIVE_CACHE"

download_artifact "https://raw.githubusercontent.com/ellie/atuin/main/install.sh" "atuin_install.sh" "$SCRIPT_CACHE"
# Need the binary atuin downloads: Check atuin_install.sh
# Example (assuming x86_64-linux-gnu):
download_artifact "https://github.com/atuinsh/atuin/releases/latest/download/atuin-x86_64-unknown-linux-gnu.tar.gz" "atuin.tar.gz" "$ARCHIVE_CACHE"

download_artifact "https://get.sdkman.io" "sdkman_install.sh" "$SCRIPT_CACHE"
# SDKMAN is heavily online-dependent. Consider skipping or using apt for Java/Gradle/Maven.

download_artifact "https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install" "navi_install.sh" "$SCRIPT_CACHE"
# Need the binary navi downloads: Check navi_install.sh
# Example (assuming x86_64-linux-musl):
download_artifact "https://github.com/denisidoro/navi/releases/latest/download/navi-x86_64-unknown-linux-musl.tar.gz" "navi.tar.gz" "$ARCHIVE_CACHE"


echo "Downloading pip packages..."
pip3 download --dest "$PIP_CACHE" thefuck pep8

echo "Downloading gems..."
gem fetch --output "$GEM_CACHE/tmuxinator.gem" tmuxinator

echo "Building/Fetching Go binaries..."
# Build asdf binary (replace with actual go install path if different)
# Assuming go is installed and configured
echo "Building asdf..."
GOBIN="$BIN_CACHE" go install github.com/asdf-vm/asdf/cmd/asdf@v0.16.0
if [ ! -f "$BIN_CACHE/asdf" ]; then echo "Failed to build asdf" >&2; fi

echo "Building/Fetching Cargo binaries..."
# Build eza binary
echo "Building eza..."
cargo install --root "$OFFLINE_CACHE_DIR" --locked eza # Installs to $OFFLINE_CACHE_DIR/bin
if [ ! -f "$BIN_CACHE/eza" ]; then echo "Failed to build eza" >&2; fi

echo "Cloning ASDF plugins..."
asdf_plugin_repo() {
    local name="$1"
    local url="$2"
    echo "Cloning ASDF plugin: $name"
    git clone --depth 1 "$url" "$ASDF_PLUGINS_CACHE/$name"
}
asdf_plugin_repo "java" "https://github.com/halcyon/asdf-java.git"
asdf_plugin_repo "gradle" "https://github.com/rfrancis/asdf-gradle.git"
asdf_plugin_repo "maven" "https://github.com/halcyon/asdf-maven.git"
asdf_plugin_repo "python" "https://github.com/asdf-community/asdf-python.git"
asdf_plugin_repo "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
asdf_plugin_repo "golang" "https://github.com/asdf-community/asdf-golang.git"
asdf_plugin_repo "rust" "https://github.com/asdf-community/asdf-rust.git"


# --- Final Steps ---
echo "Copying original setup script and dotfiles..."
# Assuming this script is run from within the dotfiles directory
rsync -a --exclude='.git' --exclude='offline_cache*' "$(pwd)/" "$OFFLINE_CACHE_DIR/dotfiles_repo/"

echo "Creating install_offline.sh template..."
# Create a basic install script template in the cache dir
# This will need significant manual editing based on setup.sh logic
cp "$OFFLINE_CACHE_DIR/dotfiles_repo/setup.sh" "$OFFLINE_CACHE_DIR/install_offline.sh"
# Add comments/placeholders in install_offline.sh indicating where to use cached files

echo "Packaging cache..."
tar czf "$HOME/offline_cache.tar.gz" -C "$HOME" "$(basename "$OFFLINE_CACHE_DIR")"

echo "-----------------------------------------------------"
echo "Offline cache prepared at: $HOME/offline_cache.tar.gz"
echo "Contains:"
echo " - Downloaded installers, binaries, archives"
echo " - Pip/Gem packages"
echo " - ASDF plugin repos"
echo " - Built Go/Rust tools (asdf, eza)"
echo " - URL map: $URL_MAP_FILE"
echo " - A copy of your dotfiles repo"
echo " - A template install_offline.sh (NEEDS EDITING!)"
echo "-----------------------------------------------------"
echo "Next Steps:"
echo "1. Transfer offline_cache.tar.gz to the restricted machine."
echo "2. Extract it: tar xzf offline_cache.tar.gz -C ~/"
echo "3. MANUALLY EDIT ~/offline_cache_*/install_offline.sh:"
echo "   - Replace ALL curl/wget/git clone commands with actions using files from the cache."
echo "   - Use '--no-index --find-links' for pip."
echo "   - Use '--local' for gem."
echo "   - Copy pre-built binaries (eza, asdf)."
echo "   - Manually add ASDF plugins from the cache dir."
echo "   - Handle Rust installation (apt or copy ~/.rustup, ~/.cargo)."
echo "   - Adapt install scripts (zoxide, starship, etc.) to use cached binaries instead of downloading."
echo "4. Run the edited install_offline.sh on the restricted machine."
