#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/wallpapers"
CURRENT_WALLPAPER="$WALLPAPER_DIR/current"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/877911.png"

# Matar instancias anteriores de swaybg para evitar acumulación
pkill swaybg 2>/dev/null

if [ -f "$CURRENT_WALLPAPER" ]; then
    swaybg -i "$CURRENT_WALLPAPER" -m fill
elif [ -f "$DEFAULT_WALLPAPER" ]; then
    cp -f "$DEFAULT_WALLPAPER" "$CURRENT_WALLPAPER" 2>/dev/null
    swaybg -i "$CURRENT_WALLPAPER" -m fill
else
    FIRST_WALLPAPER=$(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | head -n 1)
    if [ -n "$FIRST_WALLPAPER" ]; then
        cp -f "$FIRST_WALLPAPER" "$CURRENT_WALLPAPER" 2>/dev/null
        swaybg -i "$FIRST_WALLPAPER" -m fill
    fi
fi
