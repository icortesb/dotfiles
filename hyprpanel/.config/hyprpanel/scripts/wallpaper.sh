#!/usr/bin/env bash
# Wallpaper control for HyprPanel (drives `hyprpanel setWallpaper` -> awww/swww).
#
#   wallpaper.sh            rofi thumbnail grid (images only, Nord theme)
#                             Enter  set wallpaper
#                             Alt+1  toggle the ★ favourite on the highlighted image
#                             Alt+2  toggle "favourites only" view
#   wallpaper.sh favs       open the grid filtered to ★ favourites
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
theme="$HOME/.config/hyprpanel/wallpaper.rasi"
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
    { [ -f "$thumbs/$k.png" ] && [ ! "$f" -nt "$thumbs/$k.png" ]; } || printf '%s\n' "$f"
  done)"
  [ -z "$missing" ] && return
  notify-send -t 2000 "Wallpaper" "Building thumbnails"
  printf '%s\n' "$missing" | xargs -P"$(nproc)" -I{} sh -c '
    k=$(printf "%s" "{}" | sha1sum | cut -c1-16)
    magick "{}" -thumbnail "400x225^" -gravity center -extent 400x225 "'"$thumbs"'/$k.png" 2>/dev/null'
}

# grid <all|favs> — recursion handles favourite-toggle and view-toggle.
grid() {
  local view="$1" list sel rc pick
  if [ "$view" = favs ]; then
    list="$(while IFS= read -r b; do resolve "$b"; done < "$favs")"
    [ -n "$list" ] || { notify-send "Wallpaper" "No favourites yet — Alt+1 in the picker"; return 0; }
  else
    list="$(imgs)"
  fi

  local m2; [ "$view" = favs ] && m2="all wallpapers" || m2="favourites only"
  sel="$(
    printf '%s\n' "$list" | while IFS= read -r f; do
      [ -n "$f" ] || continue
      n="$(basename "$f")"; is_fav "$f" && n="★ $n"
      printf '%s\0icon\x1f%s\n' "$n" "$(thumb "$f")"
    done | rofi -dmenu -i -p wallpaper -theme "$theme" \
        -mesg "Enter set   ·   Alt+1 toggle ★   ·   Alt+2 $m2"
  )"
  rc=$?
  pick="$(resolve "${sel#★ }")"

  case "$rc" in
    0)  [ -n "$pick" ] && apply "$pick" ;;
    10) [ -n "$pick" ] && toggle_fav "$pick"; grid "$view" ;;        # Alt+1
    11) [ "$view" = favs ] && grid all || grid favs ;;               # Alt+2
  esac
}

command -v rofi >/dev/null || { notify-send "Wallpaper" "rofi not installed — pacman -S rofi"; [ "${1:-menu}" = menu ] || [ "${1:-}" = favs ] && exit 1; }

case "${1:-menu}" in
  next|random)  apply "$(imgs | shuf -n1)" ;;
  prev|previous)
    [ "$(wc -l < "$hist")" -ge 2 ] || { notify-send "Wallpaper" "No previous wallpaper"; exit 0; }
    sed -i '$d' "$hist"; apply "$(tail -n1 "$hist")" ;;
  menu)  [ -n "$(imgs)" ] || { notify-send "Wallpaper" "No images in $dir"; exit 0; }; build_thumbs; grid all ;;
  favs|fav)  grid favs ;;
  *)  echo "usage: wallpaper.sh [menu|favs|next|prev]" >&2; exit 2 ;;
esac
