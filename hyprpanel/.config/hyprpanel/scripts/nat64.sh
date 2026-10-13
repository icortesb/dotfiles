#!/usr/bin/env bash
# HyprPanel custom/nat64 — toggle DNS64 (nat64.net) para llegar por IPv6 a hosts
# solo-IPv4 (GitHub) cuando el CGNAT del ISP corta IPv4.
#   nat64.sh status   -> JSON {text,tooltip} para el módulo
#   nat64.sh toggle   -> alterna; guarda y restaura el DNS original de la conexión
# DNS64 solo sintetiza AAAA donde no existe, el resto de los sitios no cambia.
# Dos backends: NetworkManager si corre; si no (máquina iwd), systemd-resolved
# vía resolvectl, que necesita la regla de polkit de system/polkit/.
set -o pipefail

DNS64="2a01:4f8:c2c:123f::1 2a00:1098:2b::1 2a00:1098:2c::1"
state="${XDG_STATE_HOME:-$HOME/.local/state}/nat64-orig"

out() { jq -nc --arg t "$1" --arg tip "$2" '{text:$t, tooltip:$tip}'; exit 0; }

if systemctl is-active --quiet NetworkManager 2>/dev/null; then
  backend=nm
  con="$(nmcli -t -f NAME,TYPE,DEVICE con show --active \
    | awk -F: '$2 ~ /ethernet|wireless/ && $3 != "" {print $1; exit}')"
  [ -n "$con" ] || out "󰯡  -" "sin conexión NetworkManager"
  dns_now() { nmcli -g ipv6.dns con show "$con" | tr -d '\\'; }
else
  backend=resolved
  dev="$(ip -o route show default | awk '{print $5; exit}')"
  [ -n "$dev" ] || dev="$(ip -o -6 route show default | awk '{print $5; exit}')"
  [ -n "$dev" ] || out "󰯡  -" "sin ruta por defecto"
  # "Link 3 (wlan0): 192.168.0.1 192.168.68.1" -> "192.168.0.1 192.168.68.1"
  dns_now() { resolvectl dns "$dev" 2>/dev/null | sed 's/^[^:]*: *//'; }
fi

is_on() { [[ "$(dns_now)" == *2a01:4f8:c2c:123f::1* ]]; }

fail() { notify-send -u critical "NAT64" "$1"; }

case "${1:-status}" in
  toggle)
    mkdir -p "$(dirname "$state")"
    if [ "$backend" = nm ]; then
      if is_on; then
        # shellcheck disable=SC1090
        [ -f "$state" ] && . "$state"
        nmcli con mod "$con" ipv4.dns "${V4DNS:-}" ipv4.ignore-auto-dns "${V4IGN:-no}" \
                             ipv6.dns "${V6DNS:-}" ipv6.ignore-auto-dns "${V6IGN:-no}"
        rm -f "$state"
      else
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
    else
      if is_on; then
        # shellcheck disable=SC1090
        [ -f "$state" ] && . "$state"
        # sin estado guardado (p. ej. se borró): el router suele ser el DNS
        [ -n "${ORIGDNS:-}" ] || ORIGDNS="$(ip -o route show default | awk '{print $3; exit}')"
        # shellcheck disable=SC2086
        resolvectl dns "$dev" $ORIGDNS 2>/dev/null \
          && rm -f "$state" \
          || fail "resolvectl no pudo restaurar el DNS de $dev (¿falta la regla de polkit?)"
      else
        printf 'ORIGDNS=%q\n' "$(dns_now)" > "$state"
        # shellcheck disable=SC2086
        resolvectl dns "$dev" $DNS64 2>/dev/null \
          || fail "resolvectl no pudo cambiar el DNS de $dev (¿falta la regla de polkit?)"
      fi
    fi
    ;;
esac

if is_on; then
  tip="NAT64 ON — DNS64 nat64.net por IPv6\nClick: volver al DNS original"
  if [ "$backend" = resolved ]; then
    ip -6 addr show dev "$dev" scope global | grep -q inet6 \
      || tip="⚠ $dev sin IPv6 global: el DNS64 no responde\n$tip"
    tip="$tip\niwd puede pisarlo al reconectar; si vuelve a off, click de nuevo"
  fi
  out "󰖟  NAT64" "$(printf '%b' "$tip")"
else
  out "󰖟  off" "$(printf 'NAT64 off\nClick: salir por IPv6/DNS64 (GitHub vía CGNAT roto)')"
fi
