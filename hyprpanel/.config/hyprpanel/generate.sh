#!/bin/sh
# Regenerates ~/.config/hyprpanel/config.json from config.base.json.
# - injects the absolute wallpaper path for this machine
# - adds the "battery" bar module only when a real system battery (BAT*) is present,
#   so the same dotfiles give a battery readout on a laptop and hide it on a desktop.
set -e
d="${XDG_CONFIG_HOME:-$HOME/.config}/hyprpanel"
base="$d/config.base.json"
out="$d/config.json"
img="$HOME/walls/wall1.png"

filter='.["wallpaper.image"] = $img'
if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
  filter="$filter"' | (.["bar.layouts"][].right) |= (
      if index("battery") then .
      else ( .[:(index("clock") // length)] + ["battery"] + .[(index("clock") // length):] )
      end)'
fi

jq --arg img "$img" "$filter" "$base" > "$out.tmp" && mv "$out.tmp" "$out"
