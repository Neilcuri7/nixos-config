#!/usr/bin/env bash

ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
CLEAR_OPTION="[Eliminar Todo el Historial]"

SELECTED=$( (echo "$CLEAR_OPTION"; cliphist list) | rofi -dmenu -p "󰅍 Portapapeles" -theme "$ROFI_CONFIG" )

if [ -z "$SELECTED" ]; then
    exit 0
fi

if [ "$SELECTED" = "$CLEAR_OPTION" ]; then
    cliphist wipe
    notify-send "Portapapeles" "Se ha borrado todo el historial del portapapeles"
else
    echo "$SELECTED" | cliphist decode | wl-copy
fi
