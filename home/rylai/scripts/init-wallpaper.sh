#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/wallpapers"
STATE_DIR="$HOME/.local/state/wallpaper"
CURRENT_WALLPAPER="$STATE_DIR/current"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/877911.png"

mkdir -p "$STATE_DIR"

if [ ! -f "$CURRENT_WALLPAPER" ]; then
    if [ -f "$DEFAULT_WALLPAPER" ]; then
        cp -f "$DEFAULT_WALLPAPER" "$CURRENT_WALLPAPER" 2>/dev/null
    else
        FIRST_WALLPAPER=$(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | head -n 1)
        if [ -n "$FIRST_WALLPAPER" ]; then
            cp -f "$FIRST_WALLPAPER" "$CURRENT_WALLPAPER" 2>/dev/null
        fi
    fi
fi

if [ -f "$CURRENT_WALLPAPER" ]; then
    OLD_PIDS=$(pgrep swaybg)
    swaybg -i "$CURRENT_WALLPAPER" -m fill &
    if [ -n "$OLD_PIDS" ]; then
        (sleep 0.3 && kill $OLD_PIDS 2>/dev/null) &
    fi
fi

