#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/wallpapers"
CURRENT_WALLPAPER="$WALLPAPER_DIR/current"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/877911.png"

if [ -f "$CURRENT_WALLPAPER" ]; then
    swaybg -i "$CURRENT_WALLPAPER" -m fill &
elif [ -f "$DEFAULT_WALLPAPER" ]; then
    swaybg -i "$DEFAULT_WALLPAPER" -m fill &
else
    FIRST_WALLPAPER=$(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | head -n 1)
    if [ -n "$FIRST_WALLPAPER" ]; then
        swaybg -i "$FIRST_WALLPAPER" -m fill &
    fi
fi
