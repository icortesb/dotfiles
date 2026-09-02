#!/usr/bin/env bash
# Wallpaper control for HyprPanel (drives `hyprpanel setWallpaper` -> awww/swww).
#
#   wallpaper.sh            open the AGS thumbnail picker (tabs, hover heart/Set)
#   wallpaper.sh favs       open the picker on the ★ Favourites tab
#   wallpaper.sh next       random image
#   wallpaper.sh prev       step back through history
#
# Pool:  $WALLPAPER_DIR or ~/Pictures/wallpapers (or its images/ subdir)
# State: ~/.cache/wallpaper-history   ~/.cache/wallpaper-thumbs/
# Favs:  ~/.config/hyprpanel/wallpaper-favs  (basenames — synced via dotfiles)
set -o pipefail

dir="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
[ -d "$dir/images" ] && dir="$dir/images"
hist="$HOME/.cache/wallpaper-history"
thumbs="$HOME/.cache/wallpaper-thumbs"
favs="$HOME/.config/hyprpanel/wallpaper-favs"
mkdir -p "$(dirname "$hist")" "$thumbs" "$(dirname "$favs")"
touch "$hist" "$favs"

imgs()    { find -L "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort; }
resolve() { imgs | grep -F "/$1" | head -n1; }

apply() {
  [ -n "$1" ] && [ -f "$1" ] || { notify-send "Wallpaper" "Not found: ${1:-<none>}"; return 1; }
  hyprpanel setWallpaper "$1" || return 1
  [ "$(tail -n1 "$hist" 2>/dev/null)" = "$1" ] || printf '%s\n' "$1" >> "$hist"
}

is_fav() { grep -qxF "$(basename "$1")" "$favs"; }
toggle_fav() {
  local b; b="$(basename "$1")"
  if grep -qxF "$b" "$favs"; then grep -vxF "$b" "$favs" > "$favs.t" && mv "$favs.t" "$favs"
  else printf '%s\n' "$b" >> "$favs"; fi
}

thumb() {
  local src="$1" key t
  key="$(printf '%s' "$src" | sha1sum | cut -c1-16)"; t="$thumbs/$key.png"
  if [ ! -f "$t" ] || [ "$src" -nt "$t" ]; then
    magick "$src" -thumbnail '400x225^' -gravity center -extent 400x225 "$t" 2>/dev/null
  fi
  printf '%s' "$t"
}
build_thumbs() {
  local missing
  missing="$(imgs | while IFS= read -r f; do
    k="$(printf '%s' "$f" | sha1sum | cut -c1-16)"
    { [ -f "$thumbs/$k.png" ] && [ -f "$thumbs/${k}_b.png" ] && [ ! "$f" -nt "$thumbs/$k.png" ]; } || printf '%s\n' "$f"
  done)"
  [ -z "$missing" ] && return
  notify-send -t 2000 "Wallpaper" "Building thumbnails"
  printf '%s\n' "$missing" | xargs -P"$(nproc)" -I{} sh -c '
    k=$(printf "%s" "{}" | sha1sum | cut -c1-16)
    magick "{}" -thumbnail "400x225^" -gravity center -extent 400x225 "'"$thumbs"'/$k.png" 2>/dev/null
    magick "'"$thumbs"'/$k.png" -blur 0x12 "'"$thumbs"'/${k}_b.png" 2>/dev/null'
}

APPDIR="$HOME/.config/hyprpanel/wallpaper-picker"
open_picker() {  # $1: optional "favs"
  if ags list 2>/dev/null | grep -qx wallpaper-picker; then
    ags quit -i wallpaper-picker
  else
    setsid ags run -d "$APPDIR" ${1:+-- "$1"} >/dev/null 2>&1 &
  fi
}

command -v ags >/dev/null || { notify-send "Wallpaper" "ags (HyprPanel) not installed"; exit 1; }

case "${1:-menu}" in
  next|random)  apply "$(imgs | shuf -n1)" ;;
  prev|previous)
    [ "$(wc -l < "$hist")" -ge 2 ] || { notify-send "Wallpaper" "No previous wallpaper"; exit 0; }
    sed -i '$d' "$hist"; apply "$(tail -n1 "$hist")" ;;
  menu)  [ -n "$(imgs)" ] || { notify-send "Wallpaper" "No images in $dir"; exit 0; }; build_thumbs; open_picker ;;
  favs|fav)  build_thumbs; open_picker favs ;;
  *)  echo "usage: wallpaper.sh [menu|favs|next|prev]" >&2; exit 2 ;;
esac
