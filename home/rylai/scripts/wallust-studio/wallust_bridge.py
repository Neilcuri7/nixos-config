import json
import os
import subprocess
import tempfile
from pathlib import Path
from typing import Optional, Dict, Any

_PALETTE_KEYS = ["background", "foreground", "cursor"] + [f"color{i}" for i in range(16)]

def get_current_wallpaper() -> Optional[str]:
    state_dir = Path.home() / ".local" / "state" / "wallpaper"
    path_txt = state_dir / "current_path.txt"
    if path_txt.exists():
        with open(path_txt, 'r') as f:
            return f.read().strip()
    return None

def apply_wallust_theme(palette_json_path: str, config_path: Optional[str] = None):
    cmd = ["wallust", "cs", "-f", "pywal", palette_json_path]
    if config_path:
        cmd.extend(["-C", config_path])
    
    subprocess.run(cmd, check=True)

def _config_without_templates(text: str) -> str:
    kept = []
    skipping = False
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("["):
            skipping = stripped == "[templates]"
        if not skipping:
            kept.append(line)
    return "\n".join(kept)

def generate_base_palette(image_path: str, user_config: Optional[Path] = None) -> Dict[str, str]:
    """Colores que Wallust genera del wallpaper con la configuración del usuario,
    sin plantillas ni secuencias de terminal y sin tocar la caché real."""
    if user_config is None:
        user_config = Path.home() / ".config" / "wallust" / "wallust.toml"
    user_text = Path(user_config).read_text() if Path(user_config).exists() else ""

    with tempfile.TemporaryDirectory() as tmp:
        tmp_dir = Path(tmp)
        template = tmp_dir / "palette.json.tmpl"
        target = tmp_dir / "palette.json"
        cfg = tmp_dir / "wallust.toml"

        template.write_text("{" + ", ".join(f'"{k}": "{{{{{k}}}}}"' for k in _PALETTE_KEYS) + "}\n")
        cfg.write_text(
            _config_without_templates(user_text).rstrip("\n")
            + f'\n\n[templates]\nstudio = {{ template = "{template}", target = "{target}" }}\n'
        )

        subprocess.run(["wallust", "run", image_path, "-C", str(cfg), "-s", "-q", "-n"], check=True)
        if not target.exists():
            raise RuntimeError("wallust no generó la paleta")
        with open(target) as f:
            data = json.load(f)
    return {k: v.lower() for k, v in data.items()}
