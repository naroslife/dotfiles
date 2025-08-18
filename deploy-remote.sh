#!/usr/bin/env bash
# filepath: /home/naroslife/dotfiles/deploy-remote.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${GREEN}✓${NC} $1"; }
print_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# Check if remote host is provided
if [[ $# -ne 1 ]]; then
    print_error "Usage: $0 <user@host>"
    echo "Example: $0 user@192.168.1.100"
    exit 1
fi

REMOTE_HOST="$1"
REMOTE_USER="${REMOTE_HOST%%@*}"

# Verify SSH connection
print_info "Testing SSH connection to ${REMOTE_HOST}..."
if ! ssh -o ConnectTimeout=5 "${REMOTE_HOST}" "echo 'SSH connection successful'" &>/dev/null; then
    print_error "Cannot connect to ${REMOTE_HOST}. Please check SSH access."
    exit 1
fi

# Check if Nix is installed locally
if ! command -v nix &> /dev/null; then
    print_error "Nix is not installed locally. Please install Nix first."
    exit 1
fi

# Build the Home Manager configuration locally
print_info "Building Home Manager configuration locally..."
BUILD_RESULT=$(nix build --no-link --print-out-paths .#homeConfigurations.naroslife.activationPackage 2>&1) || {
    print_error "Failed to build configuration"
    echo "$BUILD_RESULT"
    exit 1
}

# Extract the store path from build result
STORE_PATH=$(echo "$BUILD_RESULT" | tail -n1)
print_info "Built configuration at: ${STORE_PATH}"

# Compute closure to get all dependencies
print_info "Computing closure (all dependencies)..."
CLOSURE=$(nix-store -qR "${STORE_PATH}")
CLOSURE_SIZE=$(nix path-info -S "${STORE_PATH}" | awk '{print $2}')
CLOSURE_SIZE_MB=$((CLOSURE_SIZE / 1024 / 1024))
print_info "Total closure size: ${CLOSURE_SIZE_MB} MB"

# Check if Nix is installed on remote
print_info "Checking Nix installation on remote..."
if ! ssh "${REMOTE_HOST}" "command -v nix" &>/dev/null; then
    print_warn "Nix is not installed on remote. Installing Nix..."
    
    # Copy and run Nix installer on remote
    ssh "${REMOTE_HOST}" "sh <(curl -L https://nixos.org/nix/install) --daemon --yes" || {
        print_error "Failed to install Nix on remote"
        print_warn "You may need to install Nix manually on the remote machine"
        print_warn "After installing, run this script again"
        exit 1
    }
    
    # Source nix profile on remote
    ssh "${REMOTE_HOST}" ". ~/.nix-profile/etc/profile.d/nix.sh"
fi

# Enable flakes on remote if needed
print_info "Ensuring flakes are enabled on remote..."
ssh "${REMOTE_HOST}" "mkdir -p ~/.config/nix && echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf"

# Copy the closure to remote machine
print_info "Copying Nix store paths to remote (this may take a while)..."
print_warn "Transferring ${CLOSURE_SIZE_MB} MB of data..."

# Use nix copy with SSH store
nix copy --to "ssh://${REMOTE_HOST}" "${STORE_PATH}" --no-check-sigs || {
    print_error "Failed to copy store paths to remote"
    exit 1
}

print_info "Store paths copied successfully"

# Create activation script on remote
print_info "Creating activation script on remote..."
ACTIVATION_SCRIPT=$(cat <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

STORE_PATH="$1"
USER="$2"

echo "Activating Home Manager configuration..."

# Ensure user's nix profile exists
mkdir -p /nix/var/nix/profiles/per-user/${USER}

# Create a profile link
nix-env --profile /nix/var/nix/profiles/per-user/${USER}/home-manager --set "${STORE_PATH}"

# Run the activation
"${STORE_PATH}/activate"

echo "✅ Home Manager configuration activated successfully!"
echo "🎉 Please reload your shell or restart your terminal."
SCRIPT
)

ssh "${REMOTE_HOST}" "cat > /tmp/activate-home-manager.sh" <<< "$ACTIVATION_SCRIPT"
ssh "${REMOTE_HOST}" "chmod +x /tmp/activate-home-manager.sh"

# Run activation on remote
print_info "Activating configuration on remote..."
ssh "${REMOTE_HOST}" "/tmp/activate-home-manager.sh '${STORE_PATH}' '${REMOTE_USER}'" || {
    print_error "Failed to activate configuration"
    exit 1
}

# Copy the dotfiles repository for future updates (optional)
print_info "Copying dotfiles repository to remote..."
ssh "${REMOTE_HOST}" "mkdir -p ~/dotfiles"
rsync -av --exclude='.git' --exclude='result' ./ "${REMOTE_HOST}:~/dotfiles/" || {
    print_warn "Failed to copy dotfiles repository (non-critical)"
}

# Clean up
ssh "${REMOTE_HOST}" "rm -f /tmp/activate-home-manager.sh"

print_info "Deployment complete! 🎉"
print_info "The Home Manager environment is now active on ${REMOTE_HOST}"
print_warn "Note: The remote machine won't be able to update or rebuild without network access"
print_warn "To update, run this script again from an unrestricted machine"