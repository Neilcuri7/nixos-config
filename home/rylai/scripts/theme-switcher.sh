#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.config/themes.json"
STATE_DIR="$HOME/.local/state/theme"
ACTIVE_THEME_FILE="$STATE_DIR/active_theme.txt"
WALLPAPER_STATE_DIR="$HOME/.local/state/wallpaper"
CURRENT_PATH_FILE="$WALLPAPER_STATE_DIR/current_path.txt"
CURRENT_WALLPAPER="$WALLPAPER_STATE_DIR/current"
MATUGEN_CONFIG="$HOME/.config/matugen/config.toml"
WALLUST_CONFIG="$HOME/.config/wallust/wallust.toml"

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
        elif command -v matugen &>/dev/null && [ -f "$MATUGEN_CONFIG" ]; then
            matugen image "$wall_path" -c "$MATUGEN_CONFIG" --mode dark --type scheme-fidelity --contrast 0.0 --source-color-index 0 || true
        fi
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

    mkdir -p "$HOME/.config/kitty" "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/swaync" "$HOME/.config/rofi" "$HOME/.config/wlogout" "$HOME/.config/micro/colorschemes" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/yazi"

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
    background:      ${base00}e8;
    input-bg:        ${base01}55;
    selected:        ${base02}50;
    selected-accent: ${base0D}30;
    accent:          ${base0D};
    border-col:      ${base03}60;
    text:            ${base05};
    placeholder:     ${base04}70;
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

/* Base GTK widgets override */
window, dialog {
    background-color: @window_bg_color;
    color: @window_fg_color;
}

.view, treeview, iconview, textview, .standard-view {
    background-color: @view_bg_color;
    color: @view_fg_color;
}

.view:selected, treeview:selected, iconview:selected, .standard-view:selected {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
}

headerbar, toolbar, .menubar, menubar {
    background-color: @headerbar_bg_color;
    color: @headerbar_fg_color;
    border-color: @borders;
}

.sidebar, .sidebar .view, treeview.sidebar, .shortcuts-pane {
    background-color: @sidebar_bg_color;
    color: @sidebar_fg_color;
}

entry, searchbar {
    background-color: @card_bg_color;
    color: @theme_text_color;
    border-color: @borders;
}

/* Thunar Specific Styling */
.thunar window,
.thunar .standard-view,
.thunar .standard-view .view,
.thunar treeview {
    background-color: @view_bg_color;
    color: @view_fg_color;
}

.thunar .sidebar,
.thunar .shortcuts-pane,
.thunar .shortcuts-pane .view {
    background-color: @sidebar_bg_color;
    color: @sidebar_fg_color;
}

.thunar .location-bar,
.thunar .path-bar-box,
.thunar entry {
    background-color: @card_bg_color;
    color: @theme_text_color;
    border-color: @borders;
}

/* Swappy Screenshot Tool Specific Styling */
#swappy-window,
#swappy-window window,
#swappy-window .view,
#swappy-window toolbar {
    background-color: @window_bg_color;
    color: @window_fg_color;
}

/* Pavucontrol Audio Mixer */
#pavucontrol-window,
.pavucontrol-window,
window#pavucontrol-window {
    background-color: @window_bg_color;
    color: @window_fg_color;
}

#pavucontrol-window notebook,
#pavucontrol-window notebook > stack {
    background-color: @view_bg_color;
}

#pavucontrol-window notebook tab {
    background-color: @card_bg_color;
    color: @theme_text_color;
    border-color: @borders;
    padding: 6px 12px;
}

#pavucontrol-window notebook tab:checked {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
}

scale highlight,
progressbar.horizontal progress,
levelbar block.filled {
    background-color: @accent_bg_color;
    border-radius: 4px;
}

scale trough,
progressbar.horizontal trough,
levelbar trough {
    background-color: @card_bg_color;
    border-radius: 4px;
}

/* System Dialogs, File Chooser (Open/Save File) & Yad */
filechooser,
filechooser .sidebar,
filechooser treeview {
    background-color: @view_bg_color;
    color: @view_fg_color;
}

