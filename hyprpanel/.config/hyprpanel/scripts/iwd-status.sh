#!/usr/bin/env bash
# HyprPanel custom/iwd label — Wi-Fi status via iwd (no NetworkManager).
# Emits {"text","tooltip"} for the module's {text} / {tooltip} templates.
set -o pipefail

dev=""
for d in /sys/class/net/*/wireless; do
  [ -e "$d" ] && dev="$(basename "$(dirname "$d")")" && break
done
[ -z "$dev" ] && { jq -nc '{text:"󰤭  no wifi", tooltip:"no wireless interface"}'; exit 0; }

info="$(iwctl station "$dev" show 2>/dev/null | sed -r 's/\x1b\[[0-9;]*m//g')"
state="$(printf '%s\n' "$info" | sed -n 's/.*State[[:space:]]\{2,\}//p'            | sed 's/[[:space:]]*$//')"
ssid="$( printf '%s\n' "$info" | sed -n 's/.*Connected network[[:space:]]\{2,\}//p' | sed 's/[[:space:]]*$//')"

case "$state" in
  connected)  text="󰤨  ${ssid:-wifi}" ;;
  connecting) text="󰤩  …" ;;
  *)          text="󰤯  off" ;;
esac

tip="$(printf '%s\n' "$info" \
  | grep -vE '^\s*$|^\s*-+\s*$|Station on|Settable|^-{3,}' \
  | sed 's/^[[:space:]]*//' | head -6)"
[ -n "$tip" ] || tip="iwd · $dev"

jq -nc --arg t "$text" --arg tip "$tip" '{text:$t, tooltip:$tip}'
