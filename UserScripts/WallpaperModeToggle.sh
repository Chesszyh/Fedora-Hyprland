#!/bin/bash
# Toggle wallpaper startup mode between static (swww) and live (mpvpaper).

set -euo pipefail

startup_config="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"
iDIR="$HOME/.config/swaync/images"
scriptsDir="$HOME/.config/hypr/scripts"
live_apply_script="$HOME/.config/hypr/UserScripts/WallpaperLiveApply.sh"

toggle_line_by_contains() {
  local needle="$1"
  local mode="$2" # comment|uncomment
  awk -v needle="$needle" -v mode="$mode" '
    {
      line=$0
      if (index(line, needle) > 0) {
        sub(/^[[:space:]]*#[[:space:]]*/, "", line)
        if (mode == "comment") line = "#" line
        print line
        next
      }
      print line
    }
  ' "$startup_config" > "${startup_config}.tmp" && mv "${startup_config}.tmp" "$startup_config"
}

is_live_mode() {
  grep -Eq '^[[:space:]]*exec-once[[:space:]]*=[[:space:]]*\$UserScripts/WallpaperLiveApply\.sh' "$startup_config"
}

if is_live_mode; then
  toggle_line_by_contains 'exec-once = swww-daemon --format xrgb' "uncomment"
  toggle_line_by_contains 'wallpaper_effects/.wallpaper_current' "uncomment"
  toggle_line_by_contains 'exec-once = $UserScripts/WallpaperLiveApply.sh' "comment"

  pkill mpvpaper 2>/dev/null || true
  swww query >/dev/null 2>&1 || swww-daemon --format xrgb &
  sleep 0.2
  wall="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
  [ -f "$wall" ] && swww img "$wall" --transition-type none --transition-duration 0
  "$scriptsDir/WallustSwww.sh" >/dev/null 2>&1 &
  notify-send -i "$iDIR/ja.png" "Wallpaper Mode" "Switched to static wallpaper mode" || true
else
  toggle_line_by_contains 'exec-once = swww-daemon --format xrgb' "comment"
  toggle_line_by_contains 'wallpaper_effects/.wallpaper_current' "comment"
  toggle_line_by_contains 'exec-once = $UserScripts/WallpaperLiveApply.sh' "uncomment"

  # Keep lock-screen/current-wallpaper image updated for live wallpaper mode.
  livewallpaper="$(awk -F'"' '/^\$livewallpaper=/{print $2}' "$startup_config")"
  resolved_video="${livewallpaper/\$HOME/$HOME}"
  if command -v ffmpeg >/dev/null 2>&1 && [ -f "$resolved_video" ]; then
    cache_key=$(printf "%s" "$resolved_video" | md5sum | awk '{print $1}')
    preview_image="$HOME/.cache/video_preview/${cache_key}.png"
    mkdir -p "$HOME/.cache/video_preview"
    ffmpeg -v error -y -i "$resolved_video" -ss 00:00:01.000 -vframes 1 "$preview_image"
    cp -f "$preview_image" "$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
  fi

  "$live_apply_script" || true
  notify-send -i "$iDIR/ja.png" "Wallpaper Mode" "Switched to live wallpaper mode" || true
fi
