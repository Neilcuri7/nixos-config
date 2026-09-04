#!/usr/bin/env bash

# ==============================================================================
# SCRIPT DE CAMBIO DE TEMAS DINÁMICO (~/.config/themes.json)
# ==============================================================================
# Aplica esquemas de colores completos (fuentes, fondos, bordes, terminales,
# barra AGS y ventanas) en tiempo real.
# ==============================================================================

CONFIG_FILE="$HOME/.config/themes.json"

if [ ! -f "$CONFIG_FILE" ]; then
    notify-send "Gestor de Temas" "No se encontró $CONFIG_FILE"
    exit 1
fi

ACTION="$1"

# Función para convertir HEX (#RRGGBB) a R G B
hex_to_rgb() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "$r, $g, $b"
}

# Función central para aplicar una paleta de colores en todos los componentes
apply_palette() {
    local base00="$1"
    local base01="$2"
    local base02="$3"
    local base03="$4"
    local base04="$5"
    local base05="$6"
    local base06="$7"
    local base07="$8"
    local base08="$9"
    local base09="${10}"
    local base0A="${11}"
    local base0B="${12}"
    local base0C="${13}"
    local base0D="${14}"
    local base0E="${15}"
    local base0F="${16}"
    local theme_id="${17}"
    local name="${18}"

    local c_active1="${base0D#\#}"
    local c_active2="${base0E#\#}"
    local c_inactive="${base02#\#}"

    # 1. Actualizar bordes de ventanas en Hyprland
    if command -v hyprctl &>/dev/null && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        hyprctl keyword general:col.active_border "rgba(${c_active1}ff) rgba(${c_active2}ff) 45deg" &>/dev/null
        hyprctl keyword general:col.inactive_border "rgba(${c_inactive}ff)" &>/dev/null
    fi

    # 2. Actualizar bordes de ventanas en Sway si está ejecutándose
    if command -v swaymsg &>/dev/null && [ -n "$SWAYSOCK" ]; then
        swaymsg client.focused "$base0D" "$base00" "$base05" "$base0D" "$base0D" &>/dev/null
        swaymsg client.unfocused "$base02" "$base00" "$base04" "$base02" "$base02" &>/dev/null
    fi

    # 3. Generar y aplicar colores dinámicos a Kitty
    mkdir -p "$HOME/.config/kitty"
    local kitty_tmp
    kitty_tmp=$(mktemp)
    cat <<EOF > "$kitty_tmp"
# Tema generado automáticamente por theme-switcher.sh
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
    mv "$kitty_tmp" "$HOME/.config/kitty/current-theme.conf"

    # Aplicar a las terminales Kitty abiertas
    if command -v kitty &>/dev/null; then
        kitty @ set-colors --all "$HOME/.config/kitty/current-theme.conf" 2>/dev/null || killall -USR1 kitty 2>/dev/null || true
    fi

    # 4. Generar variables CSS dinámicas para AGS
    mkdir -p "$HOME/.config/ags"
    local rgb_bg
    local rgb_accent
    local rgb_fg
    rgb_bg=$(hex_to_rgb "$base00")
    rgb_accent=$(hex_to_rgb "$base0D")
    rgb_fg=$(hex_to_rgb "$base05")

    local ags_tmp
    ags_tmp=$(mktemp)
    cat <<EOF > "$ags_tmp"
/* Variables dinámicas generadas por theme-switcher.sh */
@define-color theme_bg $base00;
@define-color theme_fg $base05;
@define-color theme_accent $base0D;
@define-color theme_border $base03;
@define-color theme_module_bg rgba($rgb_bg, 0.75);
@define-color theme_hover rgba($rgb_accent, 0.25);
EOF
    mv "$ags_tmp" "$HOME/.config/ags/theme-colors.css"

    # Recargar estilos de AGS en caliente (soporte para v1 y v2)
    if command -v ags &>/dev/null && pgrep -x ags &>/dev/null; then
        ags -r "App.resetCss(); App.applyCss('${HOME}/.config/ags/style.css');" &>/dev/null || ags run-js "App.resetCss(); App.applyCss('${HOME}/.config/ags/style.css');" &>/dev/null || true
    fi

    # 5. Notificar a GTK/GSettings
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' &>/dev/null || true
    fi

    # 6. Actualizar tema activo en ~/.config/themes.json
    if command -v jq &>/dev/null && [ -f "$CONFIG_FILE" ]; then
        tmp=$(mktemp)
        jq --arg id "$theme_id" '.active_theme = $id' "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    fi

    # 7. Notificación visual
    if command -v notify-send &>/dev/null; then
        notify-send "Tema cambiado" "Paleta activa: $name" -i preferences-desktop-theme &>/dev/null || true
    fi
}

