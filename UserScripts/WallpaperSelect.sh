#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# This script for selecting wallpapers (SUPER W)

# WALLPAPERS PATH
terminal=kitty
wallDIR="$HOME/Pictures/wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
wallpaper_current="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
startup_config="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"

# Directory for swaync
iDIR="$HOME/.config/swaync/images"
iDIRi="$HOME/.config/swaync/icons"

# swww transition config
FPS=60
TYPE="any"
DURATION=2
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

# Check if package bc exists
if ! command -v bc &>/dev/null; then
  notify-send -i "$iDIR/error.png" "bc missing" "Install package bc first"
  exit 1
fi

# Variables
rofi_theme="$HOME/.config/rofi/config-wallpaper.rasi"
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Ensure focused_monitor is detected
if [[ -z "$focused_monitor" ]]; then
  notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Could not detect focused monitor"
  exit 1
fi

# Monitor details
scale_factor=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .scale')
monitor_height=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .height')

icon_size=$(echo "scale=1; ($monitor_height * 3) / ($scale_factor * 150)" | bc)
adjusted_icon_size=$(echo "$icon_size" | awk '{if ($1 < 15) $1 = 20; if ($1 > 25) $1 = 25; print $1}')
rofi_override="element-icon{size:${adjusted_icon_size}%;}"

# Kill existing wallpaper daemons for video
kill_wallpaper_for_video() {
  swww kill 2>/dev/null
  pkill mpvpaper 2>/dev/null
  pkill swaybg 2>/dev/null
  pkill hyprpaper 2>/dev/null
}

# Kill existing wallpaper daemons for image
kill_wallpaper_for_image() {
  pkill mpvpaper 2>/dev/null
  pkill swaybg 2>/dev/null
  pkill hyprpaper 2>/dev/null
}

# Retrieve wallpapers (both images & videos)
mapfile -d '' PICS < <(find -L "${wallDIR}" -type f \( \
  -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
  -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" -o \
  -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.webm" \) -print0)

RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME=". random"

# Rofi command
rofi_command="rofi -i -show -dmenu -config $rofi_theme -theme-str $rofi_override"

# Helper
is_video_file() {
  [[ "${1,,}" =~ \.(mp4|mkv|mov|webm)$ ]]
}

read_startup_var() {
  local var_name="$1"
  awk -F'"' -v key="$var_name" '$1 ~ "^\\$" key "=" {print $2; exit}' "$startup_config"
}

