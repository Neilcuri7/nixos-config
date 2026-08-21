#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/wallpapers"
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpapers" "No se encontró el directorio de wallpapers en $WALLPAPER_DIR"
    exit 1
fi

SELECTED_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -exec basename {} \; | rofi -dmenu -p "󰸉 Fondo de pantalla" -theme "$ROFI_CONFIG")

if [ -n "$SELECTED_WALLPAPER" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTED_WALLPAPER"
    pkill swaybg
    swaybg -i "$FULL_PATH" -m fill &
fi
