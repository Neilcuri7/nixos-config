#!/usr/bin/env bash

# ==============================================================================
# SCRIPT DE CAMBIO DE TEMAS DINÁMICO (~/.config/themes.json + tinty)
# ==============================================================================
# Este script lee la configuración de temas desde ~/.config/themes.json
# y aplica el esquema de colores correspondiente usando tinty o cambiando
# la paleta en tiempo real.
# ==============================================================================

CONFIG_FILE="$HOME/.config/themes.json"

if [ ! -f "$CONFIG_FILE" ]; then
    notify-send "Gestor de Temas" "No se encontró $CONFIG_FILE"
    exit 1
fi

ACTION="$1"

# Función para aplicar un tema según su objeto JSON
apply_theme() {
    local theme_id="$1"
    local scheme="$2"
    local name="$3"

    # 1. Aplicar esquema con tinty si está disponible
    if command -v tinty &>/dev/null; then
        tinty apply "$scheme" &>/dev/null
    fi

    # 2. Actualizar el tema activo en ~/.config/themes.json usando jq
    if command -v jq &>/dev/null; then
        tmp=$(mktemp)
        jq --arg id "$theme_id" '.active_theme = $id' "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    fi

    # 3. Notificación de cambio de tema
    notify-send "Tema cambiado" "Tema actual: $name ($scheme)" -i preferences-desktop-theme
}

case "$ACTION" in
    "next")
        # Cambiar al siguiente tema en la lista de forma cíclica (para el botón de AGS)
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
        # Mostrar menú Rofi para seleccionar tema manualmente
        ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
        
        # Generar lista de temas para Rofi
        THEME_OPTIONS=""
        THEMES_COUNT=$(jq '.themes | length' "$CONFIG_FILE")
        for i in $(seq 0 $((THEMES_COUNT - 1))); do
            NAME=$(jq -r ".themes[$i].name" "$CONFIG_FILE")
            ICON=$(jq -r ".themes[$i].icon" "$CONFIG_FILE")
            THEME_OPTIONS="${THEME_OPTIONS}${ICON}  ${NAME}\n"
        done

        SELECTED=$(echo -e -n "$THEME_OPTIONS" | rofi -dmenu -p "󰔎 Seleccionar Tema" -theme "$ROFI_CONFIG" -theme-str 'window { width: 450px; }')

        if [ -n "$SELECTED" ]; then
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
        ;;

    *)
        echo "Uso: $0 {next|menu}"
        exit 1
        ;;
esac
