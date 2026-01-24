# 🧩 Dotfiles

My dotfiles for Arch Linux / Hyprland, managed with GNU Stow.

Includes configs for:
- Hyprland (with auto monitor detection)
- Hyprlock
- Hyprpaper
- Kitty
- Neovim
- Waybar
- SwayNC
- Wofi
- Zsh

--------------------------------------------------

## Requirements

**Minimum:**
- git
- stow

**For AUR packages (optional):**
- yay or paru

--------------------------------------------------

## Installation (automatic - recommended)

The `bootstrap.sh` script:
- installs required packages
- installs optional packages (if available)
- backs up existing configs
- applies symlinks via stow
- detects monitors and configures them automatically
- sets up wallpapers

Clone and run:

```bash
git clone git@github.com:icortesb/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

Backups are stored in ~/.dotfiles-backup-YYYYMMDD-HHMMSS

--------------------------------------------------

## Installation (manual)

Install dependencies:

```bash
sudo pacman -S git stow hyprland hyprlock hyprpaper kitty neovim waybar swaync wofi zsh jq
```

Clone the repo:

```bash
git clone git@github.com:icortesb/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Create symlinks:

```bash
stow hypr kitty nvim waybar swaync wofi zsh
```

--------------------------------------------------

## Dependencies

### Required Packages
- hyprland, hyprlock, hyprpaper
- kitty
- neovim
- waybar
- swaync
- wofi
- zsh
- jq (for monitor detection)

### Optional Packages
These provide extra functionality but aren't required:
- **hyprshot** - screenshots (SUPER+S, SUPER+SHIFT+S)
- **playerctl** - media controls and lock screen music display
- **brightnessctl** - brightness control (laptop function keys)
- **pipewire** + **wireplumber** - audio
- **pavucontrol** - audio GUI
- **brave-bin** - browser (SUPER+B)
- **dolphin** - file manager (SUPER+E)
- **foot** - terminal (wofi fallback)
- **python-hypr-power** - power menu (waybar button)

--------------------------------------------------

## Dynamic Monitor Configuration

Monitors are auto-detected and configured with the highest available refresh rate.

To regenerate monitor config:
```bash
bash ~/.config/hypr/scripts/detect-monitors.sh
```

--------------------------------------------------

## Uninstall / remove symlinks

```bash
stow -D hypr kitty nvim waybar swaync wofi zsh
```

--------------------------------------------------

## Notes

- Existing configs will be backed up by bootstrap.sh
- Removing symlinks is safe
- Deleting files in ~/.dotfiles removes your actual configs
- Clone directly to ~/.dotfiles for simplicity
- Monitor configuration adapts to your hardware automatically

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

