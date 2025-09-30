#!/usr/bin/env bash
#
# Fix DBus for Electron/GUI apps in WSL2
# This ensures a proper DBus session is available
#

# Check if DBus session bus socket exists
if [[ ! -S "/run/user/$(id -u)/bus" ]]; then
    # Start a new DBus session if not already running
    if [[ -z "$DBUS_SESSION_BUS_PID" ]] || ! kill -0 "$DBUS_SESSION_BUS_PID" 2>/dev/null; then
        # Clean up any stale DBus info
        rm -f ~/.dbus-session 2>/dev/null

        # Start dbus-daemon and save the address
        eval $(dbus-launch --sh-syntax)

        # Save for future shells
        echo "export DBUS_SESSION_BUS_ADDRESS='$DBUS_SESSION_BUS_ADDRESS'" > ~/.dbus-session
        echo "export DBUS_SESSION_BUS_PID='$DBUS_SESSION_BUS_PID'" >> ~/.dbus-session

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