# Phase 2: Transfer and Initial Activation (From Online Machine, Targeting Offline Machine)

# Step 1: Transfer Nix Store Closure (Online Machine):
echo "Phase 2, Step 1: Transferring Nix store closure..."
nix copy --to ssh://uif58593@10.36.67.81 "$ACTIVATION_PACKAGE_STORE_PATH"
echo "Nix store closure transfer complete."
echo ""

# Step 2: Transfer Specific Flake Configuration Files to Offline Machine (Online Machine):
echo "Phase 2, Step 2: Transferring specific configuration files and directories..."
# --- Begin rsync script block ---
# (Ensure you are in the root of your dotfile repo, e.g., ~/my-nix-dots/ or /home/uif58593/transferEnv/dotfiles/)
ITEMS_TO_SYNC=(
    "flake.nix" "flake.lock" "home.nix"
    "setup.sh"
    ".bashrc" ".profile" ".bash_completion" ".fzf.bash" ".gitconfig" ".tmux.conf" ".stowrc"
    "elvish/" "nvim/" "tmux/" "starship/" "atuin/"
    "base/" "carapace/" "karabiner/" "nautilus/" "ssh/" "stdlib.sh/" "termscp/" "tmux/" "tmuxinator/" "util-linux/" "wezterm/"
     
)

# Define log file path (on the online machine)
RSYNC_LOG_FILE="rsync_transfer_$(date +%Y%m%d_%H%M%S).log"

# Output for confirmation (optional)
echo "The following items will be synced:" | tee -a "$RSYNC_LOG_FILE" # Log this too
for item in "${ITEMS_TO_SYNC[@]}"; do
    echo "  - ${item}" | tee -a "$RSYNC_LOG_FILE"
done
echo "" | tee -a "$RSYNC_LOG_FILE"

# 1. Ensure target directory exists on the offline machine
echo "Ensuring target directory exists on offline machine..." | tee -a "$RSYNC_LOG_FILE"
ssh uif58593@10.36.67.81 "mkdir -p ~/.config/nix-config/"
REMOTE_MKDIR_STATUS=$?

if [ $REMOTE_MKDIR_STATUS -ne 0 ]; then
    echo "ERROR: Failed to create directory on remote machine. Aborting rsync." | tee -a "$RSYNC_LOG_FILE"
    # exit $REMOTE_MKDIR_STATUS # Optional: exit script on error
else
    echo "Target directory ready." | tee -a "$RSYNC_LOG_FILE"
    # 2. Perform the rsync, redirecting stderr and optionally stdout
    echo "Starting rsync... Logs will be in $RSYNC_LOG_FILE"
    # -i for itemized changes can be very verbose but helpful for debugging specific files
    # Remove -i if too noisy for normal operation
    rsync -avzi --relative "${ITEMS_TO_SYNC[@]}" uif58593@10.36.67.81:~/.config/nix-config/ >> "$RSYNC_LOG_FILE" 2>&1
    RSYNC_STATUS=$?

    if [ $RSYNC_STATUS -eq 0 ]; then
        echo "Rsync completed successfully." | tee -a "$RSYNC_LOG_FILE"
        echo "Details logged to $RSYNC_LOG_FILE"
    elif [ $RSYNC_STATUS -eq 23 ]; then
        echo "ERROR: rsync completed with code 23 - Some files/attrs were not transferred." | tee -a "$RSYNC_LOG_FILE"
        echo "This often indicates permission issues on the source, or issues writing attributes on the destination." | tee -a "$RSYNC_LOG_FILE"
        echo "Please check the detailed rsync errors in $RSYNC_LOG_FILE"
    else
        echo "ERROR: rsync failed with exit code $RSYNC_STATUS." | tee -a "$RSYNC_LOG_FILE"
        echo "Please check the detailed rsync errors in $RSYNC_LOG_FILE"
    fi
fi
# --- End rsync script block ---

# Step 3: Run Activation Script on Offline Machine (Online Machine):
# echo "Phase 2, Step 3: Running activation script on offline machine..."
# ssh uif58593@10.36.67.81 "\"$ACTIVATION_PACKAGE_STORE_PATH/activate\""
# echo "Activation script execution attempted."
# echo ""

# Step 4: Verify (Online Machine - New SSH Session):
echo "Phase 2, Step 4: Verification - Please start a new SSH session to the offline machine and run:"
echo "  which home-manager"
echo "  home-manager --version"
echo ""