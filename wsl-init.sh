#!/bin/bash
# WSL-specific initialization script

# Function to check if we're running in WSL
is_wsl() {
	grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null
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

	# Auto-run APT network switch once per day (Continental/WSL specific)
	if command -v apt-network-switch &>/dev/null; then
		APT_LAST_CHECK_FILE="$HOME/.cache/apt-network-last-check"
		TODAY=$(date +%Y-%m-%d)

		# Create cache directory if it doesn't exist
		mkdir -p "$HOME/.cache"

		# Check if we've already run today
		if [[ ! -f "$APT_LAST_CHECK_FILE" ]] || [[ "$(cat "$APT_LAST_CHECK_FILE" 2>/dev/null)" != "$TODAY" ]]; then
			echo "🔄 Running daily APT network configuration check..."

			# Run the check in background to not block shell startup
			(
				apt-network-switch &>/dev/null
				if [ $? -eq 0 ]; then
					echo "$TODAY" >"$APT_LAST_CHECK_FILE"
					echo "✅ APT repositories configured for today's network"
				fi
			) &

			# Give it a moment to complete (but don't wait if it's slow)
			sleep 0.5
		fi
	fi

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
