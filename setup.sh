#!/usr/bin/env bash


# Add the rsteube apt repository if it's not already added
add_rsteube_repo() {
    echo "Checking if rsteube apt repository is added..."
    if ! grep -q "^deb .*apt.fury.io/rsteube" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        echo "Adding rsteube apt repository..."
        echo "deb [trusted=yes] https://apt.fury.io/rsteube/ /" | sudo tee /etc/apt/sources.list.d/fury.list
        sudo apt update -qq
    else
        echo "rsteube apt repository is already added."
    fi
}


# Function to install ASDF plugins
install_asdf() {
  echo "Installing ASDF plugins..."
  # Check if plugin exists first to avoid errors
  asdf plugin list | grep -q "^java$" || asdf plugin add java 2>/dev/null
  asdf plugin list | grep -q "^gradle$" || asdf plugin add gradle 2>/dev/null
  asdf plugin list | grep -q "^maven$" || asdf plugin add maven 2>/dev/null
  asdf plugin list | grep -q "^python$" || asdf plugin add python 2>/dev/null
  asdf plugin list | grep -q "^nodejs$" || asdf plugin add nodejs 2>/dev/null
  asdf plugin list | grep -q "^golang$" || asdf plugin add golang 2>/dev/null
  asdf plugin list | grep -q "^rust$" || asdf plugin add rust 2>/dev/null
}

# Check if zenity is installed
if ! command -v zenity >/dev/null 2>&1; then
    echo "zenity is not installed. Installing zenity..."
    sudo apt-get update -qq && sudo apt-get install -qq -y zenity
fi

# Set up trap for SIGINT (Ctrl+C)
trap 'zenity --error --title="Installation Canceled" --text="Installation was canceled by user."; exit 1' INT

# Variable to track errors
ERROR_COUNT=0
ERROR_LOG="/tmp/dotfiles_errors_$(date +%Y%m%d_%H%M%S).log"

# Function to display a welcome message
show_welcome() {
    zenity --info \
        --title="Dotfiles Setup" \
        --text="Welcome to the dotfiles setup script!\nThis will configure your development environment with various tools and utilities.\nYou can choose what components to install in the following screens." \
        --width=400 
}

# Function to confirm dependency installation
confirm_dependencies() {
    zenity --question \
        --title="Install Dependencies" \
        --text="This script will install the following packages and tools:\n\nSYSTEM: curl wget git build-essential software-properties-common\nSHELLS: elvish\nUTILS: zoxide starship atuin fzf most tmux\nDEV: go rust python3 nodejs git-lfs clang cmake gdb ninja\nTOOLS: eza thefuck tldr navi docker carapace\nJAVA: openjdk-17 maven gradle sdkman\nC++: clang valgrind cppcheck boost doxygen\nRUBY: ruby tmuxinator\n\nDo you want to continue with the installation?" \
        --width=500 
    
    return $?
}

# Function to safely execute commands
safe_exec() {
    local cmd="$1"
    local desc="$2"
    
    # Execute command, redirecting output to logs
    if eval "$cmd" >> "$LOG_FILE" 2>> "$ERROR_LOG"; then
        return 0
    else
        ERROR_COUNT=$((ERROR_COUNT + 1))
        echo "Failed: $desc" >> "$ERROR_LOG"
        return 1
    fi
}

# Function to check if directory exists
dir_exists() {
    [ -d "$1" ]
}


# Main script flow
show_welcome

if confirm_dependencies; then
    # Create log file
    LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"
    
    # Create a proper FIFO for progress updates
    FIFO=$(mktemp -u)
    mkfifo "$FIFO"
    
    # Start Zenity progress dialog in background
    zenity --progress \
        --title="Installing Dependencies" \
        --text="Starting installation..." \
        --percentage=0 \
        --auto-close \
        --no-cancel \
         \
        --width=400 < "$FIFO" &
    ZENITY_PID=$!
    
