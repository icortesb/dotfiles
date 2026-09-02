#!/usr/bin/env bash
# Wi-Fi picker for iwd — scan, pick in a walker dmenu, connect (prompt passphrase).
# Left-click action of the HyprPanel custom/iwd module.
# If the get-networks parsing is flaky on your hardware, `iwmenu` (AUR) is a
# drop-in replacement: set onLeftClick to `iwmenu -m dmenu -d walker`.
set -o pipefail

dev=""
for d in /sys/class/net/*/wireless; do
  [ -e "$d" ] && dev="$(basename "$(dirname "$d")")" && break
done
[ -z "$dev" ] && { notify-send -u critical "Wi-Fi" "no wireless interface"; exit 1; }

iwctl station "$dev" scan >/dev/null 2>&1
sleep 1.2

# strip ANSI, drop the header/separator rows, drop the "> " connected marker,
# then chop the trailing Security + Signal columns -> leaves the SSID (may contain spaces)
networks="$(iwctl station "$dev" get-networks 2>/dev/null \
  | sed -r 's/\x1b\[[0-9;]*m//g' \
  | grep -vE '^\s*-+\s*$|Available networks|Network name|^\s*$' \
  | sed -r 's/^[[:space:]]*>?[[:space:]]*//' \
  | sed -r 's/[[:space:]]{2,}(open|psk|8021x|wep)[[:space:]]{2,}\*+[[:space:]]*$//' \
  | sed -r 's/[[:space:]]+$//' \
  | awk 'NF')"

[ -z "$networks" ] && { notify-send "Wi-Fi" "no networks found"; exit 0; }

ssid="$(printf '%s\n' "$networks" | walker --dmenu --placeholder 'Wi-Fi…')" || exit 0
[ -n "$ssid" ] || exit 0

# already-known network -> connects without a prompt
if iwctl station "$dev" connect "$ssid" >/dev/null 2>&1; then
  notify-send -i network-wireless "Wi-Fi" "connected to $ssid"
  exit 0
fi

pass="$(printf '' | walker --dmenu --password --placeholder "Passphrase · $ssid")" || exit 0
if iwctl --passphrase "$pass" station "$dev" connect "$ssid" >/dev/null 2>&1; then
  notify-send -i network-wireless "Wi-Fi" "connected to $ssid"
else
  notify-send -u critical -i network-wireless-offline "Wi-Fi" "could not connect to $ssid"
fi
