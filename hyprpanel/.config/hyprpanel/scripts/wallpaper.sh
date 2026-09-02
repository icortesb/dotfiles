#!/usr/bin/env bash
# Wallpaper control for HyprPanel (drives `hyprpanel setWallpaper` -> awww/swww).
#
#   wallpaper.sh            rofi thumbnail grid.
#                             top row toggles APPLY <-> STAR mode
#                             APPLY: Enter sets the wallpaper
#                             STAR : Enter toggles the ★ favourite, grid stays open
#                             "★ favourites only" row -> favourites grid
#   wallpaper.sh favs       rofi grid of ★ favourites only
#   wallpaper.sh next       random image
#   wallpaper.sh prev       step back through history
#
# Pool:   $WALLPAPER_DIR or ~/Pictures/wallpapers (or its images/ subdir)
# State:  ~/.cache/wallpaper-history   ~/.cache/wallpaper-thumbs/   $XDG_RUNTIME_DIR/wallpaper-mode
# Favs:   ~/.config/hyprpanel/wallpaper-favs  (basenames — synced via dotfiles)
set -o pipefail

dir="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
[ -d "$dir/images" ] && dir="$dir/images"
hist="$HOME/.cache/wallpaper-history"
thumbs="$HOME/.cache/wallpaper-thumbs"
favs="$HOME/.config/hyprpanel/wallpaper-favs"
modef="${XDG_RUNTIME_DIR:-/tmp}/wallpaper-mode"
mkdir -p "$(dirname "$hist")" "$thumbs" "$(dirname "$favs")"
touch "$hist" "$favs"

imgs() {
  find -L "$dir" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort
}
resolve() { imgs | grep -F "/$1" | head -n1; }              # basename -> abs path

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
  notify-send -t 2000 "Wallpaper" "Building thumbnails…"
  printf '%s\n' "$missing" | xargs -P"$(nproc)" -I{} sh -c '
    k=$(printf "%s" "{}" | sha1sum | cut -c1-16)
    magick "{}" -thumbnail "400x225^" -gravity center -extent 400x225 "'"$thumbs"'/$k.png" 2>/dev/null'
}

# rofi grid. reads abs paths on stdin, prints the chosen row (icon feed is piped
# straight through so no NUL ever passes through a shell variable).
grid() {
  local prompt="$1" mesg="$2"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    case "$f" in
      ":: "*) printf '%s\n' "${f#:: }"; continue ;;   # literal menu row, no icon
    esac
    local name; name="$(basename "$f")"
    is_fav "$f" && name="★ $name"
    printf '%s\0icon\x1f%s\n' "$name" "$(thumb "$f")"
  done | rofi -dmenu -i -p "$prompt" ${mesg:+-mesg "$mesg"} -theme-str '
    configuration { show-icons: true; }
    window   { width: 72%; }
    listview { columns: 4; lines: 3; spacing: 10px; }
    element  { orientation: vertical; padding: 6px; border-radius: 8px; }
    element-icon { size: 13em; }
    element-text { horizontal-align: 0.5; }'
}

command -v rofi >/dev/null || { notify-send "Wallpaper" "rofi not installed — pacman -S rofi"; [ "${1:-menu}" = menu ] && exit 1; }

case "${1:-menu}" in
  next|random) apply "$(imgs | shuf -n1)" ;;

  prev|previous)
    [ "$(wc -l < "$hist")" -ge 2 ] || { notify-send "Wallpaper" "No previous wallpaper"; exit 0; }
    sed -i '$d' "$hist"; apply "$(tail -n1 "$hist")" ;;

  menu)
    [ -n "$(imgs)" ] || { notify-send "Wallpaper" "No images in $dir"; exit 0; }
    build_thumbs
    mode="$(cat "$modef" 2>/dev/null)"; [ "$mode" = star ] || mode=apply
    if [ "$mode" = star ]; then
      other="apply"; msg="★ STAR mode — Enter toggles a favourite. Top row → back to apply."
    else
      other="star";  msg="APPLY mode — Enter sets the wallpaper. Top row → ★ star favourites."
    fi
    sel="$( { printf ':: ⟲  Switch to %s mode\n:: ★  Favourites only\n' "$other"; imgs; } | grid wallpaper "$msg" )" || exit 0
    case "$sel" in
      *"Switch to"*) printf '%s' "$other" > "$modef"; exec "$0" menu ;;
      *"Favourites only"*) exec "$0" favs ;;
      "") exit 0 ;;
      *)
        p="$(resolve "${sel#★ }")"; [ -n "$p" ] || exit 0
        if [ "$mode" = star ]; then toggle_fav "$p"; exec "$0" menu; else apply "$p"; fi ;;
    esac ;;

  favs|fav)
    list="$(while IFS= read -r b; do resolve "$b"; done < "$favs")"
    [ -n "$list" ] || { notify-send "Wallpaper" "No favourites yet — use STAR mode in the picker"; exit 0; }
    sel="$( { printf ':: ⟲  All wallpapers\n'; printf '%s\n' "$list"; } | grid favourites "★ favourites — Enter applies. Top row → all wallpapers." )" || exit 0
    case "$sel" in
      *"All wallpapers"*) exec "$0" menu ;;
      "") exit 0 ;;
      *) apply "$(resolve "${sel#★ }")" ;;
    esac ;;

  *) echo "usage: wallpaper.sh [menu|favs|next|prev]" >&2; exit 2 ;;
esac