{
        # Function to update the progress
        update_progress() {
            local percent=$1
            local message=$2
            echo "$percent"
            echo "# $message"
        }
        
        update_progress 0 "Updating system packages..."
        # Suppress apt warnings
        export DEBIAN_FRONTEND=noninteractive
        safe_exec "sudo apt-get update -qq" "update package lists"
        
        update_progress 5 "Upgrading system packages..."
        safe_exec "sudo apt-get upgrade -qq -y" "upgrade packages"
        
        update_progress 10 "Installing essential packages..."
        safe_exec "sudo apt-get install -qq -y curl wget git build-essential software-properties-common" "install essential packages"
        
        update_progress 15 "Installing Elvish shell..."
        if ! command -v elvish &>/dev/null; then
            safe_exec "curl -so - https://dl.elv.sh/linux-amd64/elvish-v0.21.0.tar.gz | sudo tar -xzC /usr/local/bin" "install elvish"
        else
            echo "Elvish is already installed, skipping..." >> "$LOG_FILE"
        fi
        
        update_progress 20 "Installing Rust..."
        if ! command -v rustc &>/dev/null; then
            safe_exec "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" "install rust"
            safe_exec "source $HOME/.cargo/env" "load cargo env"
        else
            echo "Rust is already installed, skipping..." >> "$LOG_FILE"
        fi
        
        update_progress 25 "Installing Zoxide and Starship..."
        if ! command -v zoxide &>/dev/null; then
            safe_exec "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash" "install zoxide"
        fi
        if ! command -v starship &>/dev/null; then
            # Fix: Remove the -y flag from starship installation
            safe_exec "curl -sS https://starship.rs/install.sh | sh" "install starship" 
        fi
        
        update_progress 30 "Installing Atuin and tools..."
        if ! command -v atuin &>/dev/null; then
            # Fix: Remove the -y flag from atuin installation
            safe_exec "curl -s https://raw.githubusercontent.com/ellie/atuin/main/install.sh | bash" "install atuin"
        fi
        
        # Check if snapd is needed and properly install
        update_progress 35 "Installing snapd and Go..."
        if ! command -v snap &>/dev/null; then
            safe_exec "sudo apt-get install -qq -y snapd" "install snapd"
        fi
        
        # Only try to install Go with snap if snapd socket exists
        if [ -S /run/snapd.socket ] && ! command -v go &>/dev/null; then
            safe_exec "sudo snap install go --classic" "install go"
        elif ! command -v go &>/dev/null; then
            # Fallback to apt for Go if snap fails
            safe_exec "sudo apt-get install -qq -y golang-go" "install go from apt"
        fi
        
        update_progress 40 "Installing carapace..."
        if command -v go &>/dev/null && ! command -v carapace &>/dev/null; then
            add_rsteube_repo
            safe_exec "sudo apt install carapace-bin" "install carapace"
        fi
        
        safe_exec "sudo apt-get install -qq -y tmux fzf git-lfs python3-dev python3-pip most python3-pygments ruby" "install dev packages"
        
        update_progress 45 "Installing ASDF version manager..."
        if ! dir_exists "$HOME/.asdf"; then
            safe_exec "go install github.com/asdf-vm/asdf/cmd/asdf@v0.16.0" "install asdf"
            source ~/.bashrc
        else
            echo "ASDF is already installed, skipping..." >> "$LOG_FILE"
        fi
        
        safe_exec "git lfs install" "setup git lfs"
        
        update_progress 50 "Installing Python packages..."
        if ! command -v thefuck &>/dev/null; then
            safe_exec "pip3 install thefuck pep8" "install python packages"
            grep -q "thefuck --alias" ~/.bashrc || echo 'eval $(thefuck --alias)' >> ~/.bashrc
        fi
        
        if command -v most &>/dev/null; then
            safe_exec "sudo update-alternatives --set pager /usr/bin/most" "set most as default pager" || true
        fi
        
        update_progress 60 "Installing developer tools..."
        if command -v rustc &>/dev/null && ! command -v eza &>/dev/null; then
            safe_exec "cargo install eza" "install eza"
        fi
        
        if command -v gem &>/dev/null && ! command -v tmuxinator &>/dev/null; then
            safe_exec "sudo gem install tmuxinator" "install tmuxinator"
        fi
        
        if command -v tldr &>/dev/null; then
            # Don't try to update tldr as it's causing errors
            echo "TLDR is already installed, skipping update due to potential git issues..." >> "$LOG_FILE"
        else
            safe_exec "sudo apt-get install -qq -y tldr" "install tldr from apt"
        fi
        
        if ! command -v navi &>/dev/null; then
            safe_exec "bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)" "install navi"
        fi
        
        update_progress 70 "Installing C/C++ build tools..."
        safe_exec "sudo apt-get install -qq -y build-essential gdb cmake ninja-build" "install C/C++ build tools"

        update_progress 72 "Installing C/C++ compiler tools..."
        safe_exec "sudo apt-get install -qq -y clang clang-format clang-tidy lldb" "install clang tools"

        update_progress 74 "Installing C/C++ analysis tools..."
        safe_exec "sudo apt-get install -qq -y cppcheck valgrind" "install analysis tools"

        # This is where the pipe error occurs
        update_progress 76 "Installing C/C++ libraries..."
        # Add error handling to make the boost installation more robust
        if ! dpkg -l | grep -q libboost-all-dev; then
            # Install with explicit error handling
            safe_exec "sudo apt-get install -qq -y libboost-all-dev" "install boost libraries" || true
            # Add a small delay to let the pipe stabilize
            sleep 0.5
        fi

        # Add special handling for doxygen
        update_progress 78 "Installing C/C++ documentation tools..."
        if ! command -v doxygen &>/dev/null; then
            safe_exec "sudo apt-get install -qq -y doxygen" "install doxygen" || true
            sleep 0.2
        fi

        if ! command -v dot &>/dev/null; then
            safe_exec "sudo apt-get install -qq -y graphviz" "install graphviz" || true
            sleep 0.2
        fi

        # if ! pip3 list | grep -q conan; then
        #     safe_exec "pip3 install conan" "install conan"
        # fi
        
        update_progress 80 "Installing Java tools..."
        safe_exec "sudo apt-get install -qq -y openjdk-17-jdk maven gradle" "install Java tools"
        
        update_progress 90 "Installing SDKMAN..."
        if ! dir_exists "$HOME/.sdkman"; then
            safe_exec "curl -s 'https://get.sdkman.io' | bash" "install SDKMAN"
            if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
                source "$HOME/.sdkman/bin/sdkman-init.sh"
            fi
        else
            echo "SDKMAN is already installed, skipping..." >> "$LOG_FILE"
        fi
        
        update_progress 95 "Installing ASDF plugins..."
        if command -v asdf &>/dev/null; then
            install_asdf
        fi
        
        update_progress 100 "Installation complete!"
    } > "$FIFO"  

    # Clean up the FIFO
    rm "$FIFO"
    
    # Wait for zenity to finish
    wait $ZENITY_PID
    
    # Check for errors
    if [ $ERROR_COUNT -gt 0 ]; then
        zenity --text-info \
            --title="Installation Complete With Errors" \
            --filename="$ERROR_LOG" \
            --width=600 --height=400 \
            --text="Installation completed with $ERROR_COUNT errors. See details below:"
    else
        zenity --info \
            --title="Installation Complete" \
            --text="All dependencies have been installed successfully!\n\nLog details saved to: $LOG_FILE" \
            --width=400 
    fi