filechooser .sidebar {
    background-color: @sidebar_bg_color;
    color: @sidebar_fg_color;
}

messagedialog,
dialog,
.yad-window {
    background-color: @window_bg_color;
    color: @window_fg_color;
}
EOF

    cat <<EOF > "$HOME/.config/yazi/theme.toml"
# Yazi Theme
[mgr]
cwd = { fg = "$base0D" }
hovered = { fg = "$base00", bg = "$base0D", bold = true }
preview_hovered = { underline = true }
find_keyword = { fg = "$base0E", bold = true, italic = true }
find_position = { fg = "$base0C", bg = "reset", bold = true }
marker_copied = { fg = "$base0B", bg = "$base0B" }
marker_cut = { fg = "$base08", bg = "$base08" }
marker_marked = { fg = "$base0D", bg = "$base0D" }
marker_selected = { fg = "$base0E", bg = "$base0E" }
tab_active = { fg = "$base00", bg = "$base0D" }
tab_inactive = { fg = "$base05", bg = "$base01" }
tab_width = 1
count_copied = { fg = "$base00", bg = "$base0B" }
count_cut = { fg = "$base00", bg = "$base08" }
count_selected = { fg = "$base00", bg = "$base0E" }
border_symbol = "rounded"
border_style = { fg = "$base03" }

[status]
separator_open = ""
separator_close = ""
separator_style = { fg = "$base02", bg = "$base02" }
mode_normal = { fg = "$base00", bg = "$base0D", bold = true }
mode_select = { fg = "$base00", bg = "$base0E", bold = true }
mode_unset = { fg = "$base00", bg = "$base0C", bold = true }
progress_label = { fg = "$base05", bold = true }
progress_normal = { fg = "$base0D", bg = "$base02" }
progress_error = { fg = "$base08", bg = "$base02" }
permissions_t = { fg = "$base0D" }
permissions_r = { fg = "$base0E" }
permissions_w = { fg = "$base08" }
permissions_x = { fg = "$base0B" }
permissions_s = { fg = "$base03" }

[input]
border = { fg = "$base0D" }
title = { fg = "$base0D" }
value = { fg = "$base05" }
selected = { bg = "$base02" }

[select]
border = { fg = "$base0D" }
active = { fg = "$base0D", bold = true }
inactive = { fg = "$base05" }

[tasks]
border = { fg = "$base0D" }
title = { fg = "$base0D" }
hovered = { fg = "$base0D", underline = true }

[which]
cols = 3
mask = { bg = "$base01" }
cand = { fg = "$base0D" }
rest = { fg = "$base05" }
desc = { fg = "$base03" }
separator = "  "
separator_style = { fg = "$base03" }

[completion]
border = { fg = "$base0D" }
active = { fg = "$base00", bg = "$base0D" }
inactive = { fg = "$base05" }

[filetype]
rules = [
  { url = "*/", fg = "$base0D", bold = true },
  { mime = "image/*", fg = "$base0E" },
  { mime = "video/*", fg = "$base0E" },
  { mime = "audio/*", fg = "$base0C" },
  { mime = "application/*zip", fg = "$base08" },
  { mime = "application/x-tar", fg = "$base08" },
  { mime = "application/x-bzip*", fg = "$base08" },
  { mime = "application/x-7z-compressed", fg = "$base08" },
  { mime = "application/x-rar", fg = "$base08" },
  { mime = "text/*", fg = "$base05" },
  { mime = "application/json", fg = "$base0C" },
  { mime = "application/*toml", fg = "$base0C" },
  { mime = "application/x-yaml", fg = "$base0C" },
  { mime = "application/x-executable", fg = "$base0B", bold = true },
  { mime = "application/x-shellscript", fg = "$base0B" }
]
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
    "wallpaper"|"matugen"|"wallust")
        if [ -n "${2:-}" ]; then
            "$HOME/scripts/wallpaper.sh" --set "$2"
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
            if [[ "$SELECTED" == *"Wallust"* ]] || [[ "$SELECTED" == *"Matugen"* ]]; then
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
