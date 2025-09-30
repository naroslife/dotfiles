#!/usr/bin/env bash
#
# Specific launcher for Next-Client with all known fixes
# This wraps launch-appimage.sh with Next-Client-specific workarounds
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPIMAGE="$HOME/dev/Next-Client-1.10.0.AppImage"

if [[ ! -f "$APPIMAGE" ]]; then
    echo "Error: AppImage not found at $APPIMAGE"
    exit 1
fi

# Source DBus fix
source "$SCRIPT_DIR/fix-dbus-wsl.sh"

# Next-Client specific environment
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS}"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Fix environment variable conflicts from CUDA/Nix that cause slow Electron startup
unset LD_LIBRARY_PATH CUDA_HOME CUDA_PATH
unset LOCALE_ARCHIVE_2_27 NIX_PROFILES __ETC_PROFILE_NIX_SOURCED

# Reset JAVA_HOME to system default if using Nix Java
if [[ "$JAVA_HOME" == *"/nix/store/"* ]]; then
    if [[ -d "/usr/lib/jvm/default-java" ]]; then
        export JAVA_HOME="/usr/lib/jvm/default-java"
    else
        unset JAVA_HOME
    fi
fi

echo "  Cleaned environment (removed CUDA/Nix conflicts)"

# Force software rendering (most reliable for Electron apps on WSLg)
export LIBGL_ALWAYS_SOFTWARE=1

# Disable GPU entirely for maximum compatibility
export ELECTRON_EXTRA_LAUNCH_ARGS="--disable-gpu --no-sandbox --disable-dev-shm-usage --disable-software-rasterizer --disable-features=VaapiVideoDecoder"

# Use X11, not Wayland
export GDK_BACKEND=x11

# Disable hardware video decoding
export LIBVA_DRIVER_NAME=none

# Change to config directory
cd "$HOME/.config/Next-Client" || mkdir -p "$HOME/.config/Next-Client" && cd "$HOME/.config/Next-Client"

echo "Launching Next-Client with maximum compatibility settings..."
echo "  DISPLAY: $DISPLAY"
echo "  Software Rendering: ENABLED"
echo "  GPU: DISABLED"
echo "  Working directory: $(pwd)"
echo

# Launch the AppImage
exec "$APPIMAGE" "$@"