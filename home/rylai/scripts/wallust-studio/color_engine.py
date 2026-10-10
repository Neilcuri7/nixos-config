import colorsys
import json
from dataclasses import dataclass, asdict
from typing import Dict, Any, Tuple, Optional

try:
    from coloraide import Color
    HAS_COLORAIDE = True
except ImportError:
    HAS_COLORAIDE = False

def hex_to_rgb(hex_color: str) -> Tuple[float, float, float]:
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16)/255.0 for i in (0, 2, 4)) # type: ignore

def rgb_to_hex(r: float, g: float, b: float) -> str:
    return '#{:02x}{:02x}{:02x}'.format(int(r*255), int(g*255), int(b*255))

@dataclass
class ColorPalette:
    background: str
    foreground: str
    cursor: str
    color0: str
    color1: str
    color2: str
    color3: str
    color4: str
    color5: str
    color6: str
    color7: str
    color8: str
    color9: str
    color10: str
    color11: str
    color12: str
    color13: str
    color14: str
    color15: str

    def to_dict(self) -> Dict[str, str]:
        return asdict(self)
    
    def to_css_vars(self) -> str:
        lines = []
        for key, val in self.to_dict().items():
            lines.append(f"--{key}: {val};")
        return "\n".join(lines)
    
    def to_wallust_json(self) -> str:
        return json.dumps({
            "special": {
                "background": self.background,
                "foreground": self.foreground,
                "cursor": self.cursor
            },
            "colors": {
                "color0": self.color0,
                "color1": self.color1,
                "color2": self.color2,
                "color3": self.color3,
                "color4": self.color4,
                "color5": self.color5,
                "color6": self.color6,
                "color7": self.color7,
                "color8": self.color8,
                "color9": self.color9,
                "color10": self.color10,
                "color11": self.color11,
                "color12": self.color12,
                "color13": self.color13,
                "color14": self.color14,
                "color15": self.color15
            }
        }, indent=2)
    
    def adjust_color(self, hex_color: str, l_factor: float = 1.0, c_factor: float = 1.0) -> str:
        if HAS_COLORAIDE:
            try:
                c = Color(hex_color)
                oklch = c.convert('oklch')
                oklch['l'] = max(0.0, min(1.0, oklch['l'] * l_factor))
                oklch['c'] = max(0.0, oklch['c'] * c_factor)
                return oklch.convert('srgb').to_string(hex=True)
            except Exception:
                pass
                
        # Fallback math (HSL)
        r, g, b = hex_to_rgb(hex_color)
        h, l, s = colorsys.rgb_to_hls(r, g, b)
        l = max(0.0, min(1.0, l * l_factor))
        s = max(0.0, min(1.0, s * c_factor))
        r, g, b = colorsys.hls_to_rgb(h, l, s)
        return rgb_to_hex(r, g, b)

    def adjust_lightness(self, factor: float):
        for key, val in self.to_dict().items():
            setattr(self, key, self.adjust_color(val, l_factor=factor))

    def adjust_chroma(self, factor: float):
        for key, val in self.to_dict().items():
            setattr(self, key, self.adjust_color(val, c_factor=factor))

    def adjust_contrast(self, factor: float):
        # Simplistic contrast: adjust lightness from center (0.5)
        for key, val in self.to_dict().items():
            r, g, b = hex_to_rgb(val)
            h, l, s = colorsys.rgb_to_hls(r, g, b)
            new_l = 0.5 + (l - 0.5) * factor
            new_l = max(0.0, min(1.0, new_l))
            r2, g2, b2 = colorsys.hls_to_rgb(h, new_l, s)
            setattr(self, key, rgb_to_hex(r2, g2, b2))

    def override_accents(self, primary: Optional[str] = None, secondary: Optional[str] = None):
        if primary:
            self.color4 = primary
            self.color12 = primary
        if secondary:
            self.color5 = secondary
            self.color13 = secondary

    def create_adjusted_copy(
        self,
        brightness_val: float = 0,
        saturation_val: float = 0,
        contrast_val: float = 0,
        hue_shift_val: float = 0,
        temperature_val: float = 0,
    ) -> "ColorPalette":
        l_fac = max(0.0, 1.0 + (brightness_val / 100.0))
        c_fac = max(0.0, 1.0 + (saturation_val / 100.0))
        cont_fac = max(0.1, 1.0 + (contrast_val / 50.0))

        d = self.to_dict()
        new_dict = {}
        for k, v in d.items():
            r, g, b = hex_to_rgb(v)
            h, l, s = colorsys.rgb_to_hls(r, g, b)

            # Hue shift (smooth rotation)
            if hue_shift_val != 0:
                h = (h + (hue_shift_val / 360.0)) % 1.0

            # Color temperature (warm adds red/yellow, cool adds blue/cyan)
            if temperature_val != 0:
                temp_fac = temperature_val / 200.0
                r = min(1.0, max(0.0, r + temp_fac))
                b = min(1.0, max(0.0, b - temp_fac))
                h, l, s = colorsys.rgb_to_hls(r, g, b)

            # Lightness & Saturation factors
            l = max(0.0, min(1.0, l * l_fac))
            s = max(0.0, min(1.0, s * c_fac))

            # Contrast factor
            l = 0.5 + (l - 0.5) * cont_fac
            l = max(0.0, min(1.0, l))

            r2, g2, b2 = colorsys.hls_to_rgb(h, l, s)
            new_dict[k] = rgb_to_hex(r2, g2, b2)
        return ColorPalette(**new_dict)

def load_current_palette() -> ColorPalette:
    from pathlib import Path
    kitty_theme = Path.home() / ".config" / "kitty" / "current-theme.conf"
    defaults = {
        "background": "#1e1e2e",
        "foreground": "#cdd6f4",
        "cursor": "#f5e0dc",
        "color0": "#45475a",
        "color1": "#f38ba8",
        "color2": "#a6e3a1",
        "color3": "#f9e2af",
        "color4": "#89b4fa",
        "color5": "#f5c2e7",
        "color6": "#94e2d5",
        "color7": "#bac2de",
        "color8": "#585b70",
        "color9": "#f38ba8",
        "color10": "#a6e3a1",
        "color11": "#f9e2af",
        "color12": "#89b4fa",
        "color13": "#f5c2e7",
        "color14": "#94e2d5",
        "color15": "#a6adc8",
    }
    if kitty_theme.exists():
        try:
            with open(kitty_theme, 'r') as f:
                for line in f:
                    parts = line.strip().split()
                    if len(parts) >= 2:
                        key, val = parts[0], parts[1]
                        if key in defaults:
                            defaults[key] = val if val.startswith('#') else f"#{val}"
        except Exception:
            pass
    return ColorPalette(**defaults)
