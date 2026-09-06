# Atenua el fondo de los splits sin foco.
#
# Kitty 0.48 no tiene background_opacity por ventana: las unicas opciones son
# background_opacity (global), dim_opacity e inactive_text_alpha, y esta ultima
# solo desvanece el TEXTO -- el fondo del split inactivo queda identico. Por eso
# este watcher parchea el color profile de cada ventana en on_focus_change, que
# es la unica forma de reproducir dentro de kitty el efecto de Hyprland.
#
# El color sale de decoration.inactive_opacity = 0.85 (~/.config/hypr/hyprland.lua):
#   #2e3440 * 0.85 = #272c36 (nord0 atenuado).
#
# Al ganar foco se repintan TODAS las ventanas del tab, no solo la que cambio:
# kitty no emite el evento focused=False de la ventana anterior cuando se crea
# un split nuevo, asi que el barrido completo mantiene el estado consistente.

from typing import Any

from kitty.boss import Boss
from kitty.fast_data_types import patch_color_profiles
from kitty.window import Window

ACTIVE_BG = 0x2e3440
INACTIVE_BG = 0x272c36


def _set_bg(window: Window, color: int) -> None:
    c = window.screen.color_profile.default_bg
    if (c.red << 16 | c.green << 8 | c.blue) == color:
        return  # ya esta, evita un refresh inutil
    patch_color_profiles({'background': color}, (), (window.screen.color_profile,), False)
    window.refresh()


def on_focus_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    if not data['focused']:
        _set_bg(window, INACTIVE_BG)
        return
    tab = boss.active_tab
    if tab is None:
        _set_bg(window, ACTIVE_BG)
        return
    for w in tab:
        _set_bg(w, ACTIVE_BG if w.id == window.id else INACTIVE_BG)
