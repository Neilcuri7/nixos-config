#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
STATE_DIR="$HOME/.local/state/wallpaper"
CURRENT_PATH_FILE="$STATE_DIR/current_path.txt"
CURRENT_WALLPAPER="$STATE_DIR/current"
MATUGEN_CONFIG="$HOME/.config/matugen/config.toml"

mkdir -p "$STATE_DIR" "$WALLPAPER_DIR"

# Función para recargar todas las aplicaciones en caliente sin sobrecosto de CPU
reload_environment() {
    # 1. Recargar bordes y reglas de Hyprland
    if command -v hyprctl &>/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl reload &>/dev/null || true
    fi

    # 2. Recargar instancias de Kitty abiertas vía señal SIGUSR1
    killall -SIGUSR1 kitty 2>/dev/null || true

    # 3. Recargar estilos CSS de Waybar vía señal SIGUSR2
    killall -SIGUSR2 waybar 2>/dev/null || true

    # 4. Recargar estilos de SwayNC
    if command -v swaync-client &>/dev/null; then
        swaync-client --reload-css &>/dev/null || true
    fi
}

# Función central para aplicar un wallpaper
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

    # Guardar estado de forma atómica
    printf "%s" "$full_path" > "$CURRENT_PATH_FILE.tmp" && mv "$CURRENT_PATH_FILE.tmp" "$CURRENT_PATH_FILE"
    cp -L "$full_path" "$CURRENT_WALLPAPER.tmp" 2>/dev/null && mv "$CURRENT_WALLPAPER.tmp" "$CURRENT_WALLPAPER"

    # Iniciar swaybg con reemplazo suave para evitar parpadeos negros
    local old_pids
    old_pids=$(pgrep swaybg || true)
    swaybg -i "$full_path" -m fill &
    local new_pid=$!

    if [ -n "$old_pids" ]; then
        (sleep 0.15 && for pid in $old_pids; do [ "$pid" != "$new_pid" ] && kill "$pid" 2>/dev/null || true; done) &
    fi

    # Generar paleta dinámica con Matugen (~20ms)
    if command -v matugen &>/dev/null && [ -f "$MATUGEN_CONFIG" ]; then
        matugen image "$full_path" -c "$MATUGEN_CONFIG" &>/dev/null || true
    fi

    # Actualizar estado de temas si existe themes.json
    local themes_config="$HOME/.config/themes.json"
    if [ -f "$themes_config" ] && command -v jq &>/dev/null; then
        local tmp
        tmp=$(mktemp)
        jq '.active_theme = "matugen-wallpaper"' "$themes_config" > "$tmp" 2>/dev/null && mv "$tmp" "$themes_config"
    fi

    # Recargar componentes en caliente
    reload_environment

    if command -v notify-send &>/dev/null; then
        notify-send "Fondo de Pantalla" "Paleta sincronizada en caliente" -i preferences-desktop-wallpaper &>/dev/null || true
    fi
}

# Función para restaurar el fondo al iniciar sesión (usado en exec-once)
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
        # Iniciar swaybg
        local old_pids
        old_pids=$(pgrep swaybg || true)
        swaybg -i "$wall_to_set" -m fill &
        local new_pid=$!

        if [ -n "$old_pids" ]; then
            (sleep 0.15 && for pid in $old_pids; do [ "$pid" != "$new_pid" ] && kill "$pid" 2>/dev/null || true; done) &
        fi

        # Si aún no existen los archivos de colores, generarlos
        if [ ! -f "$HOME/.config/waybar/colors.css" ] && command -v matugen &>/dev/null && [ -f "$MATUGEN_CONFIG" ]; then
            matugen image "$wall_to_set" -c "$MATUGEN_CONFIG" &>/dev/null || true
            reload_environment
        fi
    fi
}

# Función para seleccionar wallpaper con interfaz Rofi ligera con miniaturas
select_wallpaper() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        notify-send "Wallpapers" "Directorio no encontrado: $WALLPAPER_DIR"
        exit 1
    fi

    list_walls() {
        cd "$WALLPAPER_DIR" || exit 1
        shopt -s nullglob
        for file in *.{jpg,jpeg,png,webp,gif}; do
            [[ -f "$file" ]] || continue
            echo -e "$file\0icon\x1f$WALLPAPER_DIR/$file"
        done
        shopt -u nullglob
    }

    local rofi_theme_str='
        window {
            width: 75%;
            height: 70%;
            border-radius: 16px;
        }
        listview {
            columns: 4;
            lines: 2;
            spacing: 12px;
            padding: 10px;
            cycle: true;
        }
        element {
            orientation: vertical;
            padding: 8px;
            border-radius: 12px;
        }
        element-icon {
            size: 180px;
            horizontal-align: 0.5;
        }
        element-text {
            horizontal-align: 0.5;
            vertical-align: 0.5;
            margin: 4px 0 0 0;
        }
    '

    local choice
    choice=$(list_walls | rofi -dmenu -i -show-icons -p "󰸉 Fondo de pantalla" -theme-str "$rofi_theme_str" || true)

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
