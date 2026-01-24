# 🧩 Dotfiles

My dotfiles for Arch Linux / Hyprland, managed with GNU Stow.

Includes configs for:
- Hyprland
- Kitty
- Neovim
- Waybar
- SwayNC
- Wofi
- Zsh
- bootstrap.sh

--------------------------------------------------

## Requirements

Install git and stow:

sudo pacman -S git stow

--------------------------------------------------

## Installation (manual)

Clone the repo:

git clone git@github.com:icortesb/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

Create symlinks:

stow hypr kitty nvim waybar swaync wofi zsh
# or all together
stow *

--------------------------------------------------

## Installation (automatic)

The `bootstrap.sh` script:
- installs required packages
- backs up existing configs
- applies symlinks via stow

Give it execution permission first:

chmod +x bootstrap.sh
./bootstrap.sh

Backups are stored in ~/.dotfiles-backup-YYYYMMDD-HHMMSS

--------------------------------------------------

## Uninstall / remove symlinks

stow -D hypr kitty nvim waybar swaync wofi zsh

--------------------------------------------------

## Notes

- Existing configs will be backed up by bootstrap.sh
- Removing symlinks is safe
- Deleting files in ~/.dotfiles removes your actual configs
- Clone directly to ~/.dotfiles for simplicity

--------------------------------------------------

## Tip

After a fresh install:

git clone git@github.com:icortesb/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x bootstrap.sh
./bootstrap.sh

Your setup will be restored.

