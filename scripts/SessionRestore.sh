#!/bin/bash

# /* ---- 💫 Session Restore Script for Hyprland 💫 ---- */
# Restore previous session windows and layouts

SESSION_DIR="$HOME/.config/hypr/sessions"
SESSION_FILE="$SESSION_DIR/last_session.json"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$SESSION_DIR/session.log"
}

# Function to wait for application to launch
wait_for_window() {
    local class="$1"
    local timeout=10
    local count=0
    
    while [ $count -lt $timeout ]; do
        if hyprctl clients -j | jq -e ".[] | select(.class == \"$class\")" >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.5
        ((count++))
    done
    return 1
}

# Function to restore session
restore_session() {
    if [ ! -f "$SESSION_FILE" ]; then
        log_message "No session file found at $SESSION_FILE"
        
        # Try to find the most recent backup
        if [ -d "$SESSION_DIR/backups" ]; then
            LATEST_BACKUP=$(ls -t "$SESSION_DIR/backups"/session_*.json 2>/dev/null | head -1)
            if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
                log_message "Found backup session: $(basename "$LATEST_BACKUP")"
                cp "$LATEST_BACKUP" "$SESSION_FILE"
                notify-send "Session Restore" "Using backup session: $(basename "$LATEST_BACKUP")" -t 3000 -i dialog-information
            else
                notify-send "Session Restore" "No previous session found" -t 3000 -i dialog-information
                return 1
            fi
        else
            notify-send "Session Restore" "No previous session found" -t 3000 -i dialog-information
            return 1
        fi
    fi
    
    log_message "Starting session restore..."
    
    # Read session data
    SESSION_DATA=$(cat "$SESSION_FILE")
    
    # Check if session data is valid
    if ! echo "$SESSION_DATA" | jq empty 2>/dev/null; then
        log_message "Invalid session data format, trying backup"
        
        # Try to use backup if main session file is corrupted
        if [ -d "$SESSION_DIR/backups" ]; then
            LATEST_BACKUP=$(ls -t "$SESSION_DIR/backups"/session_*.json 2>/dev/null | head -1)
            if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
                log_message "Using backup session due to corruption"
                SESSION_DATA=$(cat "$LATEST_BACKUP")
                if ! echo "$SESSION_DATA" | jq empty 2>/dev/null; then
                    log_message "Backup session also corrupted"
                    notify-send "Session Restore" "Session data is corrupted" -t 3000 -i dialog-error
                    return 1
                fi
            else
                notify-send "Session Restore" "Session data is corrupted" -t 3000 -i dialog-error
                return 1
            fi
        else
            notify-send "Session Restore" "Session data is corrupted" -t 3000 -i dialog-error
            return 1
        fi
    fi
    
    # Get session timestamp
    SESSION_TIME=$(echo "$SESSION_DATA" | jq -r '.timestamp // "unknown"')
    log_message "Restoring session from $SESSION_TIME"
    
    # Get clients from session
    CLIENTS=$(echo "$SESSION_DATA" | jq -c '.clients[]? // empty')
    
    if [ -z "$CLIENTS" ]; then
        log_message "No windows to restore"
        notify-send "Session Restore" "No windows to restore" -t 3000 -i dialog-information
        return 0
    fi
    
    # Count total windows
    TOTAL_WINDOWS=$(echo "$SESSION_DATA" | jq '.clients | length')
    RESTORED_COUNT=0
    
    notify-send "Session Restore" "Restoring $TOTAL_WINDOWS windows..." -t 2000 -i window-restore
    
    # Create a map of workspace names to ensure they exist
    declare -A workspace_created
    
    # Process each client
    while IFS= read -r client; do
        # Extract client information
        CLASS=$(echo "$client" | jq -r '.class // empty')
        TITLE=$(echo "$client" | jq -r '.title // empty')
        WORKSPACE=$(echo "$client" | jq -r '.workspace.name // empty')
        PID=$(echo "$client" | jq -r '.pid // empty')
        INITIAL_CLASS=$(echo "$client" | jq -r '.initialClass // empty')
        INITIAL_TITLE=$(echo "$client" | jq -r '.initialTitle // empty')
        
        # Skip if essential info is missing
        if [ -z "$CLASS" ] || [ "$CLASS" = "null" ]; then
            log_message "Skipping window with missing class information"
            continue
        fi
        
        # Determine the command to launch the application
        APP_COMMAND=""
        
        # Map common applications to their launch commands
        case "$CLASS" in
            # Browsers
            "firefox"|"Firefox"|"Navigator")
                APP_COMMAND="firefox"
                ;;
            "Google-chrome"|"google-chrome"|"chrome")
                APP_COMMAND="google-chrome"
                ;;
            # Editors/IDEs
            "code"|"Code"|"VSCodium"|"codium")
                APP_COMMAND="code"
                ;;
            "cursor"|"Cursor")
                APP_COMMAND="cursor"
                ;;
            "android-studio"|"Android-studio")
                APP_COMMAND="android-studio"
                ;;
            # Terminals
            "kitty"|"Kitty")
                APP_COMMAND="kitty"
                ;;
            "Alacritty"|"alacritty")
                APP_COMMAND="alacritty"
                ;;
            "ptyxis"|"Ptyxis")
                APP_COMMAND="ptyxis"
                ;;
            # File managers
            "thunar"|"Thunar")
                APP_COMMAND="thunar"
                ;;
            "obs"|"obs-studio")
                APP_COMMAND="obs"
                ;;
            "nm-connection-editor")
                APP_COMMAND="nm-connection-editor"
                ;;
            # Document viewers
            "evince"|"Evince")
                APP_COMMAND="evince"
                ;;
            "moderncsv"|"ModernCSV")
                APP_COMMAND="moderncsv"
                ;;
            *)
                # Try to use the class name as command
                if command -v "${CLASS,,}" >/dev/null 2>&1; then
                    APP_COMMAND="${CLASS,,}"
                elif command -v "$CLASS" >/dev/null 2>&1; then
                    APP_COMMAND="$CLASS"
                else
                    log_message "Unknown application class: $CLASS, skipping..."
                    continue
                fi
                ;;
        esac
        
        # Create workspace if it doesn't exist and isn't created yet
        if [ "$WORKSPACE" != "null" ] && [ ! -z "$WORKSPACE" ] && [ "${workspace_created[$WORKSPACE]}" != "1" ]; then
            if [[ "$WORKSPACE" =~ ^[0-9]+$ ]]; then
                # It's a regular workspace number
                hyprctl dispatch workspace "$WORKSPACE" 2>/dev/null || true
                workspace_created["$WORKSPACE"]=1
                log_message "Created/switched to workspace: $WORKSPACE"
            fi
        fi
        
        # Launch the application
        log_message "Launching $APP_COMMAND for class $CLASS"
        
        if [ "$WORKSPACE" != "null" ] && [ ! -z "$WORKSPACE" ] && [[ "$WORKSPACE" =~ ^[0-9]+$ ]]; then
            # Launch on specific workspace
            hyprctl dispatch exec "[workspace $WORKSPACE] $APP_COMMAND" &
        else
            # Launch on current workspace
            hyprctl dispatch exec "$APP_COMMAND" &
        fi
        
        # Wait a bit between launches to avoid overwhelming the system
        sleep 0.3
        
        ((RESTORED_COUNT++))
        
    done <<< "$CLIENTS"
    
    # Wait a moment for applications to settle
    sleep 2
    
    # Try to restore the active workspace
    ACTIVE_WORKSPACE=$(echo "$SESSION_DATA" | jq -r '.active_workspace.id // empty')
    if [ ! -z "$ACTIVE_WORKSPACE" ] && [ "$ACTIVE_WORKSPACE" != "null" ]; then
        hyprctl dispatch workspace "$ACTIVE_WORKSPACE" 2>/dev/null || true
        log_message "Restored active workspace: $ACTIVE_WORKSPACE"
    fi
    
    log_message "Session restore completed. Attempted to restore $RESTORED_COUNT windows"
    notify-send "Session Restore" "Restored $RESTORED_COUNT applications" -t 3000 -i window-restore
}

