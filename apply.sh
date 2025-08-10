#!/usr/bin/env bash

set -euo pipefail

# Function to check if we're running in WSL
is_wsl() {
    grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null
}

echo "🏠 Applying Home Manager configuration..."

# Check for WSL and show relevant info
if is_wsl; then
    echo "🔧 WSL environment detected - applying WSL optimizations"
fi

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo "❌ Nix is not installed. Please install Nix first:"
    echo "   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
    exit 1
fi

# Check if flakes are enabled
if ! nix --version | grep -q "flakes"; then
    echo "📝 Enabling flakes and nix-command..."
    mkdir -p ~/.config/nix
    if ! grep -q "experimental-features = nix-command flakes" ~/.config/nix/nix.conf 2>/dev/null; then
        echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    fi
fi

# Initialize submodules if they exist
if [[ -f ".gitmodules" ]]; then
    echo "📦 Initializing git submodules..."
    git submodule update --init --recursive
fi

# Apply the configuration
echo "🔧 Applying Home Manager configuration..."
nix run home-manager/master -- switch --flake .#naroslife

echo "✅ Home Manager configuration applied successfully!"
echo "🎉 You may need to reload your shell or restart your terminal."

# Show info about submodules
if [[ -d "base" ]] && [[ -f "base/base.sh" ]]; then
    echo "📚 Base shell framework will be automatically sourced"
fi

if [[ -d "stdlib.sh" ]] && [[ -f "stdlib.sh/stdlib.sh" ]]; then
    echo "🔧 Stdlib.sh will be automatically sourced"
fi
