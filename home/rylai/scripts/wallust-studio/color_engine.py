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
