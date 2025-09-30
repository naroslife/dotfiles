#!/usr/bin/env bash
#
# AppImage Launcher for WSL2
# Fixes common Electron/AppImage issues on WSL2
#
# Usage: launch-appimage.sh <path-to-appimage> [args...]
#

set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: $(basename "$0") <path-to-appimage> [args...]"
    exit 1
fi

APPIMAGE="$1"
shift

if [[ ! -f "$APPIMAGE" ]]; then
    echo "Error: AppImage not found: $APPIMAGE"
    exit 1
fi

if [[ ! -x "$APPIMAGE" ]]; then
    echo "Error: AppImage is not executable: $APPIMAGE"
    echo "Run: chmod +x $APPIMAGE"
    exit 1
fi

# Ensure DBus session exists
if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    # Try to restore from saved session
    if [[ -f ~/.dbus-session ]]; then
        source ~/.dbus-session
    fi

    # If still not set, start a new session
    if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
        eval $(dbus-launch --sh-syntax)
        echo "export DBUS_SESSION_BUS_ADDRESS='$DBUS_SESSION_BUS_ADDRESS'" > ~/.dbus-session
        echo "export DBUS_SESSION_BUS_PID='$DBUS_SESSION_BUS_PID'" >> ~/.dbus-session
    fi
fi

# Set XDG_RUNTIME_DIR if not set
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Ensure DISPLAY is set
export DISPLAY="${DISPLAY:-:0}"

# Disable GPU acceleration if causing issues (can be removed if GPU works fine)
# export LIBGL_ALWAYS_SOFTWARE=1

# Fix for "dri3 extension not supported" warning
export MESA_LOADER_DRIVER_OVERRIDE=d3d12

# Electron flags to improve WSL2 compatibility
export ELECTRON_EXTRA_LAUNCH_ARGS="--disable-gpu-sandbox --disable-software-rasterizer --enable-features=UseSkiaRenderer"

# Disable Wayland (use X11 instead for better compatibility)
export GDK_BACKEND=x11

echo "Starting AppImage with WSL2 fixes..."
echo "  DISPLAY: $DISPLAY"
echo "  DBUS: $DBUS_SESSION_BUS_ADDRESS"
echo "  XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
echo

# Detect config directory for the app
# Extract app name from AppImage filename (e.g., Next-Client-1.10.0.AppImage -> Next-Client)
APPIMAGE_BASENAME=$(basename "$APPIMAGE")
APP_NAME=$(echo "$APPIMAGE_BASENAME" | sed -E 's/-[0-9]+\.[0-9]+\.[0-9]+\.AppImage$//')

# Change to app config directory if it exists
# This helps apps that look for settings.json in the current directory
CONFIG_DIR="$HOME/.config/$APP_NAME"
if [[ -d "$CONFIG_DIR" ]]; then
    cd "$CONFIG_DIR"
    echo "Working directory: $CONFIG_DIR"
    echo
fi

# Launch the AppImage
exec "$APPIMAGE" "$@"