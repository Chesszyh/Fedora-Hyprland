#!/bin/bash

# /* ---- 💫 Session Save Script for Hyprland 💫 ---- */
# Auto-save session on logout/shutdown and manual save functionality

SESSION_DIR="$HOME/.config/hypr/sessions"
SESSION_FILE="$SESSION_DIR/last_session.json"
BACKUP_DIR="$SESSION_DIR/backups"

# Create directories if they don't exist
mkdir -p "$SESSION_DIR" "$BACKUP_DIR"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$SESSION_DIR/session.log"
}

# Function to save current session
save_session() {
    log_message "Starting session save..."
    
    # Check if Hyprland is running and responsive
    if ! timeout 5 hyprctl version >/dev/null 2>&1; then
        log_message "Hyprland not responding, attempting to use last valid session from backup"
        
        # Try to restore from most recent backup if available
        if [ -d "$BACKUP_DIR" ]; then
            LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/session_*.json 2>/dev/null | head -1)
            if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
                cp "$LATEST_BACKUP" "$SESSION_FILE"
                log_message "Restored session from backup: $(basename "$LATEST_BACKUP")"
                return 0
            fi
        fi
        
        log_message "No valid backup found, session save failed"
        return 1
    fi
    
    # Create backup of previous session
    if [ -f "$SESSION_FILE" ]; then
        cp "$SESSION_FILE" "$BACKUP_DIR/session_$(date +%Y%m%d_%H%M%S).json"
        # Keep only last 10 backups
        ls -t "$BACKUP_DIR"/session_*.json | tail -n +11 | xargs -r rm
    fi
    
    # Get all client windows with timeout protection
    CLIENTS=""
    if CLIENTS=$(timeout 10 hyprctl clients -j 2>/dev/null); then
        if [ -z "$CLIENTS" ] || [ "$CLIENTS" = "[]" ]; then
            log_message "No clients found or empty client list"
            CLIENTS="[]"
        fi
    else
        log_message "Failed to get clients, using empty list"
        CLIENTS="[]"
    fi
    
    # Get current workspaces with timeout protection
    WORKSPACES=""
    if ! WORKSPACES=$(timeout 10 hyprctl workspaces -j 2>/dev/null); then
        log_message "Failed to get workspaces, using empty list"
        WORKSPACES="[]"
    fi
    
    # Get active workspace with timeout protection
    ACTIVE_WORKSPACE=""
    if ! ACTIVE_WORKSPACE=$(timeout 10 hyprctl activeworkspace -j 2>/dev/null); then
        log_message "Failed to get active workspace, using default"
        ACTIVE_WORKSPACE='{"id": 1, "name": "1"}'
    fi
    
    # Get monitor configuration with timeout protection
    MONITORS=""
    if ! MONITORS=$(timeout 10 hyprctl monitors -j 2>/dev/null); then
        log_message "Failed to get monitors, using empty list"
        MONITORS="[]"
    fi
    
    # Create session data with error handling
    SESSION_DATA=""
    if SESSION_DATA=$(jq -n \
        --argjson clients "$CLIENTS" \
        --argjson workspaces "$WORKSPACES" \
        --argjson active_workspace "$ACTIVE_WORKSPACE" \
        --argjson monitors "$MONITORS" \
        --arg timestamp "$(date -Iseconds)" \
        '{
            timestamp: $timestamp,
            monitors: $monitors,
            active_workspace: $active_workspace,
            workspaces: $workspaces,
            clients: $clients | map(select(.workspace.name != "special:minimized" and .workspace.name != "special:scratchpad"))
        }' 2>/dev/null); then
        
        # Save session to file
        echo "$SESSION_DATA" > "$SESSION_FILE"
        
        WINDOW_COUNT=$(echo "$CLIENTS" | jq 'length' 2>/dev/null || echo "0")
        log_message "Session saved successfully with $WINDOW_COUNT windows"
        
        # Send notification
        if command -v notify-send >/dev/null 2>&1; then
            notify-send -t 3000 -u low "Session Saved" "Saved $WINDOW_COUNT windows for restoration" -i document-save
        fi
    else
        log_message "Failed to create session JSON data"
        return 1
    fi
}

# Function to manually save session
manual_save() {
    save_session
    echo "Session saved manually"
}

# Function to auto-save on logout
auto_save() {
    log_message "Auto-saving session on logout/shutdown..."
    save_session
}

# Main execution based on parameter
case "${1:-auto}" in
    "manual")
        manual_save
        ;;
    "auto")
        auto_save
        ;;
    *)
        echo "Usage: $0 [manual|auto]"
        echo "  manual - Save session manually"
        echo "  auto   - Auto-save session (default)"
        exit 1
        ;;
esac