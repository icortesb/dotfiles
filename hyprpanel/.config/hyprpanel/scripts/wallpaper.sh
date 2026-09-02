#!/usr/bin/env bash
# Wallpaper control for HyprPanel (drives `hyprpanel setWallpaper` -> awww/swww).
#
#   wallpaper.sh              picker: walker dmenu with Random / Previous + every image
#   wallpaper.sh next         random image
#   wallpaper.sh prev         step back through history
#
# Pool: $WALLPAPER_DIR or ~/Pictures/wallpapers. History: ~/.cache/wallpaper-history
set -o pipefail

dir="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
hist="$HOME/.cache/wallpaper-history"
mkdir -p "$(dirname "$hist")"; touch "$hist"

imgs() {
  find -L "$dir" -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort
}

apply() {
  [ -n "$1" ] && [ -f "$1" ] || { notify-send "Wallpaper" "Not found: ${1:-<none>}"; return 1; }
  hyprpanel setWallpaper "$1" || return 1
  [ "$(tail -n1 "$hist" 2>/dev/null)" = "$1" ] || printf '%s\n' "$1" >> "$hist"
}

case "${1:-menu}" in
  next|random)
    apply "$(imgs | shuf -n1)"
    ;;
  prev|previous)
    # drop current, apply the one before it
    lines=$(wc -l < "$hist")
    [ "${lines:-0}" -ge 2 ] || { notify-send "Wallpaper" "No previous wallpaper"; exit 0; }
    sed -i '$d' "$hist"
    apply "$(tail -n1 "$hist")"
    ;;
  menu)
    sel="$(
      { printf '~ Random ~\n~ Previous ~\n'
        imgs | sed "s|^$dir/||"
      } | walker --dmenu --placeholder 'Wallpaper…'
    )" || exit 0
    case "$sel" in
      "~ Random ~")   exec "$0" next ;;
      "~ Previous ~") exec "$0" prev ;;
      "")             exit 0 ;;
      *)              apply "$dir/$sel" ;;
    esac
    ;;
  *)
    echo "usage: wallpaper.sh [menu|next|prev]" >&2; exit 2 ;;
esac