else
    zenity --info \
        --title="Installation Skipped" \
        --text="Dependency installation was skipped.\nYour configuration files will still be linked." \
        --width=400 
fi

# Link configuration files
echo "Linking configuration files..."

# Try a different approach for progress display - use direct stdout to zenity
# This avoids relying on files that might cause synchronization issues

(
    # Echo progress percentage and message directly to zenity
    echo "0" 
    echo "# Starting configuration setup..."
    sleep 0.1
    
    # Check if stow is installed, install if not
    echo "10" 
    echo "# Checking for stow..."
    if ! command -v stow &>/dev/null; then
        echo "15"
        echo "# Installing stow..."
        export DEBIAN_FRONTEND=noninteractive
        sudo apt-get install -qq -y stow >/dev/null 2>&1
    fi
    sleep 0.1
    
    # Create necessary directories
    echo "30"
    echo "# Creating directory structure..."
    mkdir -p ~/.config/starship ~/.config/zsh 2>/dev/null
    sleep 0.1
    
    # Try to use stow first, but don't fail if it errors
    echo "40"
    echo "# Setting up symlinks with stow..."
    if command -v stow &>/dev/null; then
        ( cd "$(dirname -- "$(readlink -f -- "$0")")" && stow . -t ~ ) 2>/dev/null || true
    fi
    sleep 0.1
    
    # Always set up manual symlinks as a fallback - do these one by one with progress updates
    echo "50"
    echo "# Setting up bashrc..."
    SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
    ln -sf "$SCRIPT_DIR/.bashrc" ~/.bashrc 2>/dev/null
    sleep 0.1
    
    echo "55"
    echo "# Setting up bash_completion..."
    ln -sf "$SCRIPT_DIR/.bash_completion" ~/.bash_completion 2>/dev/null
    sleep 0.1
    
    echo "60"
    echo "# Setting up profile..."
    ln -sf "$SCRIPT_DIR/.profile" ~/.profile 2>/dev/null
    ln -sf "$SCRIPT_DIR/.tool-versions" ~/.tool-versions 2>/dev/null
    sleep 0.1
    
    echo "70"
    echo "# Setting up starship configuration..."
    mkdir -p ~/.config/starship 2>/dev/null
    ln -sf "$SCRIPT_DIR/starship/starship.toml" ~/.config/starship/starship.toml 2>/dev/null
    sleep 0.1
    
    # Breaking up the progress more finely around the 70-80% mark where errors occur
    echo "75"
    echo "# Setting up zsh config..."
    ln -sf "$SCRIPT_DIR/zshrc/.zshrc" ~/.zshrc 2>/dev/null
    sleep 0.1
    
    echo "80"
    echo "# Setting up zprofile..."
    ln -sf "$SCRIPT_DIR/zshrc/.zprofile" ~/.zprofile 2>/dev/null
    sleep 0.1

    echo "85"
    echo "# Setting up stdlib.sh..."

    # Link each file from stdlib.sh to /usr/local/lib
    STDLIB_DIR="$SCRIPT_DIR/stdlib.sh"
    if [ -d "$STDLIB_DIR" ]; then
        for file in "$STDLIB_DIR"/*.sh; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                sudo ln -sf "$file" "/usr/local/lib/$filename" 2>/dev/null
            fi
        done
        
        # Also link any subdirectory files if they exist
        if [ -d "$STDLIB_DIR/lib" ]; then
            for file in "$STDLIB_DIR/lib"/*.sh; do
                if [ -f "$file" ]; then
                    filename=$(basename "$file")
                    sudo ln -sf "$file" "/usr/local/lib/$filename" 2>/dev/null
                fi
            done
        fi
        
        # Make sure it's in the path by adding to .bashrc if not already there
        if ! grep -q "source /usr/local/lib/stdlib.sh" ~/.bashrc; then
            echo "source /usr/local/lib/stdlib.sh" >> ~/.bashrc
        fi
    fi
    sleep 0.1


    
    # Finish up with slightly longer delay
    echo "95"
    echo "# Finalizing configuration..."
    sleep 0.2
    
    echo "100"
    echo "# Configuration complete!"
    sleep 0.5
    
) | zenity --progress \
      --title="Linking Configuration Files" \
      --text="Setting up configuration files..." \
      --percentage=0 \
      --auto-close \
      --width=400 || true

# Show completion message regardless of zenity exit status
zenity --info \
    --title="Setup Complete" \
    --text="Setup has been completed successfully!" \
    --width=400