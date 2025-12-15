#!/bin/bash

# /* ---- 💫 Periodic Session Saver for Hyprland 💫 ---- */
# Saves session periodically to ensure we always have a recent backup

SESSION_DIR="$HOME/.config/hypr/sessions"
SCRIPTS_DIR="$HOME/.config/hypr/scripts"
INTERVAL=3600  # Save every 60 minutes

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] PERIODIC: $1" >> "$SESSION_DIR/session.log"
}

# Create session directory if it doesn't exist
mkdir -p "$SESSION_DIR"

log_message "Starting periodic session saver (interval: ${INTERVAL}s)"

while true; do
    # Check if Hyprland is still running
    if ! pgrep -x "Hyprland" > /dev/null; then
        log_message "Hyprland not running, periodic saver exiting"
        break
    fi
    
    # Check if there are any windows open before saving
    if timeout 5 hyprctl clients -j >/dev/null 2>&1; then
        WINDOW_COUNT=$(hyprctl clients -j 2>/dev/null | jq 'length' 2>/dev/null || echo "0")
        if [ "$WINDOW_COUNT" -gt 0 ]; then
            log_message "Periodic save triggered - $WINDOW_COUNT windows detected"
            "$SCRIPTS_DIR/SessionSave.sh" auto >/dev/null 2>&1
        fi
    fi
    
    sleep "$INTERVAL"
done