# Function to restore session with delay (for startup)
restore_session_delayed() {
    local delay=${1:-5}
    log_message "Scheduling session restore in $delay seconds..."
    
    # Wait for desktop environment to be ready
    sleep "$delay"
    
    # Additional check - make sure hyprctl is working
    local retries=5
    while [ $retries -gt 0 ]; do
        if hyprctl version >/dev/null 2>&1; then
            break
        fi
        sleep 1
        ((retries--))
    done
    
    if [ $retries -eq 0 ]; then
        log_message "Hyprland not ready, skipping session restore"
        return 1
    fi
    
    restore_session
}

# Function to list available sessions
list_sessions() {
    echo "Available sessions:"
    if [ -f "$SESSION_FILE" ]; then
        echo "  last_session.json ($(jq -r '.timestamp' "$SESSION_FILE" 2>/dev/null || echo 'corrupted'))"
    fi
    
    if [ -d "$SESSION_DIR/backups" ]; then
        find "$SESSION_DIR/backups" -name "session_*.json" -printf "  %f (%TY-%Tm-%Td %TH:%TM)\n" | sort -r
    fi
}

# Main execution
case "${1:-restore}" in
    "restore")
        restore_session
        ;;
    "delayed")
        restore_session_delayed "${2:-5}"
        ;;
    "list")
        list_sessions
        ;;
    *)
        echo "Usage: $0 [restore|delayed [seconds]|list]"
        echo "  restore  - Restore session immediately"
        echo "  delayed  - Restore session after delay (default 5 seconds)"
        echo "  list     - List available sessions"
        exit 1
        ;;
esac