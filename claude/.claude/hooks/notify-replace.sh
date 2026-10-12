#!/bin/sh
# Una sola notificación de Claude Code a la vez: cada nueva reemplaza a la anterior.
idf="${XDG_RUNTIME_DIR:-/tmp}/claude-notify-id"
msg=$(jq -r '.message // "Claude Code"' 2>/dev/null)
old=$(cat "$idf" 2>/dev/null)
new=$(notify-send -p -a "Claude Code" ${old:+-r "$old"} "Claude Code" "$msg") && echo "$new" > "$idf"
