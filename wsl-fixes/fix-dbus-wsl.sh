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

# Check if we need to start a DBus session
# Don't rely on socket existence alone - verify daemon is actually running
NEED_NEW_SESSION=false

if [[ -z "$DBUS_SESSION_BUS_PID" ]] || ! kill -0 "$DBUS_SESSION_BUS_PID" 2>/dev/null; then
    # No valid PID, need to check if daemon is actually responsive
    if [[ -S "/run/user/$(id -u)/bus" ]]; then
        # Socket exists, test if it's responsive
        if ! dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames &>/dev/null; then
            # Socket exists but not responsive
            NEED_NEW_SESSION=true
        else
            # Socket is responsive, use it
            export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
            echo "Using existing DBus daemon at /run/user/$(id -u)/bus"
        fi
    else
        # No socket, definitely need new session
        NEED_NEW_SESSION=true
    fi
fi

if [[ "$NEED_NEW_SESSION" == "true" ]]; then
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

# Display current DBus status
if [[ -n "$DBUS_SESSION_BUS_ADDRESS" ]]; then
    echo "DBus configured: $DBUS_SESSION_BUS_ADDRESS"
else
    echo "Warning: DBus not configured"
fi