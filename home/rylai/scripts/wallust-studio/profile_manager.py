import os
import json
import hashlib
import tempfile
from pathlib import Path
from typing import Dict, Any, Optional

STATE_DIR = Path.home() / ".local" / "state" / "wallust-studio"
PROFILES_DIR = STATE_DIR / "profiles"
REGISTRY_FILE = STATE_DIR / "registry.json"

def calculate_sha256(filepath: str | Path, block_size: int = 65536) -> str:
    sha256 = hashlib.sha256()
    with open(filepath, 'rb') as f:
        for block in iter(lambda: f.read(block_size), b''):
            sha256.update(block)
    return sha256.hexdigest()

def ensure_dirs():
    PROFILES_DIR.mkdir(parents=True, exist_ok=True)

def atomic_write_json(filepath: Path, data: Dict[str, Any]):
    ensure_dirs()
    fd, temp_path = tempfile.mkstemp(dir=filepath.parent, prefix=filepath.name + ".")
    with os.fdopen(fd, 'w') as f:
        json.dump(data, f, indent=2)
    os.replace(temp_path, filepath)

def get_registry() -> Dict[str, Any]:
    if not REGISTRY_FILE.exists():
        return {}
    with open(REGISTRY_FILE, 'r') as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return {}

def save_registry(data: Dict[str, Any]):
    atomic_write_json(REGISTRY_FILE, data)

def save_profile(image_path: str, palette_data: Dict[str, Any]) -> str:
    image_file = Path(image_path)
    if not image_file.exists():
        raise FileNotFoundError(f"Image not found: {image_path}")
    
    file_hash = calculate_sha256(image_file)
    profile_file = PROFILES_DIR / f"{file_hash}.json"
    
    atomic_write_json(profile_file, palette_data)
    
    registry = get_registry()
    registry[str(image_file.absolute())] = {
        "hash": file_hash,
        "mtime": image_file.stat().st_mtime,
        "profile_file": str(profile_file)
    }
    save_registry(registry)
    
    return str(profile_file)

def garbage_collect():
    """Removes profiles whose original image files no longer exist."""
    registry = get_registry()
    valid_profiles = set()
    to_delete = []

    for img_path_str, meta in registry.items():
        if Path(img_path_str).exists():
            valid_profiles.add(meta.get("profile_file"))
        else:
            to_delete.append(img_path_str)
            
    for img_path_str in to_delete:
        del registry[img_path_str]
        
    save_registry(registry)
    
    if PROFILES_DIR.exists():
        for prof_file in PROFILES_DIR.glob("*.json"):
            if str(prof_file) not in valid_profiles:
                try:
                    prof_file.unlink()
                except OSError:
                    pass
