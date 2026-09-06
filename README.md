# 🧩 Dotfiles

Configs de Arch Linux + Hyprland, gestionadas con GNU Stow.

> Escrito en español porque el destinatario es mi yo futuro y el asistente
> que me ayude a reinstalar. Si abrís esto sin contexto, empezá por
> "Instalación" y después por "Ajustes de sistema".

## Stack actual

| Rol | Programa |
|---|---|
| Compositor | Hyprland (config en **Lua**, ver trampa #1) |
| Barra / notificaciones / OSD | HyprPanel (fork parcheado, ver trampa #2) |
| Lanzador | walker + elephant |
| Terminal | kitty |
| Editor | Neovim (LazyVim + nord.nvim) |
| Wallpaper | awww (wrapper de swww) + selector en Quickshell |
| Lock / idle | hyprlock + hypridle |
| Shell | zsh |

Paquetes stow: `bin hypr hyprpanel kitty nvim systemd walker walls zsh`

**Ya no se usan** waybar, swaync, wofi ni hyprpaper. Si un historial viejo
o una guía te dice que los instales, está desactualizado.

--------------------------------------------------

## Instalación

```bash
git clone https://github.com/icortesb/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

`bootstrap.sh` instala paquetes de repos oficiales y de AUR, respalda las
configs existentes que no sean symlinks en `~/.dotfiles-backup-<fecha>`,
aplica stow, genera la config de HyprPanel y detecta monitores.

Pide sudo una vez, para `pacman -S`. El resto no necesita root.

### Qué se adapta solo a la máquina

`hyprpanel/.config/hyprpanel/generate.sh` genera `config.json` y `modules.json` a
partir de los `*.base.json` y decide según el hardware:

| Detecta | Cómo | Efecto |
|---|---|---|
| Notebook | existe `/sys/class/power_supply/BAT*` | agrega el módulo `battery` a la barra |
| Máquina de trabajo | existe `~/MDG/mdg-infra` | agrega el módulo `custom/mobidb` |
| Red sin NetworkManager | — | usa `custom/iwd` en lugar de `network` |

**No hace falta tocar nada de esto a mano en la notebook.** Los
`config.json` / `modules.json` generados están gitignorados a propósito:
editar siempre los `*.base.json`.

Para regenerar a mano: `bash ~/.config/hyprpanel/generate.sh && hyprpanel -q; hyprpanel`

Monitores: `bash ~/.config/hypr/scripts/detect-monitors.sh`

--------------------------------------------------

## Ajustes de sistema (fuera de dotfiles) — TODO ESTO NECESITA SUDO

Stow solo maneja `~`. Lo de abajo vive en `/etc` y `/boot`, no se
versiona acá, y **hay que rehacerlo en cada máquina nueva**. Verificado en
el desktop el 2026-09-06; en la notebook conviene confirmar cada uno antes
de aplicarlo, sobre todo el bootloader.

### 1. Builds de AUR en paralelo y sin paquetes -debug

El de mayor retorno: sin `MAKEFLAGS`, makepkg compila en **un solo core**.
Y `debug` en `OPTIONS` genera un paquete `-debug` por cada build de AUR,
que después queda huérfano (en el desktop había 30).

```bash
sudo sed -i 's/^#MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf
sudo sed -i 's/ debug lto)/ !debug lto)/' /etc/makepkg.conf
```

### 2. Arranque

```bash
# systemd-boot: el timeout por defecto de 30s es tiempo muerto puro.
# Si hay dual-boot conviene 5, no 1, para poder elegir Windows.
sudo sed -i 's/^timeout 30/timeout 5/' /boot/loader/loader.conf

# Bloquea el arranque ~12s esperando red que nadie necesita todavía
sudo systemctl disable NetworkManager-wait-online.service
```

⚠️ Confirmá primero que la notebook use systemd-boot: `bootctl status`.
Si usa GRUB, el equivalente es `GRUB_TIMEOUT` en `/etc/default/grub` y
después `grub-mkconfig -o /boot/grub/grub.cfg`.

### 3. Mantenimiento automático

```bash
sudo systemctl enable --now paccache.timer   # poda la cache a 3 versiones
sudo systemctl enable --now fstrim.timer     # TRIM semanal en SSD

sudo mkdir -p /etc/systemd/journald.conf.d
echo -e '[Journal]\nSystemMaxUse=500M' | sudo tee /etc/systemd/journald.conf.d/size.conf

sudo pacman -S reflector
sudo systemctl enable --now reflector.timer
```

⚠️ Configurá el país en `/etc/xdg/reflector/reflector.conf`
(`--country Brazil,Chile,Argentina`) o te manda a mirrors de Europa.

Habilitar los timers **no limpia lo que ya está acumulado**. Una vez:

```bash
sudo paccache -rk3
sudo paccache -ruk0
sudo journalctl --vacuum-size=500M
```

### 4. Higiene puntual

```bash
sudo pacman -Rns $(pacman -Qdtq)            # huérfanos
sudo DIFFPROG="nvim -d" pacdiff             # archivos .pacnew pendientes
```

En `pacdiff` hay que tipear la letra **y después Enter**: Enter solo
cuenta como respuesta vacía y responde "Invalid answer" en loop.

### 5. Seguridad — revisar, no copiar a ciegas

En el desktop, Samba estaba escuchando en `0.0.0.0:445` con un share
`guest ok = yes`, sin ningún firewall instalado. Revisá qué expone la
notebook antes de conectarla a una red ajena:

```bash
ss -tulpn | grep -v '127.0.0.1\|::1'
systemctl is-enabled firewalld ufw nftables
```

En una notebook que se conecta a redes que no controlás, un firewall no
es opcional. `firewalld` es el que mejor se lleva con NetworkManager.

--------------------------------------------------

## Trampas conocidas

**1. `hyprland.lua` es la config viva.** `hyprland.conf` fue eliminado en
2026-09-06. El autostart (walker, elephant, generate.sh) va en el bloque
de autostart del `.lua`, no en un `exec-once` de hyprlang.

**2. HyprPanel es un fork parcheado.** El paquete es
`ags-hyprpanel-grouped`, construido desde `~/Dev/HyprPanel` (rama
`feat/group-notifications-by-app`), no desde el PKGBUILD pelado de AUR.
**Instalar `ags-hyprpanel-git` desde AUR revierte el parche de agrupado de
notificaciones.** El PKGBUILD vive en `pkgbuilds/ags-hyprpanel-grouped/`:

```bash
cd ~/.dotfiles/pkgbuilds/ags-hyprpanel-grouped
makepkg -Ccf && sudo pacman -U ags-hyprpanel-grouped-*.pkg.tar.zst
#      ^^ -C limpia src/ antes (si no, pkgver se queda en el commit viejo)
#         -c borra src/ y pkg/ después (si no, quedan ~160 MB tirados)
```

**3. Cambiar la paleta implica tocar 4 lugares.** No hay una fuente única
de color todavía; cada app tiene su paleta escrita a mano. Si cambiás una,
cambiá las cuatro o vuelve la incoherencia:

| Archivo | Qué define |
|---|---|
| `kitty/.config/kitty/color.ini` | los 16 colores de la terminal |
| `kitty/.config/kitty/split-dim.py` | `ACTIVE_BG` / `INACTIVE_BG` **hardcodeados en hex** |
| `hyprpanel/.config/hyprpanel/config.base.json` | ~380 valores de la barra |
| `hypr/.config/hypr/hyprland.lua` | bordes de ventana |

`split-dim.py` es el que se olvida: repinta el fondo en cada cambio de
foco, así que si queda con el color viejo revierte todo lo demás.

**4. `matugen-bin` está instalado pero no conectado a nada.** No hay
`~/.config/matugen` ni templates. Es el candidato natural para resolver la
trampa #3 (colores derivados del wallpaper), pero hoy no hace nada.

--------------------------------------------------

## Sistema de diseño

Paleta **Nord**, tipografía **JetBrainsMono Nerd Font**. Los tres fondos
coinciden en `#2e3440` (terminal, editor y barra).

| Rol | Hex |
|---|---|
| Fondo (nord0) | `#2e3440` |
| Superficie (nord1) | `#3b4252` |
| Selección (nord2) | `#434c5e` |
| Muted (nord3) | `#4c566a` |
| Texto (nord4) | `#d8dee9` |
| Acento (nord8) | `#88c0d0` |
| Frost (nord7 / nord9 / nord10) | `#8fbcbb` `#81a1c1` `#5e81ac` |
| Aurora (rojo/naranja/amarillo/verde/violeta) | `#bf616a` `#d08770` `#ebcb8b` `#a3be8c` `#b48ead` |

Geometría: `rounding = 8` en Hyprland para que las ventanas coincidan con
los pills de la barra (`theme.bar.buttons.radius` = `0.5em`).
`rounding_power` tiene que ser `2.0`: con `0` el redondeo no se renderiza.

--------------------------------------------------

## Nota para asistentes de IA

- **No corras `sudo` en comandos no interactivos.** No hay askpass: el
  comando falla, y cada fallo cuenta para `pam_faillock`. Tres seguidos
  bloquean el sudo del usuario 10 minutos (`deny=3`, `unlock_time=600`),
  y parece que la contraseña dejó de andar. Pasale los comandos con sudo
  al usuario para que los corra él. Si ya pasó: `faillock --user <user>`
  muestra los intentos, y se limpia con `su -` + `faillock --reset`.
- Reiniciar kitty mata la sesión del asistente si corre dentro de kitty.
  Los cambios de `kitty.conf` y `color.ini` se aplican con
  `pkill -USR1 -x kitty`, pero los **watchers** (`split-dim.py`) solo se
  recargan en ventanas nuevas.
- Hyprland con config Lua **no acepta `hyprctl keyword`** ("can't work with
  non-legacy parsers"). Para aplicar cambios: editar el `.lua` +
  `hyprctl reload`.
- Verificá los colores midiendo píxeles de una captura (`grimblast save
  screen` + PIL), no a ojo.

--------------------------------------------------

## Desinstalar

```bash
cd ~/.dotfiles
stow -D bin hypr hyprpanel kitty nvim systemd walker walls zsh
```

Borrar los symlinks es seguro. Borrar archivos dentro de `~/.dotfiles`
borra las configs reales.
