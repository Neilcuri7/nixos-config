#!/usr/bin/env bash
set -euo pipefail

# theme-sync.sh: Script centralizado para sincronizar color de carpetas y recargar componentes visuales

accent_hex="${1:-}"

# Si no se pasó acento, intentar extraerlo del archivo gtk.css
if [ -z "$accent_hex" ]; then
    gtk_css="$HOME/.config/gtk-3.0/gtk.css"
    if [ -f "$gtk_css" ]; then
        accent_hex=$(grep -E '@define-color (accent_color|theme_selected_bg_color)' "$gtk_css" 2>/dev/null | head -n 1 | grep -oE '#[0-9a-fA-F]{6}' || true)
    fi
fi

# 1. Actualizar papirus-folders según el color de acento
if command -v papirus-folders &>/dev/null; then
    color="blue"
    if [ -n "$accent_hex" ]; then
        hex="${accent_hex#\#}"
        if [ ${#hex} -eq 6 ]; then
            r_val=$((16#${hex:0:2}))
            g_val=$((16#${hex:2:2}))
            b_val=$((16#${hex:4:2}))

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
fi

# 2. Recargar GTK e iconos
if command -v gsettings &>/dev/null; then
    curr_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'" || echo "adw-gtk3-dark")
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita" &>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme "$curr_theme" &>/dev/null || true

    gsettings set org.gnome.desktop.interface icon-theme "Papirus" &>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" &>/dev/null || true
fi

# 3. Recargar Hyprland
if command -v hyprctl &>/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    hyprctl reload &>/dev/null || true
fi

# 4. Recargar Kitty
pkill -SIGUSR1 -f '(\.kitty-wrapped|bin/kitty)' 2>/dev/null || pkill -SIGUSR1 -f kitty 2>/dev/null || true

# 5. Recargar Waybar
systemctl --user restart waybar 2>/dev/null || pkill -SIGUSR2 -f waybar 2>/dev/null || true

# 6. Recargar SwayNC
if command -v swaync-client &>/dev/null; then
    swaync-client --reload-css &>/dev/null || true
fi
