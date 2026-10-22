import subprocess
import os
import json
import tempfile
from pathlib import Path
from typing import Optional, Union, Dict, Any

try:
    from .wallust_bridge import apply_wallust_theme
except (ImportError, ValueError):
    from wallust_bridge import apply_wallust_theme

def sync_environment(accent_hex: Optional[str] = None):
    sync_script = Path.home() / "scripts" / "theme-sync.sh"
    cmd = [str(sync_script)]
    if accent_hex:
        cmd.append(accent_hex)
    try:
        subprocess.run(cmd, check=False)
    except Exception:
        pass

def apply_and_reload(palette_data: Union[str, Dict[str, Any]], accent_hex: Optional[str] = None):
    """
    Aplica el tema usando wallust y ejecuta la recarga sincronizada
    mediante theme-sync.sh.
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

    sync_environment(accent_hex)
