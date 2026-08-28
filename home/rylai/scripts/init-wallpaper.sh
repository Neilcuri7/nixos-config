#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/wallpapers"
STATE_DIR="$HOME/.local/state/wallpaper"
CURRENT_PATH_FILE="$STATE_DIR/current_path.txt"
CURRENT_WALLPAPER="$STATE_DIR/current"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/877911.png"

mkdir -p "$STATE_DIR"

WALLPAPER_TO_SET=""

# 1. Verificar si hay una ruta guardada válida
if [ -f "$CURRENT_PATH_FILE" ]; then
    SAVED_PATH=$(cat "$CURRENT_PATH_FILE" | tr -d '\n')
    if [ -n "$SAVED_PATH" ] && [ -f "$SAVED_PATH" ]; then
        WALLPAPER_TO_SET="$SAVED_PATH"
    fi
fi

# 2. Si no hay ruta guardada, verificar el archivo current
if [ -z "$WALLPAPER_TO_SET" ] && [ -f "$CURRENT_WALLPAPER" ] && [ -s "$CURRENT_WALLPAPER" ]; then
    WALLPAPER_TO_SET="$CURRENT_WALLPAPER"
fi

# 3. Si no existe ninguno, recurrir al fondo por defecto o al primero disponible
if [ -z "$WALLPAPER_TO_SET" ]; then
    if [ -f "$DEFAULT_WALLPAPER" ]; then
        WALLPAPER_TO_SET="$DEFAULT_WALLPAPER"
    else
        FIRST_WALLPAPER=$(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | head -n 1)
        if [ -n "$FIRST_WALLPAPER" ]; then
            WALLPAPER_TO_SET="$FIRST_WALLPAPER"
        fi
    fi
    # Guardar para futuros inicios
    if [ -n "$WALLPAPER_TO_SET" ]; then
        echo "$WALLPAPER_TO_SET" > "$CURRENT_PATH_FILE"
        cp -L "$WALLPAPER_TO_SET" "$CURRENT_WALLPAPER" 2>/dev/null
    fi
fi

# 4. Iniciar swaybg de forma limpia
if [ -n "$WALLPAPER_TO_SET" ] && [ -f "$WALLPAPER_TO_SET" ]; then
    pkill -x swaybg 2>/dev/null
    swaybg -i "$WALLPAPER_TO_SET" -m fill &
fi

