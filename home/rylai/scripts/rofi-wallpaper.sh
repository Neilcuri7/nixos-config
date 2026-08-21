#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.config/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpapers" "No se encontró el directorio de wallpapers en $WALLPAPER_DIR"
    exit 1
fi

mkdir -p "$CACHE_DIR"

generate_entry() {
    local wallpaper=$(readlink -f "$1")
    local filename=$(basename "$wallpaper")
    local thumb="$CACHE_DIR/$filename"

    if [ ! -f "$thumb" ] || [ "$wallpaper" -nt "$thumb" ]; then
        if command -v magick &>/dev/null; then
            magick "$wallpaper" -thumbnail 250x150^ -gravity center -extent 250x150 "$thumb" &>/dev/null
        elif command -v convert &>/dev/null; then
            convert "$wallpaper" -thumbnail 250x150^ -gravity center -extent 250x150 "$thumb" &>/dev/null
        else
            thumb="$wallpaper"
        fi
    fi

    printf "%s\0icon\x1f%s\n" "$filename" "$thumb"
}

export -f generate_entry
export CACHE_DIR

ROFI_GRID_THEME='
window {
    width: 1200px;
}
listview {
    columns: 5;
    lines: 2;
    spacing: 12px;
    cycle: true;
    dynamic: true;
}
element {
    orientation: vertical;
    padding: 10px;
    border-radius: 8px;
}
element-icon {
    size: 140px;
    horizontal-align: 0.5;
}
element selected element-icon {
    size: 140px;
}
element-text {
    horizontal-align: 0.5;
    vertical-align: 0.5;
}
'

SELECTED_WALLPAPER=$(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | \
    while read -r img; do
        generate_entry "$img"
    done | \
    rofi -dmenu -i -show-icons -p "󰸉 Fondo de pantalla" -theme "$ROFI_CONFIG" -theme-str "$ROFI_GRID_THEME")

if [ -n "$SELECTED_WALLPAPER" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTED_WALLPAPER"
    
    # 1. Guardar/actualizar la referencia al wallpaper actual para que persista entre reinicios
    cp -f "$FULL_PATH" "$WALLPAPER_DIR/current"
    
    # 2. Iniciar nueva instancia de swaybg en segundo plano antes de matar la anterior para evitar parpadeos
    swaybg -i "$FULL_PATH" -m fill &
    NEW_SWAYBG_PID=$!
    
    # Esperar un instante breve para que la nueva instancia tome el foco del fondo y matar las anteriores
    (sleep 0.5 && pkill --oldest swaybg) &
fi
