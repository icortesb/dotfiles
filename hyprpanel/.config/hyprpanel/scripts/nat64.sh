#!/usr/bin/env bash
# HyprPanel custom/nat64 — toggle DNS64 (nat64.net) para llegar por IPv6 a hosts
# solo-IPv4 (GitHub) cuando el CGNAT del ISP corta IPv4. Requiere NetworkManager.
#   nat64.sh status   -> JSON {text,tooltip} para el módulo
#   nat64.sh toggle   -> alterna; guarda y restaura el DNS original de la conexión
# DNS64 solo sintetiza AAAA donde no existe, el resto de los sitios no cambia.
set -o pipefail

DNS64="2a01:4f8:c2c:123f::1 2a00:1098:2b::1 2a00:1098:2c::1"
state="${XDG_STATE_HOME:-$HOME/.local/state}/nat64-orig"

con="$(nmcli -t -f NAME,TYPE,DEVICE con show --active \
  | awk -F: '$2 ~ /ethernet|wireless/ && $3 != "" {print $1; exit}')"
[ -n "$con" ] || { jq -nc '{text:"󰯡  -", tooltip:"sin conexión NetworkManager"}'; exit 0; }

is_on() { [[ "$(nmcli -g ipv6.dns con show "$con" | tr -d '\\')" == *2a01:4f8:c2c:123f::1* ]]; }

case "${1:-status}" in
  toggle)
    if is_on; then
      mkdir -p "$(dirname "$state")"
      # shellcheck disable=SC1090
      [ -f "$state" ] && . "$state"
      nmcli con mod "$con" ipv4.dns "${V4DNS:-}" ipv4.ignore-auto-dns "${V4IGN:-no}" \
                           ipv6.dns "${V6DNS:-}" ipv6.ignore-auto-dns "${V6IGN:-no}"
      rm -f "$state"
    else
      mkdir -p "$(dirname "$state")"
      {
        printf 'V4DNS=%q\n'  "$(nmcli -g ipv4.dns con show "$con" | tr -d '\\' | tr ',' ' ')"
        printf 'V4IGN=%q\n'  "$(nmcli -g ipv4.ignore-auto-dns con show "$con")"
        printf 'V6DNS=%q\n'  "$(nmcli -g ipv6.dns con show "$con" | tr -d '\\' | tr ',' ' ')"
        printf 'V6IGN=%q\n'  "$(nmcli -g ipv6.ignore-auto-dns con show "$con")"
      } > "$state"
      nmcli con mod "$con" ipv4.dns "" ipv4.ignore-auto-dns yes \
                           ipv6.dns "$DNS64" ipv6.ignore-auto-dns yes
    fi
    nmcli con up "$con" >/dev/null 2>&1
    ;;
esac

if is_on; then
  jq -nc '{text:"󰖟  NAT64", tooltip:"NAT64 ON — DNS64 nat64.net por IPv6\nClick: volver al DNS original"}'
else
  jq -nc '{text:"󰖟  off", tooltip:"NAT64 off\nClick: salir por IPv6/DNS64 (GitHub vía CGNAT roto)"}'
fi
