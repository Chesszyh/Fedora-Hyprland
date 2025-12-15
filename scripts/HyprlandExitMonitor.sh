#!/bin/bash

# /* ---- 💫 Hyprland Exit Monitor for Session Save 💫 ---- */
# This script monitors Hyprland process and saves session before exit

SESSION_DIR="$HOME/.config/hypr/sessions"
SCRIPTS_DIR="$HOME/.config/hypr/scripts"
PID_FILE="$SESSION_DIR/hyprland_monitor.pid"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] MONITOR: $1" >> "$SESSION_DIR/session.log"
}

# Function to cleanup on exit
cleanup() {
    log_message "Monitor shutting down"
    rm -f "$PID_FILE"
    exit 0
}

# Set up signal handlers
trap cleanup EXIT TERM INT

# Create session directory if it doesn't exist
mkdir -p "$SESSION_DIR"

# Store PID
echo $$ > "$PID_FILE"

log_message "Starting Hyprland exit monitor"

# Monitor Hyprland process
while true; do
    # Check if Hyprland is running
    if ! pgrep -x "Hyprland" > /dev/null; then
        log_message "Hyprland not running, monitor exiting"
        break
    fi
    
    # Sleep for a short interval
    sleep 2
done

# If we reach here, Hyprland has exited
log_message "Hyprland process ended, saving session before exit"

# Try to save session if we still have access to hyprctl
if command -v hyprctl >/dev/null 2>&1; then
    # Give a small delay to ensure Hyprland is still responding
    sleep 0.5
    if timeout 5 hyprctl version >/dev/null 2>&1; then
        "$SCRIPTS_DIR/SessionSave.sh" auto
    else
        log_message "Hyprland not responding, skipping session save"
    fi
else
    log_message "hyprctl not available, skipping session save"
fi

cleanup