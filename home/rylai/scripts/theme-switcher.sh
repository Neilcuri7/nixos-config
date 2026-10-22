#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/themes.json"
STATE_DIR="$HOME/.local/state/theme"
ACTIVE_THEME_FILE="$STATE_DIR/active_theme.txt"
WALLPAPER_STATE_DIR="$HOME/.local/state/wallpaper"
CURRENT_PATH_FILE="$WALLPAPER_STATE_DIR/current_path.txt"
CURRENT_WALLPAPER="$WALLPAPER_STATE_DIR/current"
WALLUST_CONFIG="$HOME/.config/wallust/wallust.toml"
SYNC_SCRIPT="$HOME/scripts/theme-sync.sh"

mkdir -p "$STATE_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    if command -v notify-send &>/dev/null; then
        notify-send "Gestor de Temas" "No se encontró $CONFIG_FILE"
    fi
    exit 1
fi

ACTION="${1:-menu}"

sync_env() {
    local accent_hex="${1:-}"
    if [ -x "$SYNC_SCRIPT" ]; then
        "$SYNC_SCRIPT" "$accent_hex"
    elif [ -x "$(dirname "$0")/theme-sync.sh" ]; then
        "$(dirname "$0")/theme-sync.sh" "$accent_hex"
    fi
}

apply_wallpaper_theme() {
    printf "%s" "wallust-wallpaper" > "$ACTIVE_THEME_FILE.tmp" && mv "$ACTIVE_THEME_FILE.tmp" "$ACTIVE_THEME_FILE"

    local wall_path=""
    if [ -f "$CURRENT_PATH_FILE" ]; then
        wall_path=$(tr -d '\r\n' < "$CURRENT_PATH_FILE" || true)
    fi

    if [ -z "$wall_path" ] || [ ! -f "$wall_path" ]; then
        if [ -f "$CURRENT_WALLPAPER" ] && [ -s "$CURRENT_WALLPAPER" ]; then
            wall_path="$CURRENT_WALLPAPER"
        fi
    fi

    if [ -z "$wall_path" ] || [ ! -f "$wall_path" ]; then
        local first_found
        first_found=$(find -L "$HOME/Pictures/wallpapers" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) 2>/dev/null | head -n 1 || true)
        if [ -n "$first_found" ]; then
            wall_path="$first_found"
        fi
    fi

    if [ -n "$wall_path" ] && [ -f "$wall_path" ]; then
        mkdir -p "$HOME/.config/waybar" "$HOME/.config/kitty" "$HOME/.config/hypr" "$HOME/.config/swaync" "$HOME/.config/rofi" "$HOME/.config/wlogout" "$HOME/.config/micro/colorschemes" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/yazi"

        if command -v wallust &>/dev/null && [ -f "$WALLUST_CONFIG" ]; then
            wallust run "$wall_path" -C "$WALLUST_CONFIG" || true
        fi
        sync_env
    fi
}

apply_theme() {
    local theme_id="$1"
    local name="$2"

    local theme_json
    theme_json=$(jq -c --arg id "$theme_id" '.themes[] | select(.id == $id)' "$CONFIG_FILE" 2>/dev/null || true)

    if [ -z "$theme_json" ]; then
        echo "Tema no encontrado: $theme_id" >&2
        return 1
    fi

    # Convertir paleta base16/base24 de themes.json al formato que espera pywal / wallust cs
    local temp_json
    temp_json=$(mktemp --suffix=.json)
    jq '{
        colors: {
            color0:  .colors.base00,
            color1:  .colors.base08,
            color2:  .colors.base0B,
            color3:  .colors.base0A,
            color4:  .colors.base0D,
            color5:  .colors.base0E,
            color6:  .colors.base0C,
            color7:  .colors.base05,
            color8:  .colors.base03,
            color9:  .colors.base08,
            color10: .colors.base0B,
            color11: .colors.base0A,
            color12: .colors.base0D,
            color13: .colors.base0E,
            color14: .colors.base0C,
            color15: .colors.base07
        },
        special: {
            background: .colors.base00,
            foreground: .colors.base05,
            cursor:     .colors.base05
        }
    }' <<< "$theme_json" > "$temp_json"

    mkdir -p "$HOME/.config/waybar" "$HOME/.config/kitty" "$HOME/.config/hypr" "$HOME/.config/swaync" "$HOME/.config/rofi" "$HOME/.config/wlogout" "$HOME/.config/micro/colorschemes" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/yazi"

    if command -v wallust &>/dev/null && [ -f "$WALLUST_CONFIG" ]; then
        wallust cs -f pywal "$temp_json" -C "$WALLUST_CONFIG" || true
    fi
    rm -f "$temp_json"

    printf "%s" "$theme_id" > "$ACTIVE_THEME_FILE.tmp" && mv "$ACTIVE_THEME_FILE.tmp" "$ACTIVE_THEME_FILE"

    local accent_hex
    accent_hex=$(jq -r '.colors.base0D // "#81a1c1"' <<< "$theme_json")
    sync_env "$accent_hex"
}

