import subprocess
import os
import json
import tempfile
from typing import Optional, Union, Dict, Any

try:
    from .wallust_bridge import apply_wallust_theme
except (ImportError, ValueError):
    from wallust_bridge import apply_wallust_theme

def map_hex_to_papirus(hex_str: str) -> str:
    hex_str = hex_str.lstrip('#')
    if len(hex_str) != 6:
        return "blue"
    try:
        r = int(hex_str[0:2], 16) / 255.0
        g = int(hex_str[2:4], 16) / 255.0
        b = int(hex_str[4:6], 16) / 255.0
    except ValueError:
        return "blue"
        
    c_max = max(r, g, b)
    c_min = min(r, g, b)
    delta = c_max - c_min
    sat = 0.0 if c_max == 0 else delta / c_max
    
    if delta == 0:
        hue = 0.0
    elif c_max == r:
        hue = (60.0 * (((g - b) / delta) % 6))
    elif c_max == g:
        hue = (60.0 * (((b - r) / delta) + 2))
    else:
        hue = (60.0 * (((r - g) / delta) + 4))
    if hue < 0:
        hue += 360.0
        
    if sat < 0.12:
        return "nordic"
    elif hue >= 345 or hue < 15:
        return "red"
    elif 15 <= hue < 42:
        if hue >= 38 and c_max > 0.8:
            return "yellow"
        if c_max < 0.65:
            return "brown"
        return "orange"
    elif 42 <= hue < 70:
        return "yellow"
    elif 70 <= hue < 160:
        return "green"
    elif 160 <= hue < 190:
        return "teal"
    elif 190 <= hue < 215:
        return "cyan"
    elif 215 <= hue < 255:
        return "blue"
    elif 255 <= hue < 290:
        return "violet"
    elif 290 <= hue < 325:
        return "magenta"
    else:
        return "pink"

def reload_waybar():
    try:
        subprocess.run(["systemctl", "--user", "restart", "waybar"], check=True)
    except Exception:
        subprocess.run(["pkill", "-SIGUSR2", "-f", "waybar"], check=False)

def reload_hyprland():
    subprocess.Popen(["hyprctl", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def reload_kitty():
    subprocess.run(["pkill", "-SIGUSR1", "-f", "(\\.kitty-wrapped|bin/kitty)"], check=False)
    subprocess.run(["pkill", "-SIGUSR1", "-f", "kitty"], check=False)

def reload_swaync():
    subprocess.Popen(["swaync-client", "--reload-css"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def apply_papirus_folders(accent_hex: str):
    color_name = map_hex_to_papirus(accent_hex)
    try:
        subprocess.run(["papirus-folders", "-C", color_name, "--theme", "Papirus-Dark"], check=False)
    except Exception:
        pass

def reload_gtk():
    try:
        res = subprocess.run(["gsettings", "get", "org.gnome.desktop.interface", "gtk-theme"], capture_output=True, text=True)
        theme = res.stdout.strip().strip("'")
        if not theme:
            theme = "adw-gtk3-dark"
        
        # Forzar recarga en caliente de gtk.css para Thunar y apps GTK3/GTK4
        subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", "Adwaita"], check=False)
        subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", theme], check=False)
        
        # Forzar recarga de tema de iconos para Thunar
        subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", "Papirus"], check=False)
        subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", "Papirus-Dark"], check=False)
    except Exception:
        pass

def apply_and_reload(palette_data: Union[str, Dict[str, Any]], accent_hex: Optional[str] = None):
    """
    Applies the theme using wallust, then orchestrates a synchronized reload
    of various system components.
    """
    temp_file = None
    try:
        if isinstance(palette_data, dict):
            fd, temp_file = tempfile.mkstemp(prefix="wallust_palette_", suffix=".json")
            with os.fdopen(fd, 'w') as f:
                json.dump(palette_data, f, indent=2)
            theme_path = temp_file
        elif isinstance(palette_data, str):
            if os.path.exists(palette_data):
                theme_path = palette_data
            else:
                # Tratar como contenido JSON directamente
                fd, temp_file = tempfile.mkstemp(prefix="wallust_palette_", suffix=".json")
                with os.fdopen(fd, 'w') as f:
                    f.write(palette_data)
                theme_path = temp_file
        else:
            raise ValueError(f"Formato no compatible para la paleta: {type(palette_data)}")

        apply_wallust_theme(theme_path)
    finally:
        if temp_file and os.path.exists(temp_file):
            try:
                os.remove(temp_file)
            except OSError:
                pass
    
    if accent_hex:
        apply_papirus_folders(accent_hex)
        
    reload_gtk()
    reload_waybar()
    reload_hyprland()
    reload_kitty()
    reload_swaync()
