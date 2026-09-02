#!/usr/bin/env bash
# Wallpaper control for HyprPanel (drives `hyprpanel setWallpaper` -> awww/swww).
#
#   wallpaper.sh            toggle the Quickshell picker (resident -> instant)
#   wallpaper.sh favs       show the picker on the ★ Favourites tab
#   wallpaper.sh next       random image
#   wallpaper.sh prev       step back through history
#
# The picker runs as a hidden resident Quickshell instance (autostarted from
# hyprland.lua); this toggles its visibility over IPC (~30 ms). If it is not
# running yet, it is started once, then shown.
#
# Pool:   $WALLPAPER_DIR or ~/Pictures/wallpapers (or its images/ subdir)
# Thumbs: ~/.cache/wallpaper-thumbs/<md5 of full path>.png  (built in background)
# State:  ~/.cache/wallpaper-history      Favs: ~/.config/hyprpanel/wallpaper-favs
set -o pipefail

dir="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
[ -d "$dir/images" ] && dir="$dir/images"
hist="$HOME/.cache/wallpaper-history"
thumbs="$HOME/.cache/wallpaper-thumbs"
appdir="$HOME/.config/hyprpanel/wallpaper-picker"
mkdir -p "$(dirname "$hist")" "$thumbs" "$HOME/.config/hyprpanel"
touch "$hist" "$HOME/.config/hyprpanel/wallpaper-favs"

imgs() {
  find -L "$dir" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort
}
apply() {
  [ -n "$1" ] && [ -f "$1" ] || { notify-send "Wallpaper" "Not found: ${1:-<none>}"; return 1; }
  hyprpanel setWallpaper "$1" || return 1
  [ "$(tail -n1 "$hist" 2>/dev/null)" = "$1" ] || printf '%s\n' "$1" >> "$hist"
}
build_thumbs() {
  local missing
  missing="$(imgs | while IFS= read -r f; do
    k="$(printf '%s' "$f" | md5sum | cut -c1-32)"
    { [ -f "$thumbs/$k.png" ] && [ ! "$f" -nt "$thumbs/$k.png" ]; } || printf '%s\n' "$f"
  done)"
  [ -z "$missing" ] && return
  notify-send -t 2500 "Wallpaper" "Preparing thumbnails…"
  printf '%s\n' "$missing" | xargs -r -P"$(nproc)" -I{} sh -c '
    k=$(printf "%s" "{}" | md5sum | cut -c1-32)
    magick "{}" -thumbnail 520x293^ -gravity center -extent 520x293 -quality 82 "'"$thumbs"'/$k.png" 2>/dev/null'
}
open_picker() {  # $1: optional "favs"
  local tab="${1:-all}"
  # fast path: the resident instance toggles over IPC in ~30 ms
  qs -p "$appdir" ipc call picker toggle "$tab" 2>/dev/null && return
  # cold: start the resident daemon once, then show
  command -v qs >/dev/null || { notify-send "Wallpaper" "quickshell not installed — yay -S quickshell"; return 1; }
  setsid qs -p "$appdir" -d >/dev/null 2>&1 &
  for _ in $(seq 1 80); do
    qs -p "$appdir" ipc call picker show "$tab" 2>/dev/null && return
    sleep 0.05
  done
}

case "${1:-menu}" in
  next|random)
    apply "$(imgs | shuf -n1)" ;;
  prev|previous)
    [ "$(wc -l < "$hist")" -ge 2 ] || { notify-send "Wallpaper" "No previous wallpaper"; exit 0; }
    sed -i '$d' "$hist"; apply "$(tail -n1 "$hist")" ;;
  menu)
    [ -n "$(imgs)" ] || { notify-send "Wallpaper" "No images in $dir"; exit 0; }
    ( build_thumbs & ) ; open_picker ;;
  favs|fav)
    ( build_thumbs & ) ; open_picker favs ;;
  *)
    echo "usage: wallpaper.sh [menu|favs|next|prev]" >&2; exit 2 ;;
esac
