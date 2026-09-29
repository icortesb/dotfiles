#!/usr/bin/env bash
# walker dmenu -> open the chosen MDG tool in kitty (mdg-db / mdg-local live in .zshrc).
set -o pipefail
pick="$(printf '%s\n' 'PROD (mdg-db)' 'Local (mdg-local)' 'Refrescar local' 'mdg-tui' \
        | walker --dmenu --placeholder 'MDG…')" || exit 0
case "$pick" in
  'PROD (mdg-db)')     exec kitty zsh -ic mdg-db ;;
  'Local (mdg-local)') exec kitty zsh -ic mdg-local ;;
  'Refrescar local')   exec kitty zsh -ic 'mdg-local-sync; read -k1 "?Enter para cerrar"' ;;
  'mdg-tui')           exec kitty mdg-tui ;;
esac