set_startup_var() {
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

detect_sidecar_audio() {
  local video_path="$1"
  local base="${video_path%.*}"
  local ext
  for ext in mp3 m4a wav flac ogg opus aac; do
    if [ -f "${base}.${ext}" ]; then
      printf "%s" "${base}.${ext}"
      return 0
    fi
  done
  return 1
}

save_video_preview_as_current() {
  local video_path="$1"
  local cache_key preview_image
  cache_key=$(printf "%s" "$video_path" | md5sum | awk '{print $1}')
  preview_image="$HOME/.cache/video_preview/${cache_key}.png"

  mkdir -p "$HOME/.cache/video_preview"
  if [[ ! -f "$preview_image" ]]; then
    ffmpeg -v error -y -i "$video_path" -ss 00:00:01.000 -vframes 1 "$preview_image"
  fi
  cp -f "$preview_image" "$wallpaper_current"
}

video_transition_effect() {
  local video_path="$1"
  local cache_key preview_image
  cache_key=$(printf "%s" "$video_path" | md5sum | awk '{print $1}')
  preview_image="$HOME/.cache/video_preview/${cache_key}.png"

  mkdir -p "$HOME/.cache/video_preview"
  if [[ ! -f "$preview_image" ]]; then
    ffmpeg -v error -y -i "$video_path" -ss 00:00:01.000 -vframes 1 "$preview_image"
  fi

  swww query >/dev/null 2>&1 || swww-daemon --format xrgb &
  sleep 0.2
  swww img -o "$focused_monitor" "$preview_image" $SWWW_PARAMS >/dev/null 2>&1 || true
}

# Sorting Wallpapers
menu() {
  IFS=$'\n' sorted_options=($(sort <<<"${PICS[*]}"))

  printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_PIC"

  for pic_path in "${sorted_options[@]}"; do
    pic_name=$(basename "$pic_path")
    display_name="${pic_path#$wallDIR/}"
    cache_key=$(printf "%s" "$pic_path" | md5sum | awk '{print $1}')

    if [[ "${pic_name,,}" =~ \.gif$ ]]; then
      cache_gif_image="$HOME/.cache/gif_preview/${cache_key}.png"
      if [[ ! -f "$cache_gif_image" ]]; then
        mkdir -p "$HOME/.cache/gif_preview"
        magick "$pic_path[0]" -resize 1920x1080 "$cache_gif_image"
      fi
      printf "%s\x00icon\x1f%s\n" "$display_name" "$cache_gif_image"
    elif is_video_file "$pic_name"; then
      cache_preview_image="$HOME/.cache/video_preview/${cache_key}.png"
      if [[ ! -f "$cache_preview_image" ]]; then
        mkdir -p "$HOME/.cache/video_preview"
        ffmpeg -v error -y -i "$pic_path" -ss 00:00:01.000 -vframes 1 "$cache_preview_image"
      fi
      printf "%s\x00icon\x1f%s\n" "$display_name" "$cache_preview_image"
    else
      printf "%s\x00icon\x1f%s\n" "$display_name" "$pic_path"
    fi
  done
}

# Offer SDDM Simple Wallpaper Option (only for non-video wallpapers)
set_sddm_wallpaper() {
  sleep 1
  sddm_simple="/usr/share/sddm/themes/simple_sddm_2"

  if [ -d "$sddm_simple" ]; then

    # Check if yad is running to avoid multiple notifications
    if pidof yad >/dev/null; then
      killall yad
    fi

    if yad --info --text="Set current wallpaper as SDDM background?\n\nNOTE: This only applies to SIMPLE SDDM v2 Theme" \
      --text-align=left \
      --title="SDDM Background" \
      --timeout=5 \
      --timeout-indicator=right \
      --button="yes:0" \
      --button="no:1"; then

      # Check if terminal exists
      if ! command -v "$terminal" &>/dev/null; then
        notify-send -i "$iDIR/error.png" "Missing $terminal" "Install $terminal to enable setting of wallpaper background"
        exit 1
      fi
	  
	  exec $SCRIPTSDIR/sddm_wallpaper.sh --normal
    
    fi
  fi
}

modify_startup_config() {
  local selected_file="$1"

  # Check if it's a live wallpaper (video)
  if is_video_file "$selected_file"; then
    # For video wallpapers:
    sed -i -E '/^[[:space:]]*#?[[:space:]]*exec-once[[:space:]]*=[[:space:]]*swww-daemon[[:space:]]*--format[[:space:]]*xrgb[[:space:]]*$/s/^[[:space:]]*#?[[:space:]]*/#/' "$startup_config"
    sed -i -E '/^[[:space:]]*#?[[:space:]]*exec-once[[:space:]]*=[[:space:]]*bash -lc .*swww img.*wallpaper_effects\/\.wallpaper_current.*/s/^[[:space:]]*#?[[:space:]]*/#/' "$startup_config"
    sed -i -E '/^[[:space:]]*#?[[:space:]]*exec-once[[:space:]]*=[[:space:]]*\$UserScripts\/WallpaperLiveApply\.sh/s/^[[:space:]]*#?[[:space:]]*//' "$startup_config"

    # Update live wallpaper path and sidecar audio path (if found)
    selected_file="${selected_file/#$HOME/\$HOME}" # Replace /home/user with $HOME
    set_startup_var "livewallpaper" "$selected_file"
    local selected_audio
    selected_audio="$(detect_sidecar_audio "${selected_file/\$HOME/$HOME}" || true)"
    if [ -n "$selected_audio" ]; then
      selected_audio="${selected_audio/#$HOME/\$HOME}"
    fi
    set_startup_var "livewallpaper_audio" "$selected_audio"

    echo "Configured for live wallpaper (video)."
  else
    # For image wallpapers:
    sed -i -E '/^[[:space:]]*#?[[:space:]]*exec-once[[:space:]]*=[[:space:]]*swww-daemon[[:space:]]*--format[[:space:]]*xrgb[[:space:]]*$/s/^[[:space:]]*#?[[:space:]]*//' "$startup_config"
    sed -i -E '/^[[:space:]]*#?[[:space:]]*exec-once[[:space:]]*=[[:space:]]*bash -lc .*swww img.*wallpaper_effects\/\.wallpaper_current.*/s/^[[:space:]]*#?[[:space:]]*//' "$startup_config"
    sed -i -E '/^[[:space:]]*#?[[:space:]]*exec-once[[:space:]]*=[[:space:]]*\$UserScripts\/WallpaperLiveApply\.sh/s/^[[:space:]]*#?[[:space:]]*/#/' "$startup_config"

    echo "Configured for static wallpaper (image)."
  fi
}

# Apply Image Wallpaper
apply_image_wallpaper() {
  local image_path="$1"

  kill_wallpaper_for_image

  if ! pgrep -x "swww-daemon" >/dev/null; then
    echo "Starting swww-daemon..."
    swww-daemon --format xrgb &
  fi

  swww img -o "$focused_monitor" "$image_path" $SWWW_PARAMS
  cp -f "$image_path" "$wallpaper_current"

  # Run additional scripts
  "$SCRIPTSDIR/WallustSwww.sh"
  sleep 2
  "$SCRIPTSDIR/Refresh.sh"
  sleep 1

  set_sddm_wallpaper
}

apply_video_wallpaper() {
  local video_path="$1"

  # Check if mpvpaper is installed
  if ! command -v mpvpaper &>/dev/null; then
    notify-send -i "$iDIR/error.png" "E-R-R-O-R" "mpvpaper not found"
    return 1
  fi
  video_transition_effect "$video_path"
  save_video_preview_as_current "$video_path"

  pkill mpvpaper 2>/dev/null
  pkill swaybg 2>/dev/null
  pkill hyprpaper 2>/dev/null
  sleep 0.2
  swww kill 2>/dev/null

  # Apply video wallpaper using mpvpaper
  "$HOME/.config/hypr/UserScripts/WallpaperLiveApply.sh"
}

# Main function
main() {
  choice=$(menu | $rofi_command)
  choice=$(echo "$choice" | xargs)
  RANDOM_PIC_NAME=$(echo "$RANDOM_PIC_NAME" | xargs)

  if [[ -z "$choice" ]]; then
    echo "No choice selected. Exiting."
    exit 0
  fi

  if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
    selected_file="$RANDOM_PIC"
  else
    selected_file="$wallDIR/$choice"
  fi

  if [[ -z "$selected_file" ]]; then
    echo "File not found. Selected choice: $choice"
    exit 1
  fi

  # Modify the Startup_Apps.conf file based on wallpaper type
  modify_startup_config "$selected_file"

  # **CHECK FIRST** if it's a video or an image **before calling any function**
  if is_video_file "$selected_file"; then
    apply_video_wallpaper "$selected_file"
  else
    apply_image_wallpaper "$selected_file"
  fi
}

# Check if rofi is already running
if pidof rofi >/dev/null; then
  pkill rofi
fi

main
