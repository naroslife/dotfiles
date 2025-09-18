#!/usr/bin/env bash

set -euo pipefail

# Colors for nicer output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to check if we're running in WSL
is_wsl() {
    grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null
}

# Check for required commands
for cmd in git nix; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}❌ Required command '$cmd' not found. Please install it first.${NC}"
        exit 1
    fi
done

# Check for required files
for file in "flake.nix" "flake.lock" "home.nix"; do
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}❌ Required file '$file' not found in $(pwd). Please ensure your repo is complete.${NC}"
        exit 1
    fi
done

echo -e "${CYAN}🏠 Applying Home Manager configuration...${NC}"

# Check for WSL and show relevant info
if is_wsl; then
    echo -e "${YELLOW}🔧 WSL environment detected - applying WSL optimizations${NC}"
fi

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo -e "${RED}❌ Nix is not installed. Installing...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Check if flakes are enabled
if ! nix --version | grep -q "flakes"; then
    echo -e "${YELLOW}📝 Enabling flakes and nix-command...${NC}"
    mkdir -p ~/.config/nix
    if ! grep -q "experimental-features = nix-command flakes" ~/.config/nix/nix.conf 2>/dev/null; then
        echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
        sudo systemctl restart nix-daemon.service
    fi
fi

# Shell Script UX: --help and --dry-run
if [[ "${1:-}" == "--help" ]]; then
    echo -e "${CYAN}Usage: ./apply.sh [--dry-run]${NC}"
    echo -e "${CYAN}This script applies your Home Manager configuration using flakes or legacy mode.${NC}"
    exit 0
fi

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=1
    echo -e "${YELLOW}Dry run mode: no changes will be made.${NC}"
fi

# Prompt user for Home Manager type
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🏠 Which Home Manager do you want to use?${NC}"
echo -e "${CYAN}  [f] Flake-based (recommended, multi-user support)${NC}"
echo -e "${CYAN}  [r] Regular (legacy)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "👉 Please choose [f/r]: " hm_type

if [[ "$hm_type" =~ ^[Ff]$ ]]; then
    echo ""
    echo -e "${GREEN}✅ You chose: Flake-based Home Manager.${NC}"
    echo -e "${YELLOW}ℹ️  Building and applying Flake-based Home Manager config...${NC}"
    if [[ $DRY_RUN -eq 0 ]]; then
        # Prompt for username
        read -p "👉 Enter your username for Home Manager (default: $USER): " hm_user
        hm_user=${hm_user:-$USER}
        if nix run home-manager/master -- switch --flake .#"${hm_user}"; then
            echo -e "${GREEN}✅ Flake-based Home Manager configuration applied!${NC}"
            echo -e "${YELLOW}🔄 Reloading your shell to apply changes...${NC}"
            exec $SHELL -l
        else
            echo -e "${RED}❌ Failed to apply Flake-based Home Manager configuration.${NC}"
            exit 1
        fi
    fi
elif [[ "$hm_type" =~ ^[Rr]$ ]]; then
    echo ""
    echo -e "${GREEN}✅ You chose: Regular Home Manager.${NC}"
    echo -e "${YELLOW}ℹ️  Setting up Regular Home Manager...${NC}"
    if ! command -v home-manager &> /dev/null; then
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update
        nix-shell '<home-manager>' -A install
    fi
    if [[ $DRY_RUN -eq 0 ]]; then
        if home-manager switch -f ./home.nix; then
            echo -e "${GREEN}✅ Regular Home Manager configuration applied!${NC}"
            echo -e "${YELLOW}🔄 Reloading your shell to apply changes...${NC}"
            exec $SHELL -l
        else
            echo -e "${RED}❌ Failed to apply Regular Home Manager configuration.${NC}"
            exit 1
        fi
    fi
else
    echo ""
    echo -e "${RED}❌ Invalid choice. Exiting.${NC}"
    exit 1
fi

# Ask user if they want to use git submodules
if [[ -f ".gitmodules" ]]; then
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 Do you want to use git submodules?${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -p "👉 Use git submodules? [y/N]: " use_submodules
    if [[ "$use_submodules" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✅ Initializing git submodules...${NC}"
        git submodule update --init --recursive
    else
        echo -e "${YELLOW}🧹 Uninitializing git submodules...${NC}"
        git submodule deinit -f --all
        rm -rf .git/modules/*
    fi
fi

echo ""
echo -e "${CYAN}💡 If you need to push to private repos, you may need to unset your GitHub token.${NC}"
read -p "👉 Do you want to unset GITHUB_TOKEN and run 'gh auth login' now? [y/N]: " unset_gh_token
if [[ "$unset_gh_token" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🔑 Unsetting GITHUB_TOKEN and starting GitHub CLI authentication...${NC}"
    unset GITHUB_TOKEN
    gh auth login
fi

# Show info about submodules
if [[ -d "base" ]] && [[ -f "base/base.sh" ]]; then
    echo -e "${CYAN}📚 Base shell framework will be automatically sourced${NC}"
fi

if [[ -d "stdlib.sh" ]] && [[ -f "stdlib.sh/stdlib.sh" ]]; then
    echo -e "${CYAN}🔧 Stdlib.sh will be automatically sourced${NC}"
fi

# Show summary
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Summary:${NC}"
echo -e "${CYAN}• Home Manager type: $hm_type${NC}"
if [[ -f ".gitmodules" ]]; then
    echo -e "${CYAN}• Git submodules: $( [[ "$use_submodules" =~ ^[Yy]$ ]] && echo "enabled" || echo "disabled" )${NC}"
fi
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"