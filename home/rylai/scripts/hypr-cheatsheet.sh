#!/usr/bin/env bash

ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

KEYBINDINGS="󰌽 Alt + Shift             : Cambiar distribución/idioma del teclado (us / es)
󰌌 Super + Enter           : Terminal (Kitty)
󰈹 Super + W               : Navegador (Brave)
󰉋 Super + E               : Explorador de archivos (Thunar)
󰅍 Super + V               : Historial de portapapeles (Cliphist + Rofi)
󰅖 Super + Q               : Cerrar ventana activa
󰊓 Super + F               : Pantalla completa (Fullscreen)
󰕰 Super + P               : Modo Pseudo-tile
󰈔 Super + T               : Gestor de archivos Yazi (en Kitty)
󰄄 Super + S               : Captura de pantalla (Grim + Slurp + Swappy)
󰞋 Super + H               : Mostrar menú de ayuda de atajos
󰖲 Super + Space           : Alternar espacio especial (Scratchpad)
󰍉 Super + Shift + Enter   : Menú de aplicaciones (Rofi)
󰸉 Super + Shift + W       : Selector de fondo de pantalla (Rofi)
󰞅 Super + Shift + E       : Seleccionador de Emojis (Rofi)
󰕰 Super + Shift + F       : Alternar ventana flotante
󰌾 Super + Shift + L       : Bloquear pantalla (Swaylock)
󰐥 Super + Shift + X       : Menú de apagado (Wlogout)
󰔎 Super + Shift + T       : Cambiar tema claro / oscuro (GTK)
󰈊 Super + Shift + O       : Selector de color (Hyprpicker)
󰤼 Super + Shift + I       : Alternar split horizontal/vertical
󰖲 Super + Shift + Space   : Mover ventana activa a espacio especial
󰨞 Super + [1-9, 0]        : Ir al escritorio (Workspace 1-10)
󰨞 Super + Shift + [1-9, 0] : Mover ventana al escritorio (1-10)
󰁔 Super + Flechas / H,J,K,L: Mover foco entre ventanas
󰁔 Super + Shift + Flechas : Mover ventana activa
󰍽 Super + Mouse Clic Izq  : Mover ventana libremente
󰍽 Super + Mouse Clic Der  : Redimensionar ventana libremente"

if command -v rofi >/dev/null 2>&1; then
    echo "$KEYBINDINGS" | rofi -dmenu \
        -p "󰌽 Atajos de Teclado" \
        -theme "$ROFI_CONFIG" \
        -theme-str 'window { width: 750px; }'
else
    echo "$KEYBINDINGS"
fi

