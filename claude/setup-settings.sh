#!/usr/bin/env bash
# Registra el hook de notificaciones en la config de Claude Code (idempotente).
# No versionamos settings.json/.claude.json enteros: tienen permisos y estado propios de cada máquina.
set -euo pipefail

merge() { # archivo, filtro jq
  [ -f "$1" ] || echo '{}' > "$1"
  jq "$2" "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

merge "$HOME/.claude/settings.json" \
  '.hooks.Notification=[{"hooks":[{"type":"command","command":"~/.claude/hooks/notify-replace.sh"}]}]'
merge "$HOME/.claude.json" '.preferredNotifChannel="notifications_disabled"'
