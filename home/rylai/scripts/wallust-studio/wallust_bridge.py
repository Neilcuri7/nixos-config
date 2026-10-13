import os
import subprocess
from pathlib import Path
from typing import Optional, Dict, Any

def get_current_wallpaper() -> Optional[str]:
    state_dir = Path.home() / ".local" / "state" / "wallpaper"
    path_txt = state_dir / "current_path.txt"
    if path_txt.exists():
        with open(path_txt, 'r') as f:
            return f.read().strip()
            
    current_symlink = state_dir / "current"
    if current_symlink.exists():
        return str(current_symlink.resolve())
        
    return None

def apply_wallust_theme(palette_json_path: str, config_path: Optional[str] = None):
    cmd = ["wallust", "cs", "-f", "pywal", palette_json_path]
    if config_path:
        cmd.extend(["-C", config_path])
    
    subprocess.run(cmd, check=True)
