#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/.config/wallpapers"
STATE_DIR="$HOME/.local/state/wallpaper"
CURRENT_PATH_FILE="$STATE_DIR/current_path.txt"
CURRENT_WALLPAPER="$STATE_DIR/current"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/877911.png"

mkdir -p "$STATE_DIR"

WALLPAPER_TO_SET=""

# 1. Verificar si hay una ruta guardada válida
if [ -f "$CURRENT_PATH_FILE" ]; then
    SAVED_PATH=$(tr -d '\r\n' < "$CURRENT_PATH_FILE" || true)
    if [ -n "$SAVED_PATH" ] && [ -f "$SAVED_PATH" ]; then
        WALLPAPER_TO_SET="$SAVED_PATH"
    fi
fi

# 2. Si no hay ruta guardada válida, verificar el archivo current
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
    # Guardar de forma atómica para futuros inicios
    if [ -n "$WALLPAPER_TO_SET" ]; then
        printf "%s" "$WALLPAPER_TO_SET" > "$CURRENT_PATH_FILE.tmp" && mv "$CURRENT_PATH_FILE.tmp" "$CURRENT_PATH_FILE"
        cp -L "$WALLPAPER_TO_SET" "$CURRENT_WALLPAPER.tmp" 2>/dev/null && mv "$CURRENT_WALLPAPER.tmp" "$CURRENT_WALLPAPER"
    fi
fi

# 4. Iniciar swaybg de forma limpia con reemplazo suave (evita parpadeos negros)
if [ -n "$WALLPAPER_TO_SET" ] && [ -f "$WALLPAPER_TO_SET" ]; then
    OLD_PIDS=$(pgrep swaybg || true)
    swaybg -i "$WALLPAPER_TO_SET" -m fill &
    NEW_PID=$!

    if [ -n "$OLD_PIDS" ]; then
        (sleep 0.15 && for pid in $OLD_PIDS; do [ "$pid" != "$NEW_PID" ] && kill "$pid" 2>/dev/null || true; done) &
    fi
fi

