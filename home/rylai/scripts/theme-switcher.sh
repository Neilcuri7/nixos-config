#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/themes.json"
STATE_DIR="$HOME/.local/state/theme"
ACTIVE_THEME_FILE="$STATE_DIR/active_theme.txt"
WALLPAPER_STATE_DIR="$HOME/.local/state/wallpaper"
CURRENT_PATH_FILE="$WALLPAPER_STATE_DIR/current_path.txt"
CURRENT_WALLPAPER="$WALLPAPER_STATE_DIR/current"
MATUGEN_CONFIG="$HOME/.config/matugen/config.toml"

mkdir -p "$STATE_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    if command -v notify-send &>/dev/null; then
        notify-send "Gestor de Temas" "No se encontró $CONFIG_FILE"
    fi
    exit 1
fi

ACTION="${1:-menu}"

reload_environment() {
    if command -v hyprctl &>/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl reload &>/dev/null || true
    fi

    pkill -USR1 -x kitty 2>/dev/null || true
    pkill -USR2 -x waybar 2>/dev/null || true

    if command -v swaync-client &>/dev/null; then
        swaync-client --reload-css &>/dev/null || true
    fi
}

apply_matugen() {
    printf "%s" "matugen-wallpaper" > "$ACTIVE_THEME_FILE.tmp" && mv "$ACTIVE_THEME_FILE.tmp" "$ACTIVE_THEME_FILE"

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

    if [ -n "$wall_path" ] && [ -f "$wall_path" ] && command -v matugen &>/dev/null && [ -f "$MATUGEN_CONFIG" ]; then
        mkdir -p "$HOME/.config/waybar" "$HOME/.config/kitty" "$HOME/.config/hypr" "$HOME/.config/swaync" "$HOME/.config/rofi" "$HOME/.config/wlogout" "$HOME/.config/micro/colorschemes" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
        matugen image "$wall_path" -c "$MATUGEN_CONFIG" --source-color-index 0 || true
        reload_environment
    fi
}

