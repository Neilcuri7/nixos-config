#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/.config/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpapers" "No se encontró el directorio de wallpapers en $WALLPAPER_DIR"
    exit 1
fi

mkdir -p "$CACHE_DIR"

generate_entry() {
    local wallpaper
    wallpaper=$(readlink -f "$1")
    local filename
    filename=$(basename "$wallpaper")
    local thumb="$CACHE_DIR/$filename"

    if [ ! -f "$thumb" ] || [ "$wallpaper" -nt "$thumb" ]; then
        if command -v magick &>/dev/null; then
            magick "$wallpaper" -thumbnail 250x150^ -gravity center -extent 250x150 "$thumb" &>/dev/null || true
        elif command -v convert &>/dev/null; then
            convert "$wallpaper" -thumbnail 250x150^ -gravity center -extent 250x150 "$thumb" &>/dev/null || true
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

# Generar miniaturas de forma paralela (multi-hilo) e inyectar directamente en rofi vía tubería
# (evita que la sustitución de comandos de bash $(...) elimine los bytes nulos \0 necesarios para los iconos)
NPROC=$(nproc 2>/dev/null || echo 4)
SELECTED_WALLPAPER=$(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0 | \
    xargs -0 -P "$NPROC" -I {} bash -c 'generate_entry "$@"' _ {} | \
    rofi -dmenu -i -show-icons -p "󰸉 Fondo de pantalla" -theme "$ROFI_CONFIG" -theme-str "$ROFI_GRID_THEME" || true)

if [ -n "$SELECTED_WALLPAPER" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTED_WALLPAPER"
    STATE_DIR="$HOME/.local/state/wallpaper"
    CURRENT_PATH_FILE="$STATE_DIR/current_path.txt"
    CURRENT_WALLPAPER="$STATE_DIR/current"
    
    mkdir -p "$STATE_DIR"
    
    # 1. Guardar la ruta seleccionada atómicamente
    printf "%s" "$FULL_PATH" > "$CURRENT_PATH_FILE.tmp" && mv "$CURRENT_PATH_FILE.tmp" "$CURRENT_PATH_FILE"
    cp -L "$FULL_PATH" "$CURRENT_WALLPAPER.tmp" 2>/dev/null && mv "$CURRENT_WALLPAPER.tmp" "$CURRENT_WALLPAPER"

    # 2. Iniciar la nueva instancia de swaybg
    OLD_PIDS=$(pgrep swaybg || true)
    swaybg -i "$FULL_PATH" -m fill &
    NEW_PID=$!

    # 3. Eliminar instancias anteriores suavemente
    if [ -n "$OLD_PIDS" ]; then
        (sleep 0.15 && for pid in $OLD_PIDS; do [ "$pid" != "$NEW_PID" ] && kill "$pid" 2>/dev/null || true; done) &
    fi

    # 4. Si el tema activo es 'matugen-wallpaper', actualizar los colores del nuevo fondo automáticamente
    THEMES_CONFIG="$HOME/.config/themes.json"
    if [ -f "$THEMES_CONFIG" ] && command -v jq &>/dev/null; then
        ACTIVE_THEME=$(jq -r '.active_theme // empty' "$THEMES_CONFIG" 2>/dev/null || true)
        if [ "$ACTIVE_THEME" = "matugen-wallpaper" ]; then
            "$HOME/scripts/theme-switcher.sh" wallpaper "$FULL_PATH" &
        fi
    fi
fi

