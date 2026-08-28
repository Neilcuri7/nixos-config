#!/usr/bin/env bash

STATE_FILE="$HOME/.local/state/gamemode_active"
mkdir -p "$HOME/.local/state"

if [ ! -f "$STATE_FILE" ]; then
    # 1. Poner CPU en modo Rendimiento Máximo (fija frecuencias altas en tu AMD A8)
    if command -v powerprofilesctl &>/dev/null; then
        powerprofilesctl set performance 2>/dev/null
    fi

    # 2. Desactivar animaciones y bordes/márgenes en Hyprland para máxima tasa de FPS
    if command -v hyprctl &>/dev/null && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        hyprctl --batch "\
            keyword animations:enabled 0;\
            keyword general:gaps_in 0;\
            keyword general:gaps_out 0;\
            keyword general:border_size 1;\
            keyword decoration:shadow:enabled 0" &>/dev/null
    fi

    touch "$STATE_FILE"
    notify-send -u low -i input-gaming "🎮 Gamemode ACTIVADO" "CPU en modo Rendimiento (3.3 GHz) y entorno aligerado al máximo."
else
    # 1. Restaurar CPU a perfil Equilibrado
    if command -v powerprofilesctl &>/dev/null; then
        powerprofilesctl set balanced 2>/dev/null
    fi

    # 2. Restaurar configuración normal de Hyprland
    if command -v hyprctl &>/dev/null && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        hyprctl reload &>/dev/null
    fi

    rm -f "$STATE_FILE"
    notify-send -u low -i preferences-system "󰓅 Gamemode DESACTIVADO" "CPU en modo Equilibrado y entorno restaurado."
fi
