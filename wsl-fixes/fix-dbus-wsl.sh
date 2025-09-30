#!/usr/bin/env bash
#
# Fix DBus for Electron/GUI apps in WSL2
# This ensures a proper DBus session is available
#

# Try to load existing DBus session first
if [[ -f ~/.dbus-session ]] && [[ -z "$DBUS_SESSION_BUS_ADDRESS" ]]; then
    source ~/.dbus-session 2>/dev/null
    # Verify the loaded session is still valid
    if [[ -n "$DBUS_SESSION_BUS_PID" ]] && kill -0 "$DBUS_SESSION_BUS_PID" 2>/dev/null; then
        # Export the variables so they're available in the current shell
        export DBUS_SESSION_BUS_ADDRESS
        export DBUS_SESSION_BUS_PID
        echo "Reusing existing DBus session (PID: $DBUS_SESSION_BUS_PID)"
        echo "DBus configured: $DBUS_SESSION_BUS_ADDRESS"
        return 0 2>/dev/null || exit 0
    fi
fi

# Check if DBus session bus socket exists
if [[ ! -S "/run/user/$(id -u)/bus" ]]; then
    # Start a new DBus session if not already running
    if [[ -z "$DBUS_SESSION_BUS_PID" ]] || ! kill -0 "$DBUS_SESSION_BUS_PID" 2>/dev/null; then
        # Clean up any stale DBus info
        rm -f ~/.dbus-session 2>/dev/null

        # Kill any orphaned dbus-daemon processes
        pkill -u $(id -u) dbus-daemon 2>/dev/null || true
        sleep 0.2

        # Start dbus-daemon and save the address
        eval $(dbus-launch --sh-syntax --exit-with-session)

        # Save for future shells
        echo "export DBUS_SESSION_BUS_ADDRESS='$DBUS_SESSION_BUS_ADDRESS'" > ~/.dbus-session
        echo "export DBUS_SESSION_BUS_PID='$DBUS_SESSION_BUS_PID'" >> ~/.dbus-session

        # Wait for daemon to be ready
        sleep 0.3

        echo "Started new DBus session (PID: $DBUS_SESSION_BUS_PID)"
    fi
elif [[ -z "$DBUS_SESSION_BUS_ADDRESS" ]]; then
    # Socket exists but environment variable not set
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    echo "Using existing DBus session at /run/user/$(id -u)/bus"
fi

# Display current DBus status
if [[ -n "$DBUS_SESSION_BUS_ADDRESS" ]]; then
    echo "DBus configured: $DBUS_SESSION_BUS_ADDRESS"
else
    echo "Warning: DBus not configured"
fi