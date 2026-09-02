#!/bin/sh
# Renders the machine-specific HyprPanel config from the tracked templates.
# Runs from hyprland.lua autostart, before `hyprpanel` starts.
#
#   config.base.json   -> config.json   (+ wallpaper path, + battery module if a laptop)
#   modules.base.json  -> modules.json  ($HOME expanded to an absolute path)
#
# config.json / modules.json are git-ignored: edit the *.base.json files, not these.
set -e

d="${XDG_CONFIG_HOME:-$HOME/.config}/hyprpanel"
img="$HOME/walls/wall1.png"

# --- config.json -----------------------------------------------------------
filter='.["wallpaper.image"] = $img'
if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
  # real system battery present (laptop) -> insert the "battery" bar module
  # just before "clock" in every monitor layout
  filter="$filter"' | (.["bar.layouts"][].right) |= (
      if index("battery") then .
      else ( .[:(index("clock") // length)] + ["battery"] + .[(index("clock") // length):] )
      end)'
fi
jq --arg img "$img" "$filter" "$d/config.base.json" > "$d/config.json.tmp"
mv "$d/config.json.tmp" "$d/config.json"

# --- modules.json (custom bar modules) -----------------------------------
if [ -f "$d/modules.base.json" ]; then
  sed "s#\$HOME#$HOME#g" "$d/modules.base.json" > "$d/modules.json.tmp"
  mv "$d/modules.json.tmp" "$d/modules.json"
fi

# --- seed HyprPanel's "current wallpaper" copy so its swww call succeeds --
# (HyprPanel does `swww img ~/.config/background`; the picker overwrites it later)
[ -f "$HOME/.config/background" ] || cp -f "$img" "$HOME/.config/background" 2>/dev/null || true
