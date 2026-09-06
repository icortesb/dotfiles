#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Repos oficiales
PACMAN_PACKAGES=(
  git stow jq
  hyprland hyprlock hypridle
  quickshell            # motor QML del wallpaper-picker
  kitty neovim zsh
  ttf-jetbrains-mono-nerd
  brightnessctl playerctl
)

# AUR (yay)
AUR_PACKAGES=(
  ags-hyprpanel-grouped # ver nota del fork parcheado, más abajo
  walker-bin
  elephant-bin elephant-calc-bin elephant-clipboard-bin
  elephant-desktopapplications-bin elephant-files-bin elephant-menus-bin
  elephant-providerlist-bin elephant-runner-bin elephant-symbols-bin
  elephant-unicode-bin elephant-websearch-bin
  awww-git              # wrapper de wallpaper
  matugen-bin grimblast-git
)

STOW_PACKAGES=(bin hypr hyprpanel kitty nvim systemd walker walls zsh)

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloná el repo primero:"
  echo "  git clone git@github.com:icortesb/dotfiles.git ~/.dotfiles"
  exit 1
fi

echo "==> Paquetes de repos oficiales"
sudo pacman -S --needed "${PACMAN_PACKAGES[@]}"

echo "==> Paquetes de AUR"
if ! command -v yay >/dev/null 2>&1; then
  echo "yay no está instalado. Instalalo y volvé a correr este script." >&2
  exit 1
fi
yay -S --needed "${AUR_PACKAGES[@]}"

echo "==> Backup de configs existentes que no sean symlinks"
mkdir -p "$BACKUP_DIR"
backup_if_exists() {
  if [ -e "$1" ] && [ ! -L "$1" ]; then
    echo "  backup: $1"
    mv "$1" "$BACKUP_DIR/"
  fi
}
backup_if_exists "$HOME/.zshrc"
for d in hypr hyprpanel kitty nvim walker systemd; do
  backup_if_exists "$HOME/.config/$d"
done

echo "==> stow"
cd "$DOTFILES_DIR"
stow "${STOW_PACKAGES[@]}"

echo "==> Generando config de HyprPanel"
bash "$HOME/.config/hyprpanel/generate.sh"

echo "==> Detectando monitores"
if command -v hyprctl >/dev/null 2>&1 && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  bash "$HOME/.config/hypr/scripts/detect-monitors.sh"
else
  echo "  Hyprland no está corriendo. Después de iniciarlo, corré:"
  echo "    bash ~/.config/hypr/scripts/detect-monitors.sh"
fi

cat <<'NOTE'

==> Listo. Backup en el directorio que se imprimió arriba.

IMPORTANTE — HyprPanel es un fork parcheado:
  ags-hyprpanel-grouped se construye desde ~/Dev/HyprPanel, no desde el
  PKGBUILD pelado de AUR. Reinstalarlo desde AUR revierte el parche de
  agrupado de notificaciones. Cloná el fork y reconstruí desde ahí.

Cerrá y volvé a abrir la sesión para que tome todo.
NOTE
