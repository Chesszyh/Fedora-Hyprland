#!/bin/bash

# /* ---- 💫 Session Signal Handler for Hyprland 💫 ---- */
# Handles shutdown signals to save session before system shutdown

SESSION_DIR="$HOME/.config/hypr/sessions"
SCRIPTS_DIR="$HOME/.config/hypr/scripts"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SIGNAL: $1" >> "$SESSION_DIR/session.log"
}

# Function to save session on signal
save_session_on_signal() {
    log_message "Received shutdown signal, saving session..."
    "$SCRIPTS_DIR/SessionSave.sh" auto
    log_message "Session save completed, exiting"
    exit 0
}

# Set up signal handlers for various shutdown scenarios
trap save_session_on_signal SIGTERM SIGINT SIGHUP SIGQUIT

# Create session directory if it doesn't exist
mkdir -p "$SESSION_DIR"

log_message "Signal handler started (PID: $$)"

# Keep the script running in background
while true; do
    sleep 60
    
    # Check if parent Hyprland process is still running
    if ! pgrep -x "Hyprland" > /dev/null; then
        log_message "Hyprland process ended, signal handler exiting"
        break
    fi
done

log_message "Signal handler exiting normally"