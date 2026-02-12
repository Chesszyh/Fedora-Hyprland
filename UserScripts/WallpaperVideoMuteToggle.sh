#!/bin/bash
# Toggle video wallpaper mute state and persist it in Startup_Apps.conf.

set -euo pipefail

startup_config="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"
iDIR="$HOME/.config/swaync/images"

read_var() {
  local var_name="$1"
  awk -F'"' -v key="$var_name" '$1 ~ "^\\$" key "=" {print $2; exit}' "$startup_config"
}

set_var() {
  local var_name="$1"
  local var_value="$2"
  awk -v key="$var_name" -v val="$var_value" '
    BEGIN { done=0 }
    $0 ~ "^\\$" key "=" {
      print "$" key "=\"" val "\""
      done=1
      next
    }
    { print }
    END {
      if (!done) print "$" key "=\"" val "\""
    }
  ' "$startup_config" > "${startup_config}.tmp" && mv "${startup_config}.tmp" "$startup_config"
}

livewallpaper_mute="$(read_var "livewallpaper_mute")"
[ -z "$livewallpaper_mute" ] && livewallpaper_mute="no"

if [[ "$livewallpaper_mute" == "yes" ]]; then
  livewallpaper_mute="no"
  notify_msg="Video wallpaper unmuted"
else
  livewallpaper_mute="yes"
  notify_msg="Video wallpaper muted"
fi

set_var "livewallpaper_mute" "$livewallpaper_mute"

# If currently in live wallpaper mode, restart mpvpaper immediately.
if grep -Eq '^[[:space:]]*exec-once[[:space:]]*=[[:space:]]*\$UserScripts/WallpaperLiveApply\.sh' "$startup_config"; then
  "$HOME/.config/hypr/UserScripts/WallpaperLiveApply.sh" || true
fi

notify-send -i "$iDIR/ja.png" "Wallpaper Audio" "$notify_msg" || true
