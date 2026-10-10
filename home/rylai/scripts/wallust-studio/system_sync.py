import subprocess
import os
from typing import Optional

try:
    from .wallust_bridge import apply_wallust_theme
except (ImportError, ValueError):
    from wallust_bridge import apply_wallust_theme

def reload_waybar():
    try:
        subprocess.run(["systemctl", "--user", "restart", "waybar"], check=True)
    except subprocess.CalledProcessError:
        subprocess.run("pkill -x waybar && waybar &", shell=True)

def reload_hyprland():
    subprocess.Popen(["hyprctl", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def reload_kitty():
    subprocess.Popen(["pkill", "-USR1", "-x", "kitty"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def reload_swaync():
    subprocess.Popen(["swaync-client", "--reload-css"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def apply_papirus_folders(color: str):
    subprocess.Popen(["papirus-folders", "-C", color], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def apply_and_reload(palette_json_path: str, accent_hex: Optional[str] = None):
    """
    Applies the theme using wallust, then orchestrates a synchronized reload
    of various system components.
    """
    apply_wallust_theme(palette_json_path)
    
    if accent_hex:
        # In a complete implementation, this might map the hex to a known papirus color name
        apply_papirus_folders(accent_hex)
        
    reload_waybar()
    reload_hyprland()
    reload_kitty()
    reload_swaync()
