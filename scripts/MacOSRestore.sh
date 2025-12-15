#!/bin/bash

# Enhanced macOS-style restore script with bounce effect
MINIMIZED_WINDOWS=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:minimized")')

if [ -z "$MINIMIZED_WINDOWS" ] || [ "$MINIMIZED_WINDOWS" = "null" ]; then
    notify-send "No Windows" "No minimized windows to restore" -t 1000 -i dialog-information
    exit 0
fi

WINDOW_COUNT=$(echo "$MINIMIZED_WINDOWS" | jq -s 'length')

# Create bouncy restoration effect
echo "Restoring $WINDOW_COUNT minimized windows"

# Stage 1: Bounce in effect
hyprctl keyword animation "windowsIn,1,8,macosSpring,popin 50%"
hyprctl keyword animation "specialWorkspace,1,8,macosSpring,slidevert"

# Show special workspace
hyprctl dispatch togglespecialworkspace minimized

# Stage 2: Settle effect
sleep 0.2
hyprctl keyword animation "windowsIn,1,6,macosSmooth,popin 60%"

# Stage 3: Final position
sleep 0.3
hyprctl keyword animation "windowsIn,1,6,macosEaseInOut,popin 60%"
hyprctl keyword animation "specialWorkspace,1,6,macosEaseInOut,slidevert"

# Cleanup cache
rm -rf ~/.cache/hypr/minimized/*.json 2>/dev/null

notify-send -t 800 -u low "Restored" "$WINDOW_COUNT windows restored" -i window-restore