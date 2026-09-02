#!/usr/bin/env bash
# zoxide frecency -> walker dmenu -> open the chosen dir in the file manager.
set -o pipefail
pick="$(zoxide query -l | sed "s|^$HOME|~|" \
        | walker --dmenu --placeholder 'Jump to directory…')" || exit 0
[ -n "$pick" ] || exit 0
case "$pick" in "~"*) pick="$HOME${pick#\~}";; esac
exec xdg-open "$pick"
