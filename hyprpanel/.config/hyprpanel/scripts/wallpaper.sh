#!/usr/bin/env bash
# Wallpaper control for HyprPanel (drives `hyprpanel setWallpaper` -> awww/swww).
#
#   wallpaper.sh            open the Quickshell picker (tabs, hover heart/Set)
#   wallpaper.sh favs       open the picker on the ★ Favourites tab
#   wallpaper.sh next       random image
#   wallpaper.sh prev       step back through history
#
# Pool:   $WALLPAPER_DIR or ~/Pictures/wallpapers (or its images/ subdir)
# Thumbs: ~/.cache/wallpaper-thumbs/<md5 of full path>.png  (built on demand)
# State:  ~/.cache/wallpaper-history
# Favs:   ~/.config/hyprpanel/wallpaper-favs  (basenames — synced via dotfiles)
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
  if pgrep -f "qs -p $appdir" >/dev/null 2>&1; then
    pkill -f "qs -p $appdir"; return
  fi
  command -v qs >/dev/null || { notify-send "Wallpaper" "quickshell not installed — yay -S quickshell"; return 1; }
  WP_TAB="${1:-all}" setsid qs -p "$appdir" >/dev/null 2>&1 &
}

case "${1:-menu}" in
  next|random)
    apply "$(imgs | shuf -n1)" ;;
  prev|previous)
    [ "$(wc -l < "$hist")" -ge 2 ] || { notify-send "Wallpaper" "No previous wallpaper"; exit 0; }
    sed -i '$d' "$hist"; apply "$(tail -n1 "$hist")" ;;
  menu)
    [ -n "$(imgs)" ] || { notify-send "Wallpaper" "No images in $dir"; exit 0; }
    build_thumbs; open_picker ;;
  favs|fav)
    build_thumbs; open_picker favs ;;
  *)
    echo "usage: wallpaper.sh [menu|favs|next|prev]" >&2; exit 2 ;;
esac
