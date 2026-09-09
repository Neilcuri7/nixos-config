#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.local/state/gamemode_active"
mkdir -p "$HOME/.local/state"

if [ ! -f "$STATE_FILE" ]; then
    if command -v powerprofilesctl &>/dev/null; then
        powerprofilesctl set performance 2>/dev/null || true
    fi

    if command -v hyprctl &>/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
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
    if command -v powerprofilesctl &>/dev/null; then
        powerprofilesctl set balanced 2>/dev/null || true
    fi

    if command -v hyprctl &>/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl reload &>/dev/null || true
    fi

    rm -f "$STATE_FILE"
    notify-send -u low -i preferences-system "󰓅 Gamemode DESACTIVADO" "CPU en modo Equilibrado y entorno restaurado."
fi
