#!/usr/bin/env bash
# migrate-nvim.sh
# Run this on any machine where you want to apply the LazyVim config
# from this dotfiles repo, replacing whatever nvim setup was there before.
#
# Usage: bash ~/.dotfiles/migrate-nvim.sh

set -e

DOTFILES_DIR="$HOME/.dotfiles"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "==> Installing nvim system dependencies"
sudo pacman -S --needed fd lazygit fzf luarocks tree-sitter

echo "==> Backing up old nvim data"
for dir in "$HOME/.local/share/nvim" "$HOME/.cache/nvim" "$HOME/.local/state/nvim"; do
  if [ -d "$dir" ]; then
    mv "$dir" "${dir}-backup-$TIMESTAMP"
    echo "    moved $dir → ${dir}-backup-$TIMESTAMP"
  fi
done

echo "==> Removing old nvim config symlink (if any)"
if [ -L "$HOME/.config/nvim" ] || [ -d "$HOME/.config/nvim" ]; then
  rm -rf "$HOME/.config/nvim"
fi

echo "==> Applying stow"
cd "$DOTFILES_DIR"
stow nvim

echo "==> Installing plugins (this will take ~30 seconds)"
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

echo ""
echo "Done. Open nvim — Mason will finish installing LSP servers in the background."
echo "If you see any errors on first open, run :Lazy sync inside nvim."
