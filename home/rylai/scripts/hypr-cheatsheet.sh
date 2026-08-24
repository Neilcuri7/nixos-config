#!/usr/bin/env bash

ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

KEYBINDINGS="󰌌 ─── [ APLICACIONES Y LANZADORES ] ───
󰌌 Super + Enter             : Terminal (Kitty)
󰍉 Super + Shift + Enter     : Menú de aplicaciones (Rofi)
󰈹 Super + W                 : Navegador (Brave)
󰉋 Super + E                 : Explorador de archivos (Thunar)
󰈔 Super + T                 : Gestor de archivos Yazi (en Kitty)
󰅍 Super + V                 : Historial de portapapeles (Cliphist + Rofi)
󰞅 Super + Shift + E         : Seleccionador de Emojis (Rofi)
󰸉 Super + Shift + W         : Selector de fondo de pantalla (Rofi)

󰊓 ─── [ GESTIÓN DE VENTANAS ] ───
󰅖 Super + Q                 : Cerrar ventana activa
󰕰 Super + Shift + F         : Alternar ventana flotante (Toggle floating)
󰐃 Super + Shift + P         : Anclar ventana flotante (Pin en todos los escritorios)
󰊓 Super + Ctrl + F          : Maximizar ventana (Sin tapar barra AGS)
󰊓 Super + F                 : Pantalla completa total (Fullscreen)
󰕰 Super + P                 : Modo Pseudo-tile
󰤼 Super + Shift + I         : Alternar split horizontal/vertical

󰁔 ─── [ NAVEGACIÓN Y FOCO ] ───
󰁔 Super + Flechas / H,J,K,L : Mover foco entre ventanas
󰁔 Super + Shift + Flechas/HJKL: Mover ventana activa
󰍽 Super + Mouse Clic Izq    : Mover ventana libremente
󰍽 Super + Mouse Clic Der    : Redimensionar ventana libremente

󰨞 ─── [ ESPACIOS DE TRABAJO (WORKSPACES) ] ───
󰨞 Super + [1-9, 0]          : Ir al escritorio (Workspace 1-10)
󰨞 Super + Shift + [1-9, 0]   : Mover ventana al escritorio (1-10)
󰖲 Super + Space             : Alternar espacio especial (Scratchpad)
󰖲 Super + Shift + Space     : Mover ventana activa a espacio especial

󰒓 ─── [ SISTEMA Y UTILIDADES ] ───
󰌽 Alt + Shift               : Cambiar distribución de teclado (us / es)
󰄄 Super + S                 : Captura de pantalla (Grim + Slurp + Swappy)
󰈊 Super + Shift + O         : Selector de color (Hyprpicker)
󰔎 Super + Shift + T         : Cambiar tema claro / oscuro (GTK)
󰊴 Super + Shift + G         : Activar/Desactivar Gamemode
󰌾 Super + Shift + L         : Bloquear pantalla (Swaylock)
󰐥 Super + Shift + X         : Menú de apagado (Wlogout)
󰞋 Super + H                 : Mostrar este menú de ayuda"

if command -v rofi >/dev/null 2>&1; then
    echo "$KEYBINDINGS" | rofi -dmenu \
        -p "󰌽 Atajos de Teclado" \
        -theme "$ROFI_CONFIG" \
        -theme-str 'window { width: 850px; }'
else
    echo "$KEYBINDINGS"
fi

