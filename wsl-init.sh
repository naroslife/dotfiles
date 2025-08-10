#!/bin/bash
# WSL-specific initialization script

# Function to check if we're running in WSL
is_wsl() {
    grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null
}

if is_wsl; then
    echo "🔧 WSL environment detected - applying optimizations..."
    
    # Set up Windows PATH integration (if needed)
    if [[ -d "/mnt/c/Windows/System32" ]]; then
        export PATH="$PATH:/mnt/c/Windows/System32"
    fi
    
    # WSL-specific aliases for clipboard integration
    alias pbcopy='clip.exe'
    alias pbpaste='powershell.exe -command "Get-Clipboard" | head -n -1'
    
    # Open files/URLs in Windows default applications
    alias open='wslview'
    
    # WSL utilities reminders
    echo "💡 WSL Tool Reminders:"
    echo "  wslview <file>     - Open file in Windows default app"
    echo "  wslpath <path>     - Convert between Windows and WSL paths"
    echo "  wslvar <var>       - Access Windows environment variables"
    echo "  clip.exe           - Copy to Windows clipboard"
    echo ""
    
    # Performance optimizations
    export WSLENV="PATH/l:XDG_CONFIG_HOME/up"
    
    # Ensure proper umask for Windows compatibility
    umask 022
fi
