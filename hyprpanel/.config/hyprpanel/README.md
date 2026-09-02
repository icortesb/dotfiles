# HyprPanel setup

HyprPanel is the unified **bar + notifications + OSD** on this machine (replaces
waybar + swaync). Theme: **Nord**, floating translucent bar, JetBrainsMono Nerd
Font, dense module layout, plus a custom **Claude Code usage** module.

waybar and swaync stay installed and their configs are untouched — they are the
fallback if HyprPanel misbehaves.

---

## Importing on a new machine (e.g. the work laptop)

Run these in order. Assumes the dotfiles repo is already cloned to `~/.dotfiles`
and stowed like the rest (each top-level dir is `stow`-ed into `~`).

### 1. Packages

```sh
# repo deps
sudo pacman -S --needed jq nodejs awww brightnessctl pacman-contrib wf-recorder \
                        wireplumber libgtop dart-sass gvfs gtksourceview3 \
                        ttf-jetbrains-mono-nerd

# HyprPanel + the Astal stack + screenshot helper (AUR)
yay -S ags-hyprpanel-git grimblast-git
```

`ags-hyprpanel-git` pulls the rest of the Astal stack
(`aylurs-gtk-shell-git`, `libastal-meta`, `libastal-gjs-git`) automatically.

### 2. `swww` → `awww` shim

Upstream renamed `swww` to `awww`. HyprPanel still calls the binary `swww`
internally, so add wrappers on `PATH`:

```sh
sudo sh -c 'printf "#!/bin/sh\nexec awww \"\$@\"\n"        > /usr/local/bin/swww
            printf "#!/bin/sh\nexec awww-daemon \"\$@\"\n" > /usr/local/bin/swww-daemon
            chmod +x /usr/local/bin/swww /usr/local/bin/swww-daemon'
```

### 3. Stow + generate

```sh
cd ~/.dotfiles && stow hyprpanel        # symlinks ~/.config/hyprpanel
~/.config/hyprpanel/generate.sh         # writes config.json + modules.json
```

### 4. Relogin

`hypr/.config/hypr/hyprland.lua` already autostarts it:

```lua
hl.exec_cmd(os.getenv("HOME") .. "/.config/hyprpanel/generate.sh; hyprpanel")
```

Log out / back in (or just `hyprpanel` from a terminal to test first).

---

## How the config works

| File | Tracked | Role |
|------|:-:|------|
| `config.base.json`  | ✅ | Source of truth. **Edit this.** |
| `modules.base.json` | ✅ | Custom bar modules (the Claude usage widget). `$HOME` is literal here. |
| `scripts/`          | ✅ | Helper scripts for custom modules. |
| `generate.sh`       | ✅ | Renders the two files below at login. |
| `config.json`       | ❌ | Generated. Do **not** edit — and avoid HyprPanel's in-app settings GUI, it writes here and gets overwritten on next login. |
| `modules.json`      | ❌ | Generated (`$HOME` expanded to an absolute path). |
| `modules.scss`      | ❌ | HyprPanel runtime. |

`generate.sh` does three things:

1. Injects the absolute wallpaper path (`$HOME/walls/wall1.png`).
2. **Battery module**: adds `battery` to every bar layout **only if a real
   system battery exists** (`/sys/class/power_supply/BAT*`). Desktop → hidden;
   laptop → shows the percentage. The Logitech mouse's `hidpp_battery_0` does
   not count.
3. Seeds `~/.config/background` (HyprPanel's "current wallpaper" copy) so its
   first `swww img` call succeeds.

To apply an edit without relogin: `~/.config/hyprpanel/generate.sh && hyprpanel -q; hyprpanel`
(or press **Super+R**).

---

## Wallpaper

`wallpaper.enable` is `true`; HyprPanel drives `awww` via the `swww` shim with a
grow-from-cursor transition. It manages **one** wallpaper — there is no gallery
UI. Change it with:

```sh
hyprpanel setWallpaper /path/to/img.png     # single wallpaper, with transition
~/.config/hyprpanel/scripts/wallpaper-cycle.sh   # random from ~/Pictures/wallpapers  (Super+Shift+W)
```

Wallpaper pool: clone a curated repo outside the dotfiles tree, e.g.
`git clone --depth 1 https://github.com/D3Ext/aesthetic-wallpapers ~/Pictures/wallpapers`.
The initial boot wallpaper is still set from `hyprland.lua` (`awww img …`).

There is **no settings GUI** in this build (`ags-hyprpanel-git`) — configure via
`config.base.json`, not in-app.

## Weather (disabled)

`menus.clock.weather.enabled` is **false**. HyprPanel's weather uses
weatherapi.com and needs a free API key in `menus.clock.weather.key` — it is
**not set**. To enable: register at weatherapi.com, put the key in
`config.base.json`, set `menus.clock.weather.location` (`Buenos Aires`) and
`.enabled` true.

---

## Claude Code usage module (`custom/claude`)

Shows session (5h) and weekly usage, pulled from the same endpoint as Claude
Code's `/usage`. Defined in `modules.base.json`; `scripts/claude-usage-label.sh`
adapts the waybar script `waybar/.config/waybar/scripts/claude-usage.sh` into the
module's `{label}` / `{tooltip}` templates.

- **left-click** → notification popup (`claude-usage-notify.sh`)
- **right-click** → full readout in a kitty window (`claude-usage-show.sh`)

Requires: `node`, `curl`, and a logged-in Claude Code (`~/.claude/.credentials.json`).
Degrades to `-` / cached data on any failure; 429s are normal and silent.

---

## Keybinds changed (in `hyprland.lua`)

| Key | Now |
|-----|-----|
| Super+N | `hyprpanel toggleWindow notificationsmenu` (was `swaync-client -t`) |
| Super+R | restart HyprPanel (was reload waybar) |
| Super+G | `scripts/dirjump.sh` — zoxide frecency → walker dmenu → open dir |
| Super+Shift+W | `scripts/wallpaper.sh menu` — picker (Random / Previous / every image) |
| Super+W | `scripts/wallpaper.sh next` — random wallpaper |
| Super+Ctrl+W | `scripts/wallpaper.sh prev` — step back through history |

Blur: `hl.layer_rule` for namespace `bar-.*`.

> **`hyprctl reload` does NOT re-run the native Lua config.** After editing
> `hyprland.lua` you must log out / back in for keybinds, layer rules and the
> autostart block to take effect.

---

## Verify

```sh
pgrep -af 'gjs -m'                                   # hyprpanel running
busctl --user status org.freedesktop.Notifications   # PID = the gjs one
swww query                                           # wallpaper daemon (via shim)
~/.config/hyprpanel/scripts/claude-usage-label.sh    # prints {"label":…,"tooltip":…}
```

## Revert / uninstall

```sh
pkill -f 'gjs -m'; waybar & swaync & disown          # back to the old bar now
yay -Rns ags-hyprpanel-git && yay -Yc                 # remove HyprPanel + orphans
git -C ~/.dotfiles revert <hyprpanel commit>          # undo the dotfiles changes
```

## Known cosmetic log noise (harmless)

- `No supported GPU monitoring tool found` — install `python-gpustat` if you want GPU stats.
- `Error opening file ~/.dotfiles/kitty: Is a directory` — dashboard shortcut/directory
  icon resolution walking `~/.dotfiles`; does not affect function.
