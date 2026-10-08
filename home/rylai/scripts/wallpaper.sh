#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
WALLPAPER_STATE_DIR="$HOME/.local/state/wallpaper"
CURRENT_PATH_FILE="$WALLPAPER_STATE_DIR/current_path.txt"
CURRENT_WALLPAPER="$WALLPAPER_STATE_DIR/current"

THEME_STATE_DIR="$HOME/.local/state/theme"
ACTIVE_THEME_FILE="$THEME_STATE_DIR/active_theme.txt"
MATUGEN_CONFIG="$HOME/.config/matugen/config.toml"
WALLUST_CONFIG="$HOME/.config/wallust/wallust.toml"

mkdir -p "$WALLPAPER_STATE_DIR" "$WALLPAPER_DIR" "$THEME_STATE_DIR"

update_folder_color() {
    local hex="${1:-}"
    if ! command -v papirus-folders &>/dev/null; then
        return 0
    fi

    if [ -z "$hex" ]; then
        local gtk_css="$HOME/.config/gtk-3.0/gtk.css"
        if [ -f "$gtk_css" ]; then
            hex=$(grep -E '@define-color (accent_color|theme_selected_bg_color)' "$gtk_css" | head -n 1 | grep -oE '#[0-9a-fA-F]{6}' || true)
        fi
    fi

    local color="blue"
    if [ -n "$hex" ]; then
        hex="${hex#\#}"
        if [ ${#hex} -eq 6 ]; then
            local r_val=$((16#${hex:0:2}))
            local g_val=$((16#${hex:2:2}))
            local b_val=$((16#${hex:4:2}))

            color=$(awk -v r="$r_val" -v g="$g_val" -v b="$b_val" 'BEGIN {
                r_n = r / 255.0; g_n = g / 255.0; b_n = b / 255.0;
                max = (r_n > g_n ? (r_n > b_n ? r_n : b_n) : (g_n > b_n ? g_n : b_n));
                min = (r_n < g_n ? (r_n < b_n ? r_n : b_n) : (g_n < b_n ? g_n : b_n));
                delta = max - min;
                sat = (max == 0 ? 0 : delta / max);

                if (delta == 0) {
                    hue = 0;
                } else if (max == r_n) {
                    hue = 60 * (((g_n - b_n) / delta) % 6);
                } else if (max == g_n) {
                    hue = 60 * (((b_n - r_n) / delta) + 2);
                } else {
                    hue = 60 * (((r_n - g_n) / delta) + 4);
                }
                if (hue < 0) hue += 360;

                if (sat < 0.12) {
                    print "nordic";
                } else if (hue >= 345 || hue < 15) {
                    print "red";
                } else if (hue >= 15 && hue < 42) {
                    print "orange";
                } else if (hue >= 42 && hue < 70) {
                    print "yellow";
                } else if (hue >= 70 && hue < 160) {
                    print "green";
                } else if (hue >= 160 && hue < 190) {
                    print "teal";
                } else if (hue >= 190 && hue < 215) {
                    print "cyan";
                } else if (hue >= 215 && hue < 255) {
                    print "blue";
                } else if (hue >= 255 && hue < 290) {
                    print "violet";
                } else if (hue >= 290 && hue < 325) {
                    print "magenta";
                } else {
                    print "pink";
                }
            }')
        fi
    fi

    [ -z "$color" ] && color="blue"
    papirus-folders -C "$color" --theme Papirus-Dark &>/dev/null || true

    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface icon-theme "Papirus" &>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" &>/dev/null || true
    fi
}

reload_environment() {
    update_folder_color

    if command -v hyprctl &>/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl reload &>/dev/null || true
    fi

    pkill -USR1 -x kitty 2>/dev/null || true
    pkill -USR2 -x waybar 2>/dev/null || true

    if command -v swaync-client &>/dev/null; then
        swaync-client --reload-css &>/dev/null || true
    fi
}

set_wallpaper() {
    local target_wall="$1"

    if [ ! -f "$target_wall" ]; then
        if command -v notify-send &>/dev/null; then
            notify-send "Wallpapers" "No se encontró el archivo: $target_wall" -i dialog-error
        fi
        return 1
    fi

    local full_path
    full_path=$(readlink -f "$target_wall")

    printf "%s" "$full_path" > "$CURRENT_PATH_FILE.tmp" && mv "$CURRENT_PATH_FILE.tmp" "$CURRENT_PATH_FILE"
    cp -L "$full_path" "$CURRENT_WALLPAPER.tmp" 2>/dev/null && mv "$CURRENT_WALLPAPER.tmp" "$CURRENT_WALLPAPER"

    local old_pids
    old_pids=$(pgrep swaybg || true)
    swaybg -i "$full_path" -m fill &
    local new_pid=$!

    if [ -n "$old_pids" ]; then
        (sleep 0.15 && for pid in $old_pids; do [ "$pid" != "$new_pid" ] && kill "$pid" 2>/dev/null || true; done) &
    fi

    # Comprobar el tema activo
    local active_theme="wallust-wallpaper"
    if [ -f "$ACTIVE_THEME_FILE" ]; then
        active_theme=$(tr -d '\r\n' < "$ACTIVE_THEME_FILE" || echo "wallust-wallpaper")
    fi

    if [ "$active_theme" = "wallust-wallpaper" ] || [ "$active_theme" = "matugen-wallpaper" ] || [ -z "$active_theme" ]; then
        mkdir -p "$HOME/.config/waybar" "$HOME/.config/kitty" "$HOME/.config/hypr" "$HOME/.config/swaync" "$HOME/.config/rofi" "$HOME/.config/wlogout" "$HOME/.config/micro/colorschemes" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/yazi"

        if command -v wallust &>/dev/null && [ -f "$WALLUST_CONFIG" ]; then
            wallust run "$full_path" -C "$WALLUST_CONFIG" || true
        elif command -v matugen &>/dev/null && [ -f "$MATUGEN_CONFIG" ]; then
            matugen image "$full_path" -c "$MATUGEN_CONFIG" --mode dark --type scheme-fidelity --contrast 0.0 --source-color-index 0 || true
        fi

        printf "%s" "wallust-wallpaper" > "$ACTIVE_THEME_FILE"
        reload_environment
    fi
}

restore_wallpaper() {
    local wall_to_set=""

    if [ -f "$CURRENT_PATH_FILE" ]; then
        local saved
        saved=$(tr -d '\r\n' < "$CURRENT_PATH_FILE" || true)
        if [ -n "$saved" ] && [ -f "$saved" ]; then
            wall_to_set="$saved"
        fi
    fi

    if [ -z "$wall_to_set" ] && [ -f "$CURRENT_WALLPAPER" ] && [ -s "$CURRENT_WALLPAPER" ]; then
        wall_to_set="$CURRENT_WALLPAPER"
    fi

    if [ -z "$wall_to_set" ]; then
        local first_found
        first_found=$(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) 2>/dev/null | head -n 1 || true)
        if [ -n "$first_found" ]; then
            wall_to_set="$first_found"
        fi
    fi

    if [ -n "$wall_to_set" ] && [ -f "$wall_to_set" ]; then
        local old_pids
        old_pids=$(pgrep swaybg || true)
        swaybg -i "$wall_to_set" -m fill &
        local new_pid=$!

        if [ -n "$old_pids" ]; then
            (sleep 0.15 && for pid in $old_pids; do [ "$pid" != "$new_pid" ] && kill "$pid" 2>/dev/null || true; done) &
        fi
    fi
}

select_wallpaper() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        notify-send "Wallpapers" "Directorio no encontrado: $WALLPAPER_DIR"
        exit 1
    fi

    list_walls() {
        (
            cd "$WALLPAPER_DIR" || exit 1
            shopt -s nullglob nocaseglob
            for file in *.{jpg,jpeg,png,webp,gif}; do
                [[ -f "$file" ]] || continue
                printf '%s\0icon\x1f%s\n' "$file" "$WALLPAPER_DIR/$file"
            done
        )
    }

    local ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
    local rofi_theme_str='
        window {
            width: 70%;
            height: 62%;
            background-color: @background;
            border: 2px;
            border-color: @accent;
            border-radius: 20px;
            padding: 18px;
        }
        mainbox {
            spacing: 14px;
            children: [ inputbar, listview ];
        }
        inputbar {
            background-color: @input-bg;
            border: 1px;
            border-color: @border-col;
            border-radius: 12px;
            padding: 8px 14px;
            children: [ prompt, entry ];
        }
        prompt {
            text-color: @accent;
            font: "JetBrainsMono Nerd Font Bold 12";
            margin: 0 8px 0 0;
        }
        entry {
            placeholder: "Filtrar wallpaper...";
            placeholder-color: @placeholder;
            text-color: @text;
        }
        listview {
            columns: 4;
            lines: 2;
            spacing: 16px;
            padding: 10px 4px;
            cycle: true;
        }
        element {
            orientation: vertical;
            padding: 12px;
            border-radius: 14px;
            background-color: rgba(255, 255, 255, 0.03);
            border: 1px;
            border-color: transparent;
        }
        element selected {
            background-color: @selected-accent;
            border: 2px;
            border-color: @accent;
        }
        element-icon {
            size: 140px;
            horizontal-align: 0.5;
            border-radius: 10px;
        }
        element-text {
            horizontal-align: 0.5;
            vertical-align: 0.5;
            margin: 8px 0 0 0;
            text-color: @text;
            font: "JetBrainsMono Nerd Font 10.5";
        }
        element selected element-text {
            text-color: @accent;
            font: "JetBrainsMono Nerd Font Bold 10.5";
        }
    '

    local choice
    choice=$(list_walls | rofi -dmenu -i -show-icons -p "󰸉 Fondo de pantalla" -theme "$ROFI_CONFIG" -theme-str "$rofi_theme_str" || true)

    if [ -n "$choice" ]; then
        set_wallpaper "$WALLPAPER_DIR/$choice"
    fi
}

ACTION="${1:---restore}"

case "$ACTION" in
    "--restore"|"restore"|"init")
        restore_wallpaper
        ;;
    "--select"|"select"|"menu")
        select_wallpaper
        ;;
    "--set"|"set")
        if [ -n "${2:-}" ]; then
            set_wallpaper "$2"
        else
            echo "Uso: $0 --set <ruta_imagen>" >&2
            exit 1
        fi
        ;;
    *)
        if [ -f "$ACTION" ]; then
            set_wallpaper "$ACTION"
        else
            echo "Opción no reconocida: $ACTION" >&2
            echo "Uso: $0 [--restore | --select | --set <ruta>]" >&2
            exit 1
        fi
        ;;
esac
