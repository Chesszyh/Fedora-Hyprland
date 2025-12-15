#!/bin/bash

# Enhanced macOS-style minimize script with true Dock Genie effect
WINDOW_ID=$(hyprctl activewindow -j | jq -r '.address')

if [ -z "$WINDOW_ID" ] || [ "$WINDOW_ID" = "null" ]; then
    exit 1
fi

# Get current window information
WINDOW_INFO=$(hyprctl activewindow -j)
WINDOW_CLASS=$(echo "$WINDOW_INFO" | jq -r '.class')
WINDOW_TITLE=$(echo "$WINDOW_INFO" | jq -r '.title')

# Get monitor information
MONITOR_INFO=$(hyprctl monitors -j | jq -r '.[0]')
SCREEN_W=$(echo "$MONITOR_INFO" | jq -r '.width')
SCREEN_H=$(echo "$MONITOR_INFO" | jq -r '.height')

# Calculate Dock position (bottom center)
DOCK_Y=$((SCREEN_H - 30))
DOCK_X=$((SCREEN_W / 2))

# Create multi-stage Genie effect
echo "Starting Genie effect for window: $WINDOW_TITLE"

# Stage 1: Quick scale down with perspective
hyprctl keyword animation "windowsOut,1,8,macosGenie,popin 90%"
sleep 0.1

# Stage 2: Further compression 
hyprctl keyword animation "windowsOut,1,10,macosGenie,popin 70%"
sleep 0.1

# Stage 3: Final collapse to dock
hyprctl keyword animation "windowsOut,1,12,macosGenie,popin 95%"

# Move to special workspace
hyprctl dispatch movetoworkspacesilent special:minimized

# Store window info for restoration
mkdir -p ~/.cache/hypr/minimized
echo "$WINDOW_INFO" > ~/.cache/hypr/minimized/"${WINDOW_ID}.json"

# Reset animation after effect
sleep 0.3
hyprctl keyword animation "windowsOut,1,8,macosGenie,popin 80%"

# Show subtle notification
notify-send -t 800 -u low "Minimized" "$WINDOW_TITLE" -i window-minimize