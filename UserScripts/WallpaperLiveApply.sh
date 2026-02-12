#!/bin/bash
# Apply live wallpaper using Startup_Apps.conf variables.

set -euo pipefail

startup_config="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"

read_var() {
  local name="$1"
  awk -F'"' -v key="$name" '$1 ~ "^\\$" key "=" {print $2; exit}' "$startup_config"
}

resolve_home_path() {
  local path="$1"
  printf "%s" "${path/\$HOME/$HOME}"
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

livewallpaper="$(resolve_home_path "$(read_var "livewallpaper")")"
livewallpaper_audio="$(resolve_home_path "$(read_var "livewallpaper_audio")")"
livewallpaper_opts="$(read_var "livewallpaper_opts")"
livewallpaper_mute="$(read_var "livewallpaper_mute")"

[ -z "$livewallpaper_opts" ] && livewallpaper_opts="load-scripts=no loop panscan=1.0"
[ -z "$livewallpaper_mute" ] && livewallpaper_mute="no"

if [ -z "$livewallpaper" ] || [ ! -f "$livewallpaper" ]; then
  exit 0
fi

if [ -z "$livewallpaper_audio" ] || [ ! -f "$livewallpaper_audio" ]; then
  livewallpaper_audio="$(detect_sidecar_audio "$livewallpaper" || true)"
fi

opts="$livewallpaper_opts mute=$livewallpaper_mute"
if [ -n "$livewallpaper_audio" ] && [ -f "$livewallpaper_audio" ]; then
  escaped_audio="${livewallpaper_audio//\'/\'\\\'\'}"
  opts="$opts audio-file='${escaped_audio}' audio-file-auto=no"
fi

swww kill 2>/dev/null || true
pkill mpvpaper 2>/dev/null || true
mpvpaper '*' -o "$opts" "$livewallpaper" &
