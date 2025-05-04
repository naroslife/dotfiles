#!/usr/bin/env bash

set -e # Exit on error

SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
CONFIG_FILE="$SCRIPT_DIR/transfer/config.sh"
PREPARE_SCRIPT="$SCRIPT_DIR/transfer/prepare_offline_env.sh"
REMOTE_TEMP_DIR="/tmp/offline_deploy_$(date +%s)"

# --- Check for Host Argument ---
if [ -z "$1" ]; then
    echo "Usage: $0 <user@hostname_or_ip>"
    echo "  Example: $0 user@192.168.1.100"
    exit 1
fi
REMOTE_HOST="$1"

# --- Get Current User Details ---
CURRENT_USER=$(whoami)
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
echo "Using current user details:"
echo "  User: $CURRENT_USER"
echo "  UID:  $CURRENT_UID"
echo "  GID:  $CURRENT_GID"

# --- Update config.sh ---
echo "Updating $CONFIG_FILE with current user details..."
# Use sed to replace the values. Using | as delimiter to avoid issues with paths.
sed -i "s|^TARGET_USER=.*|TARGET_USER=\"$CURRENT_USER\"|" "$CONFIG_FILE"
sed -i "s|^TARGET_UID=.*|TARGET_UID=\"$CURRENT_UID\"|" "$CONFIG_FILE"
sed -i "s|^TARGET_GID=.*|TARGET_GID=\"$CURRENT_GID\"|" "$CONFIG_FILE"
# Update TARGET_USER_HOME based on the new TARGET_USER
sed -i "s|^TARGET_USER_HOME=.*|TARGET_USER_HOME=\"/home/$CURRENT_USER\"|" "$CONFIG_FILE"
echo "Configuration updated."

# --- Run Preparation Script ---
echo "Running preparation script ($PREPARE_SCRIPT)..."
# Ensure prepare script is executable
chmod +x "$PREPARE_SCRIPT"
# Run the script from its directory to ensure relative paths work
(cd "$SCRIPT_DIR/transfer" && bash "$(basename "$PREPARE_SCRIPT")")

# Find the generated tarball (assuming only one matching pattern in $HOME)
TARBALL_PATH=$(find "$HOME" -maxdepth 1 -name 'offline_env_*.tar.gz' -printf '%T@ %p\n' | sort -nr | head -n 1 | cut -d' ' -f2-)
if [ -z "$TARBALL_PATH" ]; then
    echo "Error: Could not find the generated offline_env_*.tar.gz package in $HOME" >&2
    exit 1
fi
TARBALL_NAME=$(basename "$TARBALL_PATH")
echo "Found package: $TARBALL_PATH"

# --- Transfer Package to Remote Host ---
echo "Transferring $TARBALL_NAME to $REMOTE_HOST:$REMOTE_TEMP_DIR/"
# Create remote directory first via ssh
ssh "$REMOTE_HOST" "mkdir -p $REMOTE_TEMP_DIR"
# Copy the tarball
scp "$TARBALL_PATH" "$REMOTE_HOST:$REMOTE_TEMP_DIR/"
echo "Transfer complete."

# --- Execute Installation on Remote Host ---
echo "Executing remote installation on $REMOTE_HOST..."
ssh "$REMOTE_HOST" << EOF
    set -e # Exit on error within the remote script
    echo "--- Remote: Starting Installation ---"
    cd "$REMOTE_TEMP_DIR"
    echo "Extracting $TARBALL_NAME..."
    tar xzf "$TARBALL_NAME"
    # Find the extracted directory name (should match pattern)
    EXTRACTED_DIR=\$(find . -maxdepth 1 -name 'offline_env_*' -type d -printf '%f\n')
    if [ -z "\$EXTRACTED_DIR" ]; then
        echo "Error: Could not find extracted directory in $REMOTE_TEMP_DIR" >&2
        exit 1
    fi
    echo "Running installer script: \$EXTRACTED_DIR/scripts/install_offline.sh"
    # Run the installer with sudo
    sudo bash "\$EXTRACTED_DIR/scripts/install_offline.sh"
    echo "--- Remote: Installation Script Finished ---"

    # Optional: Cleanup
    echo "Cleaning up remote temporary files..."
    rm -f "$TARBALL_NAME"
    rm -rf "\$EXTRACTED_DIR"
    # Attempt to remove the parent temp dir, might fail if other things are there
    rmdir "$REMOTE_TEMP_DIR" 2>/dev/null || true
    echo "--- Remote: Cleanup Complete ---"
EOF

echo "--- Deployment Process Finished ---"
# Optional: Clean up local tarball
# echo "Cleaning up local package: $TARBALL_PATH"
# rm "$TARBALL_PATH"

exit 0