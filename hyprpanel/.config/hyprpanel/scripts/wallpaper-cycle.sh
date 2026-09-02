#!/usr/bin/env bash
# Pick a random wallpaper and hand it to HyprPanel (swww transition + config update).
# Usage: wallpaper-cycle.sh [dir]   (default: ~/Pictures/wallpapers)
set -o pipefail
dir="${1:-$HOME/Pictures/wallpapers}"
pick="$(find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | shuf -n1)"
[ -n "$pick" ] || { notify-send "Wallpaper" "No images in $dir"; exit 1; }
hyprpanel setWallpaper "$pick"