# Función para aplicar un tema manual predefinido desde themes.json
apply_theme() {
    local theme_id="$1"
    local scheme="$2"
    local name="$3"

    local theme_json
    theme_json=$(jq -c --arg id "$theme_id" '.themes[] | select(.id == $id)' "$CONFIG_FILE" 2>/dev/null)

    local base00="#2e3440" base01="#3b4252" base02="#434c5e" base03="#4c566a"
    local base04="#d8dee9" base05="#e5e9f0" base06="#eceff4" base07="#8fbcbb"
    local base08="#bf616a" base09="#d08770" base0A="#ebcb8b" base0B="#a3be8c"
    local base0C="#88c0d0" base0D="#81a1c1" base0E="#b48ead" base0F="#5e81ac"

    if [ -n "$theme_json" ]; then
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
    fi

    apply_palette "$base00" "$base01" "$base02" "$base03" "$base04" "$base05" "$base06" "$base07" \
                  "$base08" "$base09" "$base0A" "$base0B" "$base0C" "$base0D" "$base0E" "$base0F" \
                  "$theme_id" "$name"
}

# Función para extraer colores del wallpaper usando Matugen (Modo Dinámico Híbrido)
apply_matugen_wallpaper() {
    local target_wall="$1"

    if [ -z "$target_wall" ]; then
        local current_path_file="$HOME/.local/state/wallpaper/current_path.txt"
        if [ -f "$current_path_file" ]; then
            target_wall=$(cat "$current_path_file" | tr -d '\n')
        fi
        if [ -z "$target_wall" ] || [ ! -f "$target_wall" ]; then
            target_wall="$HOME/.local/state/wallpaper/current"
        fi
    fi

    if [ ! -f "$target_wall" ]; then
        notify-send "Matugen" "No se encontró fondo de pantalla activo para extraer colores."
        return 1
    fi

    if ! command -v matugen &>/dev/null; then
        notify-send "Matugen" "El paquete 'matugen' no está instalado en el PATH."
        return 1
    fi

    # Extraer paleta en formato JSON con matugen (~30ms)
    local matugen_raw
    matugen_raw=$(matugen image "$target_wall" --dry-run --json hex 2>/dev/null)

    if [ -z "$matugen_raw" ]; then
        notify-send "Matugen" "Error al procesar los colores del fondo."
        return 1
    fi

    # Mapear colores de Material You a variables base16
    local base00 base01 base02 base03 base04 base05 base06 base07
    local base08 base09 base0A base0B base0C base0D base0E base0F

    base00=$(echo "$matugen_raw" | jq -r '.colors.dark.surface // "#121212"')
    base01=$(echo "$matugen_raw" | jq -r '.colors.dark.surface_container // "#1e1e1e"')
    base02=$(echo "$matugen_raw" | jq -r '.colors.dark.surface_container_high // "#282828"')
    base03=$(echo "$matugen_raw" | jq -r '.colors.dark.outline // "#484848"')
    base04=$(echo "$matugen_raw" | jq -r '.colors.dark.on_surface_variant // "#c0c0c0"')
    base05=$(echo "$matugen_raw" | jq -r '.colors.dark.on_surface // "#e0e0e0"')
    base06=$(echo "$matugen_raw" | jq -r '.colors.dark.on_primary // "#ffffff"')
    base07=$(echo "$matugen_raw" | jq -r '.colors.dark.secondary // "#89b4fa"')
    base08=$(echo "$matugen_raw" | jq -r '.colors.dark.error // "#f38ba8"')
    base09=$(echo "$matugen_raw" | jq -r '.colors.dark.tertiary // "#fab387"')
    base0A=$(echo "$matugen_raw" | jq -r '.colors.dark.primary_container // "#f9e2af"')
    base0B=$(echo "$matugen_raw" | jq -r '.colors.dark.secondary_container // "#a6e3a1"')
    base0C=$(echo "$matugen_raw" | jq -r '.colors.dark.tertiary_container // "#94e2d5"')
    base0D=$(echo "$matugen_raw" | jq -r '.colors.dark.primary // "#89b4fa"')
    base0E=$(echo "$matugen_raw" | jq -r '.colors.dark.inverse_primary // "#cba6f7"')
    base0F=$(echo "$matugen_raw" | jq -r '.colors.dark.scrim // "#000000"')

    apply_palette "$base00" "$base01" "$base02" "$base03" "$base04" "$base05" "$base06" "$base07" \
                  "$base08" "$base09" "$base0A" "$base0B" "$base0C" "$base0D" "$base0E" "$base0F" \
                  "matugen-wallpaper" "Wallpaper Dinámico (Matugen)"
}

