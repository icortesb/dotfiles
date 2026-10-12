#!/usr/bin/env bash
# HyprPanel custom/temp label — CPU (k10temp Tctl) + GPU (amdgpu edge/junction).
# Emits {"text","tooltip"} for the module's {text} / {tooltip} templates.
set -o pipefail

hw() { # hw <chip-name> <temp-label> -> °C (integer) or empty
  local d
  for d in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$d/name" 2>/dev/null)" = "$1" ] || continue
    for l in "$d"/temp*_label; do
      [ "$(cat "$l" 2>/dev/null)" = "$2" ] && { echo $(( $(cat "${l%_label}_input") / 1000 )); return; }
    done
  done
}

cpu="$(hw k10temp Tctl)"
gpu="$(hw amdgpu edge)"
gpuj="$(hw amdgpu junction)"
[ -z "$cpu" ] && { jq -nc '{text:"󰔏  -", tooltip:"k10temp not found"}'; exit 0; }

if   [ "$cpu" -ge 90 ]; then icon="󱃂"
elif [ "$cpu" -ge 80 ]; then icon="󰸁"
else                         icon="󰔏"
fi

tip="CPU: ${cpu}°C"
[ -n "$gpu" ] && tip="$tip
GPU: ${gpu}°C (junction ${gpuj}°C)"

jq -nc --arg t "$icon  ${cpu}°C" --arg tip "$tip" '{text:$t, tooltip:$tip}'
