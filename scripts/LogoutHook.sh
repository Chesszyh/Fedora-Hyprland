#!/bin/bash

# /* ---- 💫 Logout Hook for Session Save 💫 ---- */
# This script is called when Hyprland is about to exit

SCRIPTS_DIR="$HOME/.config/hypr/scripts"

# Save session before logout
"$SCRIPTS_DIR/SessionSave.sh" auto

# Optional: Add any other cleanup tasks here
# For example: save current workspace layout, window positions, etc.

exit 0