case "$ACTION" in
    "wallpaper"|"matugen")
        apply_matugen_wallpaper "$2"
        ;;

    "next")
        ACTIVE_ID=$(jq -r '.active_theme' "$CONFIG_FILE")
        THEMES_COUNT=$(jq '.themes | length' "$CONFIG_FILE")
        
        CURRENT_INDEX=0
        for i in $(seq 0 $((THEMES_COUNT - 1))); do
            ID=$(jq -r ".themes[$i].id" "$CONFIG_FILE")
            if [ "$ID" = "$ACTIVE_ID" ]; then
                CURRENT_INDEX=$i
                break
            fi
        done

        NEXT_INDEX=$(( (CURRENT_INDEX + 1) % THEMES_COUNT ))
        NEXT_ID=$(jq -r ".themes[$NEXT_INDEX].id" "$CONFIG_FILE")
        NEXT_SCHEME=$(jq -r ".themes[$NEXT_INDEX].scheme" "$CONFIG_FILE")
        NEXT_NAME=$(jq -r ".themes[$NEXT_INDEX].name" "$CONFIG_FILE")

        apply_theme "$NEXT_ID" "$NEXT_SCHEME" "$NEXT_NAME"
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

        SELECTED=$(echo -e -n "$THEME_OPTIONS" | rofi -dmenu -p "󰔎 Seleccionar Tema" -theme "$ROFI_CONFIG" -theme-str 'window { width: 480px; }')

        if [ -n "$SELECTED" ]; then
            if [[ "$SELECTED" == *"Matugen"* ]]; then
                apply_matugen_wallpaper
            else
                SELECTED_NAME=$(echo "$SELECTED" | sed -E 's/^[^ ]+ +//')
                for i in $(seq 0 $((THEMES_COUNT - 1))); do
                    NAME=$(jq -r ".themes[$i].name" "$CONFIG_FILE")
                    if [ "$NAME" = "$SELECTED_NAME" ]; then
                        ID=$(jq -r ".themes[$i].id" "$CONFIG_FILE")
                        SCHEME=$(jq -r ".themes[$i].scheme" "$CONFIG_FILE")
                        apply_theme "$ID" "$SCHEME" "$NAME"
                        break
                    fi
                done
            fi
        fi
        ;;

    *)
        if [ "$ACTION" = "init" ]; then
            ACTIVE_ID=$(jq -r '.active_theme' "$CONFIG_FILE")
            if [ "$ACTIVE_ID" = "matugen-wallpaper" ]; then
                apply_matugen_wallpaper
            else
                THEMES_COUNT=$(jq '.themes | length' "$CONFIG_FILE")
                for i in $(seq 0 $((THEMES_COUNT - 1))); do
                    ID=$(jq -r ".themes[$i].id" "$CONFIG_FILE")
                    if [ "$ID" = "$ACTIVE_ID" ]; then
                        SCHEME=$(jq -r ".themes[$i].scheme" "$CONFIG_FILE")
                        NAME=$(jq -r ".themes[$i].name" "$CONFIG_FILE")
                        apply_theme "$ID" "$SCHEME" "$NAME"
                        break
                    fi
                done
            fi
        else
            echo "Uso: $0 {next|menu|init|wallpaper [path]}"
            exit 1
        fi
        ;;
esac
