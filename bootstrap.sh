#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

PACKAGES=(
  git
  stow
  neovim
  kitty
  waybar
  swaync
  wofi
  zsh
  jq
  hyprland
  hyprlock
  hyprpaper
)

STOW_PACKAGES=(
  hypr
  kitty
  nvim
  waybar
  swaync
  wofi
  zsh
)

echo "==> Installing packages"
sudo pacman -S --needed "${PACKAGES[@]}"

echo "==> Checking dotfiles repo"
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Dotfiles repo not found in $DOTFILES_DIR"
  echo "Clone it first:"
  echo "git clone git@github.com:TU_USUARIO/dotfiles.git ~/.dotfiles"
  exit 1
fi

echo "==> Backing up existing configs (if any)"
mkdir -p "$BACKUP_DIR"

backup_if_exists() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up $target"
    mv "$target" "$BACKUP_DIR/"
  fi
}

backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.config/hypr"
backup_if_exists "$HOME/.config/kitty"
backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/waybar"
backup_if_exists "$HOME/.config/swaync"
backup_if_exists "$HOME/.config/wofi"

echo "==> Applying stow"
cd "$DOTFILES_DIR"
stow "${STOW_PACKAGES[@]}"

echo "==> Setting up wallpapers"
mkdir -p "$HOME/walls"
rm -rf "$HOME/walls/"*
cp "$DOTFILES_DIR/walls/"* "$HOME/walls/" 2>/dev/null || echo "No wallpapers found in dotfiles"

echo "==> Detecting monitors and configuring Hyprland"
if command -v hyprctl >/dev/null 2>&1; then
    bash "$HOME/.config/hypr/scripts/detect-monitors.sh"
else
    echo "Hyprland not running, skipping monitor detection"
    echo "Run 'bash ~/.config/hypr/scripts/detect-monitors.sh' after starting Hyprland"
fi

echo
echo "==> Done"
echo "Backup created at: $BACKUP_DIR"
echo "Restart your shell or log out/in to apply everything."

