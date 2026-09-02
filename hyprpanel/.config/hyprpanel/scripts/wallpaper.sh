#!/usr/bin/env bash
# Wallpaper control for HyprPanel (drives `hyprpanel setWallpaper` -> awww/swww).
#
#   wallpaper.sh            rofi thumbnail grid of every wallpaper
#                             Enter  apply      Alt+f  toggle ★ favourite      Alt+r  random
#   wallpaper.sh favs       rofi grid of ★ favourites only
#   wallpaper.sh next       random image
#   wallpaper.sh prev       step back through history
#
# Pool:   $WALLPAPER_DIR or ~/Pictures/wallpapers
# State:  ~/.cache/wallpaper-history     ~/.cache/wallpaper-thumbs/
# Favs:   ~/.config/hyprpanel/wallpaper-favs  (basenames, one per line — synced via dotfiles)
set -o pipefail

dir="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
# many wallpaper repos keep the images in an images/ subdir
[ -d "$dir/images" ] && dir="$dir/images"
hist="$HOME/.cache/wallpaper-history"
thumbs="$HOME/.cache/wallpaper-thumbs"
favs="$HOME/.config/hyprpanel/wallpaper-favs"
mkdir -p "$(dirname "$hist")" "$thumbs" "$(dirname "$favs")"
touch "$hist" "$favs"

imgs() {
  find -L "$dir" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort
}

apply() {
  [ -n "$1" ] && [ -f "$1" ] || { notify-send "Wallpaper" "Not found: ${1:-<none>}"; return 1; }
  hyprpanel setWallpaper "$1" || return 1
  [ "$(tail -n1 "$hist" 2>/dev/null)" = "$1" ] || printf '%s\n' "$1" >> "$hist"
}

is_fav()  { grep -qxF "$(basename "$1")" "$favs"; }
toggle_fav() {
  local b; b="$(basename "$1")"
  if grep -qxF "$b" "$favs"; then grep -vxF "$b" "$favs" > "$favs.t" && mv "$favs.t" "$favs"
  else printf '%s\n' "$b" >> "$favs"; fi
}

thumb() { # echo cached thumbnail path, building it if stale
  local src="$1" key t
  key="$(printf '%s' "$src" | sha1sum | cut -c1-16)"
  t="$thumbs/$key.png"
  if [ ! -f "$t" ] || [ "$src" -nt "$t" ]; then
    magick "$src" -thumbnail '400x225^' -gravity center -extent 400x225 "$t" 2>/dev/null
  fi
  printf '%s' "$t"
}

build_thumbs() { # parallel pre-gen for anything missing
  local missing; missing="$(imgs | while read -r f; do
    k="$(printf '%s' "$f" | sha1sum | cut -c1-16)"
    { [ -f "$thumbs/$k.png" ] && [ ! "$f" -nt "$thumbs/$k.png" ]; } || printf '%s\n' "$f"
  done)"
  [ -z "$missing" ] && return
  notify-send -t 2000 "Wallpaper" "Building thumbnails…"
  printf '%s\n' "$missing" | xargs -P"$(nproc)" -I{} sh -c '
    k=$(printf "%s" "{}" | sha1sum | cut -c1-16)
    magick "{}" -thumbnail "400x225^" -gravity center -extent 400x225 "'"$thumbs"'/$k.png" 2>/dev/null'
}

rofi_grid() { # $1 = newline list of abs paths; echoes: <exitcode>\n<selected basename>
  local list="$1" feed
  feed="$(printf '%s\n' "$list" | while read -r f; do
    [ -n "$f" ] || continue
    local name; name="$(basename "$f")"
    is_fav "$f" && name="★ $name"
    printf '%s\0icon\x1f%s\n' "$name" "$(thumb "$f")"
  done)"
  local sel rc
  sel="$(printf '%s' "$feed" | rofi -dmenu -i -p wallpaper \
      -kb-custom-1 'Alt+f' -kb-custom-2 'Alt+r' \
      -theme-str '
        configuration { show-icons: true; }
        window   { width: 70%; }
        listview { columns: 4; lines: 3; spacing: 10px; }
        element  { orientation: vertical; padding: 6px; border-radius: 8px; }
        element-icon { size: 13em; }
        element-text { horizontal-align: 0.5; }
      ')"
  rc=$?
  printf '%s\n%s' "$rc" "${sel#★ }"
}

resolve() { imgs | grep -F "/$1" | head -n1; }   # basename -> abs path

case "${1:-menu}" in
  next|random) apply "$(imgs | shuf -n1)" ;;

  prev|previous)
    [ "$(wc -l < "$hist")" -ge 2 ] || { notify-send "Wallpaper" "No previous wallpaper"; exit 0; }
    sed -i '$d' "$hist"; apply "$(tail -n1 "$hist")" ;;

  favs|fav)
    command -v rofi >/dev/null || { notify-send "Wallpaper" "rofi not installed"; exit 1; }
    list="$(while read -r b; do resolve "$b"; done < "$favs")"
    [ -n "$list" ] || { notify-send "Wallpaper" "No favourites yet (Alt+f in the picker)"; exit 0; }
    out="$(rofi_grid "$list")"
    rc="$(printf '%s' "$out" | head -n1)"; pick="$(printf '%s' "$out" | tail -n +2)"
    case "$rc" in
      0)  [ -n "$pick" ] && apply "$(resolve "$pick")" ;;
      10) [ -n "$pick" ] && toggle_fav "$(resolve "$pick")"; exec "$0" favs ;;
      11) apply "$(imgs | shuf -n1)" ;;
    esac ;;

  menu)
    command -v rofi >/dev/null || { notify-send "Wallpaper" "rofi not installed — pacman -S rofi"; exit 1; }
    [ -n "$(imgs)" ] || { notify-send "Wallpaper" "No images in $dir"; exit 0; }
    build_thumbs
    out="$(rofi_grid "$(imgs)")"
    rc="$(printf '%s' "$out" | head -n1)"; pick="$(printf '%s' "$out" | tail -n +2)"
    case "$rc" in
      0)  [ -n "$pick" ] && apply "$(resolve "$pick")" ;;
      10) [ -n "$pick" ] && toggle_fav "$(resolve "$pick")"; exec "$0" menu ;;
      11) apply "$(imgs | shuf -n1)" ;;
    esac ;;

  *) echo "usage: wallpaper.sh [menu|favs|next|prev]" >&2; exit 2 ;;
esac
