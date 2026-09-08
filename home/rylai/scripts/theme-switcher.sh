#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/themes.json"

if [ ! -f "$CONFIG_FILE" ]; then
    if command -v notify-send &>/dev/null; then
        notify-send "Gestor de Temas" "No se encontró $CONFIG_FILE"
    fi
    exit 1
fi

ACTION="${1:-menu}"

# Función central para emitir señales POSIX de recarga en caliente
reload_environment() {
    # 1. Recargar Hyprland (para releer colors.conf)
    if command -v hyprctl &>/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl reload &>/dev/null || true
    fi

    # 2. Recargar instancias de Kitty abiertas
    killall -SIGUSR1 kitty 2>/dev/null || true

    # 3. Recargar estilos CSS de Waybar
    killall -SIGUSR2 waybar 2>/dev/null || true

    # 4. Recargar estilos de SwayNC
    if command -v swaync-client &>/dev/null; then
        swaync-client --reload-css &>/dev/null || true
    fi
}

# Función para aplicar una paleta base16 fija en todos los archivos de destino
apply_palette() {
    local base00="$1" base01="$2" base02="$3" base03="$4"
    local base04="$5" base05="$6" base06="$7" base07="$8"
    local base08="$9" base09="${10}" base0A="${11}" base0B="${12}"
    local base0C="${13}" base0D="${14}" base0E="${15}" base0F="${16}"
    local theme_id="${17}"
    local name="${18}"

    mkdir -p "$HOME/.config/kitty" "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/swaync" "$HOME/.config/rofi"

    # 1. Generar colores para Hyprland
    cat <<EOF > "$HOME/.config/hypr/colors.conf"
# Colores generados por theme-switcher.sh ($name)
\$background = rgb(${base00#\#})
\$foreground = rgb(${base05#\#})
\$primary = rgb(${base0D#\#})
\$secondary = rgb(${base0E#\#})
\$tertiary = rgb(${base0C#\#})
\$error = rgb(${base08#\#})
\$surface = rgb(${base01#\#})
\$outline = rgb(${base03#\#})
EOF

    # 2. Generar colores para Kitty
    cat <<EOF > "$HOME/.config/kitty/current-theme.conf"
# Tema generado automáticamente por theme-switcher.sh ($name)
background            $base00
foreground            $base05
selection_background  $base02
selection_foreground  $base05
url_color             $base0D
cursor                $base05
cursor_text_color     $base00
active_border_color   $base0D
inactive_border_color $base02

# Paleta para terminal
color0  $base00
color1  $base08
color2  $base0B
color3  $base0A
color4  $base0D
color5  $base0E
color6  $base0C
color7  $base05

# Colores brillantes
color8  $base03
color9  $base08
color10 $base0B
color11 $base0A
color12 $base0D
color13 $base0E
color14 $base0C
color15 $base07
EOF

    # 3. Generar colores para Waybar
    cat <<EOF > "$HOME/.config/waybar/colors.css"
/* Variables generadas por theme-switcher.sh ($name) */
@define-color background $base00;
@define-color foreground $base05;
@define-color primary $base0D;
@define-color secondary $base0E;
@define-color tertiary $base0C;
@define-color error $base08;
@define-color surface $base01;
@define-color on_surface $base04;
@define-color surface_variant $base02;
@define-color outline $base03;
EOF

    # 4. Generar colores para SwayNC
    cat <<EOF > "$HOME/.config/swaync/colors.css"
/* Variables generadas por theme-switcher.sh ($name) */
@define-color cc-bg $base01;
@define-color noti-bg $base00;
@define-color noti-bg-hover $base02;
@define-color text-color $base05;
@define-color text-color-disabled $base04;
@define-color border-color $base0D;
@define-color accent-color $base0D;
EOF

    # 5. Generar colores para Rofi
    cat <<EOF > "$HOME/.config/rofi/colors.rasi"
/* Variables generadas por theme-switcher.sh ($name) */
* {
    background:  ${base00}ee;
    selected:    ${base02}dd;
    accent:      ${base0D};
    border-col:  ${base03};
    text:        ${base05};
    placeholder: ${base04}88;
}
EOF

    # 6. Actualizar tema activo en themes.json
    if command -v jq &>/dev/null && [ -f "$CONFIG_FILE" ]; then
        local tmp
        tmp=$(mktemp)
        jq --arg id "$theme_id" '.active_theme = $id' "$CONFIG_FILE" > "$tmp" 2>/dev/null && mv "$tmp" "$CONFIG_FILE"
    fi

    # 7. Recargar todas las aplicaciones abiertas
    reload_environment

    if command -v notify-send &>/dev/null; then
        notify-send "Tema cambiado" "Paleta activa: $name" -i preferences-desktop-theme &>/dev/null || true
    fi
}

# Función para aplicar un tema por su ID desde themes.json
apply_theme() {
    local theme_id="$1"
    local name="$2"

    local theme_json
    theme_json=$(jq -c --arg id "$theme_id" '.themes[] | select(.id == $id)' "$CONFIG_FILE" 2>/dev/null || true)

    if [ -z "$theme_json" ]; then
        echo "Tema no encontrado: $theme_id" >&2
        return 1
    fi

    local base00 base01 base02 base03 base04 base05 base06 base07
    local base08 base09 base0A base0B base0C base0D base0E base0F

    base00=$(echo "$theme_json" | jq -r '.colors.base00 // "#2e3440"')
    base01=$(echo "$theme_json" | jq -r '.colors.base01 // "#3b4252"')
    base02=$(echo "$theme_json" | jq -r '.colors.base02 // "#434c5e"')
    base03=$(echo "$theme_json" | jq -r '.colors.base03 // "#4c566a"')
    base04=$(echo "$theme_json" | jq -r '.colors.base04 // "#d8dee9"')
    base05=$(echo "$theme_json" | jq -r '.colors.base05 // "#e5e9f0"')
    base06=$(echo "$theme_json" | jq -r '.colors.base06 // "#eceff4"')
    base07=$(echo "$theme_json" | jq -r '.colors.base07 // "#8fbcbb"')
    base08=$(echo "$theme_json" | jq -r '.colors.base08 // "#bf616a"')
    base09=$(echo "$theme_json" | jq -r '.colors.base09 // "#d08770"')
    base0A=$(echo "$theme_json" | jq -r '.colors.base0A // "#ebcb8b"')
    base0B=$(echo "$theme_json" | jq -r '.colors.base0B // "#a3be8c"')
    base0C=$(echo "$theme_json" | jq -r '.colors.base0C // "#88c0d0"')
    base0D=$(echo "$theme_json" | jq -r '.colors.base0D // "#81a1c1"')
    base0E=$(echo "$theme_json" | jq -r '.colors.base0E // "#b48ead"')
    base0F=$(echo "$theme_json" | jq -r '.colors.base0F // "#5e81ac"')

    apply_palette "$base00" "$base01" "$base02" "$base03" "$base04" "$base05" "$base06" "$base07" \
                  "$base08" "$base09" "$base0A" "$base0B" "$base0C" "$base0D" "$base0E" "$base0F" \
                  "$theme_id" "$name"
}

case "$ACTION" in
    "wallpaper"|"matugen")
        if [ -n "${2:-}" ]; then
            "$HOME/scripts/wallpaper.sh" --set "$2"
        else
            "$HOME/scripts/wallpaper.sh" --restore
        fi
        ;;

    "menu")
        ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
        THEME_OPTIONS="󰸉  Extraer colores del Wallpaper (Matugen)\n"
        THEMES_COUNT=$(jq '.themes | length' "$CONFIG_FILE")
        for i in $(seq 0 $((THEMES_COUNT - 1))); do
            NAME=$(jq -r ".themes[$i].name" "$CONFIG_FILE")
            ICON=$(jq -r ".themes[$i].icon" "$CONFIG_FILE")
            THEME_OPTIONS="${THEME_OPTIONS}${ICON}  ${NAME}\n"
        done

        SELECTED=$(echo -e -n "$THEME_OPTIONS" | rofi -dmenu -p "󰔎 Seleccionar Tema" -theme "$ROFI_CONFIG" -theme-str 'window { width: 480px; }' || true)

        if [ -n "$SELECTED" ]; then
            if [[ "$SELECTED" == *"Matugen"* ]]; then
                "$HOME/scripts/wallpaper.sh" --select
            else
                SELECTED_NAME=$(echo "$SELECTED" | sed -E 's/^[^ ]+ +//')
                for i in $(seq 0 $((THEMES_COUNT - 1))); do
                    NAME=$(jq -r ".themes[$i].name" "$CONFIG_FILE")
                    if [ "$NAME" = "$SELECTED_NAME" ]; then
                        ID=$(jq -r ".themes[$i].id" "$CONFIG_FILE")
                        apply_theme "$ID" "$NAME"
                        break
                    fi
                done
            fi
        fi
        ;;

    "init")
        ACTIVE_ID=$(jq -r '.active_theme // "matugen-wallpaper"' "$CONFIG_FILE" 2>/dev/null || echo "matugen-wallpaper")
        if [ "$ACTIVE_ID" = "matugen-wallpaper" ]; then
            "$HOME/scripts/wallpaper.sh" --restore
        else
            THEMES_COUNT=$(jq '.themes | length' "$CONFIG_FILE")
            for i in $(seq 0 $((THEMES_COUNT - 1))); do
                ID=$(jq -r ".themes[$i].id" "$CONFIG_FILE")
                if [ "$ID" = "$ACTIVE_ID" ]; then
                    NAME=$(jq -r ".themes[$i].name" "$CONFIG_FILE")
                    apply_theme "$ID" "$NAME"
                    break
                fi
            done
        fi
        ;;

    *)
        echo "Uso: $0 {menu|init|wallpaper [path]}" >&2
        exit 1
        ;;
esac