case "$ACTION" in
    "wallpaper"|"wallust")
        wp_script="$HOME/scripts/wallpaper.sh"
        if [ ! -f "$wp_script" ] && [ -f "$(dirname "$0")/wallpaper.sh" ]; then
            wp_script="$(dirname "$0")/wallpaper.sh"
        fi
        if [ -n "${2:-}" ]; then
            "$wp_script" --set "$2"
        else
            apply_wallpaper_theme
        fi
        ;;

    "menu")
        ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
        THEME_OPTIONS="󰸉  Extraer colores del Wallpaper (Wallust)\n"
        THEMES_COUNT=$(jq '.themes | length' "$CONFIG_FILE")
        for i in $(seq 0 $((THEMES_COUNT - 1))); do
            NAME=$(jq -r ".themes[$i].name" "$CONFIG_FILE")
            ICON=$(jq -r ".themes[$i].icon" "$CONFIG_FILE")
            THEME_OPTIONS="${THEME_OPTIONS}${ICON}  ${NAME}\n"
        done

        SELECTED=$(echo -e -n "$THEME_OPTIONS" | rofi -dmenu -p "󰔎 Seleccionar Tema" -theme "$ROFI_CONFIG" -theme-str 'window { width: 480px; }' || true)

        if [ -n "$SELECTED" ]; then
            if [[ "$SELECTED" == *"Wallust"* ]]; then
                apply_wallpaper_theme
                if command -v notify-send &>/dev/null; then
                    notify-send "Gestor de Temas" "Colores dinámicos de Wallust aplicados" -i preferences-desktop-theme
                fi
            else
                SELECTED_NAME=$(echo "$SELECTED" | sed -E 's/^[^ ]+ +//')
                for i in $(seq 0 $((THEMES_COUNT - 1))); do
                    NAME=$(jq -r ".themes[$i].name" "$CONFIG_FILE")
                    if [ "$NAME" = "$SELECTED_NAME" ]; then
                        ID=$(jq -r ".themes[$i].id" "$CONFIG_FILE")
                        apply_theme "$ID" "$NAME"
                        if command -v notify-send &>/dev/null; then
                            notify-send "Gestor de Temas" "Tema aplicado: $NAME" -i preferences-desktop-theme
                        fi
                        break
                    fi
                done
            fi
        fi
        ;;

    "init")
        ACTIVE_ID="wallust-wallpaper"
        if [ -f "$ACTIVE_THEME_FILE" ]; then
            ACTIVE_ID=$(tr -d '\r\n' < "$ACTIVE_THEME_FILE" || echo "wallust-wallpaper")
        fi

        if [ "$ACTIVE_ID" = "wallust-wallpaper" ] || [ "$ACTIVE_ID" = "matugen-wallpaper" ] || [ -z "$ACTIVE_ID" ]; then
            apply_wallpaper_theme
        else
            THEMES_COUNT=$(jq '.themes | length' "$CONFIG_FILE")
            THEME_FOUND=false
            for i in $(seq 0 $((THEMES_COUNT - 1))); do
                ID=$(jq -r ".themes[$i].id" "$CONFIG_FILE")
                if [ "$ID" = "$ACTIVE_ID" ]; then
                    NAME=$(jq -r ".themes[$i].name" "$CONFIG_FILE")
                    apply_theme "$ID" "$NAME"
                    THEME_FOUND=true
                    break
                fi
            done
            if [ "$THEME_FOUND" = false ]; then
                apply_wallpaper_theme
            fi
        fi
        ;;

    *)
        echo "Uso: $0 {menu|init|wallpaper [path]}" >&2
        exit 1
        ;;
esac