apply_palette() {
    local base00="$1" base01="$2" base02="$3" base03="$4"
    local base04="$5" base05="$6" base06="$7" base07="$8"
    local base08="$9" base09="${10}" base0A="${11}" base0B="${12}"
    local base0C="${13}" base0D="${14}" base0E="${15}" base0F="${16}"
    local theme_id="${17}"
    local name="${18}"

    mkdir -p "$HOME/.config/kitty" "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/swaync" "$HOME/.config/rofi" "$HOME/.config/wlogout" "$HOME/.config/micro/colorschemes" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

    cat <<EOF > "$HOME/.config/hypr/colors.conf"
\$background = rgb(${base00#\#})
\$foreground = rgb(${base05#\#})
\$primary = rgb(${base0D#\#})
\$secondary = rgb(${base0E#\#})
\$tertiary = rgb(${base0C#\#})
\$error = rgb(${base08#\#})
\$surface = rgb(${base01#\#})
\$outline = rgb(${base03#\#})
EOF

    cat <<EOF > "$HOME/.config/kitty/current-theme.conf"
background            $base00
foreground            $base05
selection_background  $base02
selection_foreground  $base05
url_color             $base0D
cursor                $base05
cursor_text_color     $base00
active_border_color   $base0D
inactive_border_color $base02

color0  $base00
color1  $base08
color2  $base0B
color3  $base0A
color4  $base0D
color5  $base0E
color6  $base0C
color7  $base05

color8  $base03
color9  $base08
color10 $base0B
color11 $base0A
color12 $base0D
color13 $base0E
color14 $base0C
color15 $base07
EOF

    cat <<EOF > "$HOME/.config/waybar/colors.css"
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

    cat <<EOF > "$HOME/.config/swaync/colors.css"
@define-color cc-bg $base01;
@define-color noti-bg $base00;
@define-color noti-bg-hover $base02;
@define-color text-color $base05;
@define-color text-color-disabled $base04;
@define-color border-color $base0D;
@define-color accent-color $base0D;
EOF

    cat <<EOF > "$HOME/.config/rofi/colors.rasi"
* {
    background:      ${base00}ee;
    selected:        ${base02}dd;
    selected-accent: ${base0D}40;
    accent:          ${base0D};
    border-col:      ${base03};
    text:            ${base05};
    placeholder:     ${base04}88;
}
EOF

    cat <<EOF > "$HOME/.config/micro/colorschemes/current-theme.micro"
color-link default "$base05,default"
color-link comment "$base03,default"
color-link identifier "$base08,default"
color-link constant "$base09,default"
color-link constant.string "$base0B,default"
color-link constant.number "$base09,default"
color-link statement "$base0E,default"
color-link symbol "$base0C,default"
color-link preproc "$base0D,default"
color-link type "$base0A,default"
color-link special "$base0C,default"
color-link underlined "$base0D,default"
color-link error "bold $base08,default"
color-link todo "bold $base0A,default"
color-link statusline "$base05,$base01"
color-link tabbar "$base04,$base01"
color-link line-number "$base03,default"
color-link current-line-number "bold $base0D,default"
color-link cursor-line "$base02,default"
color-link color-column "$base02,default"
color-link divider "$base03,default"
color-link indent-char "$base03,default"
    cat <<EOF > "$HOME/.config/gtk-3.0/gtk.css"
/* GTK 3 Theme Palette */
@define-color theme_bg_color $base00;
@define-color theme_fg_color $base05;
@define-color theme_base_color $base01;
@define-color theme_text_color $base05;
@define-color theme_selected_bg_color $base0D;
@define-color theme_selected_fg_color $base00;
@define-color insensitive_bg_color $base01;
@define-color insensitive_fg_color $base03;
@define-color insensitive_base_color $base01;
@define-color theme_unfocused_bg_color $base00;
@define-color theme_unfocused_fg_color $base04;
@define-color theme_unfocused_base_color $base01;
@define-color theme_unfocused_text_color $base04;
@define-color theme_unfocused_selected_bg_color $base0D;
@define-color theme_unfocused_selected_fg_color $base00;
@define-color borders $base03;
@define-color unfocused_borders $base02;
@define-color warning_color $base0A;
@define-color error_color $base08;
@define-color success_color $base0B;

/* Libadwaita / Modern GTK */
@define-color accent_color $base0D;
@define-color accent_bg_color $base0D;
@define-color accent_fg_color $base00;
@define-color window_bg_color $base00;
@define-color window_fg_color $base05;
@define-color view_bg_color $base01;
@define-color view_fg_color $base05;
@define-color headerbar_bg_color $base00;
@define-color headerbar_fg_color $base05;
@define-color headerbar_border_color $base03;
@define-color headerbar_backdrop_color @window_bg_color;
@define-color card_bg_color $base01;
@define-color card_fg_color $base05;
@define-color card_border_color $base03;
@define-color sidebar_bg_color $base00;
@define-color sidebar_fg_color $base05;
@define-color sidebar_backdrop_color @window_bg_color;
@define-color sidebar_border_color $base03;
EOF

    cp "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css" 2>/dev/null || true
    cp "$HOME/.config/waybar/colors.css" "$HOME/.config/wlogout/colors.css" 2>/dev/null || true

    printf "%s" "$theme_id" > "$ACTIVE_THEME_FILE.tmp" && mv "$ACTIVE_THEME_FILE.tmp" "$ACTIVE_THEME_FILE"

    reload_environment
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
            apply_matugen
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
                apply_matugen
                if command -v notify-send &>/dev/null; then
                    notify-send "Gestor de Temas" "Colores dinámicos de Matugen aplicados" -i preferences-desktop-theme
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
        ACTIVE_ID="matugen-wallpaper"
        if [ -f "$ACTIVE_THEME_FILE" ]; then
            ACTIVE_ID=$(tr -d '\r\n' < "$ACTIVE_THEME_FILE" || echo "matugen-wallpaper")
        fi

        if [ "$ACTIVE_ID" = "matugen-wallpaper" ] || [ -z "$ACTIVE_ID" ]; then
            apply_matugen
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
                apply_matugen
            fi
        fi
        ;;

    *)
        echo "Uso: $0 {menu|init|wallpaper [path]}" >&2
        exit 1
        ;;
esac
