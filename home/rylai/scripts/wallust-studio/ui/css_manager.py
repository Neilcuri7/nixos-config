import gi
gi.require_version('Gtk', '4.0')

from gi.repository import Gtk, Gdk, GLib
from typing import Dict, Any

def _hex_to_rgba_css(hex_str: str, alpha: float) -> str:
    h = hex_str.lstrip('#')
    if len(h) != 6:
        return f"rgba(128, 128, 128, {alpha})"
    r = int(h[0:2], 16)
    g = int(h[2:4], 16)
    b = int(h[4:6], 16)
    return f"rgba({r}, {g}, {b}, {alpha:.2f})"

class CSSManager:
    def __init__(self):
        self.provider = Gtk.CssProvider()
        self._display_attached = False
        self._ensure_display()
        self._debounce_id = None

    def _ensure_display(self):
        if not self._display_attached:
            display = Gdk.Display.get_default()
            if display:
                # Prioridad USER + 100 (900) para garantizar que sobreescriba ~/.config/gtk-4.0/gtk.css (800)
                Gtk.StyleContext.add_provider_for_display(
                    display,
                    self.provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_USER + 100
                )
                self._display_attached = True

    def update_palette_css(self, palette_dict: Dict[str, str], immediate: bool = False):
        self._ensure_display()
        if self._debounce_id:
            GLib.source_remove(self._debounce_id)
            self._debounce_id = None
        
        if immediate:
            self._apply_palette_css(palette_dict)
        else:
            self._debounce_id = GLib.timeout_add(16, self._apply_palette_css, palette_dict)

    def _apply_palette_css(self, p: Dict[str, str]):
        self._ensure_display()
        bg = p.get("background", "#0f1016")
        fg = p.get("foreground", "#e4e1ef")
        c0 = p.get("color0", "#15161e")
        c1 = p.get("color1", "#f7768e")
        c2 = p.get("color2", "#9ece6a")
        c3 = p.get("color3", "#e0af68")
        c4 = p.get("color4", "#7aa2f7")
        c5 = p.get("color5", "#bb9af7")
        c6 = p.get("color6", "#7dcfff")
        c7 = p.get("color7", "#a9b1d6")
        c8 = p.get("color8", "#414868")
        c9 = p.get("color9", "#f7768e")
        c10 = p.get("color10", "#73daca")
        c11 = p.get("color11", "#e0af68")
        c12 = p.get("color12", "#7aa2f7")
        c13 = p.get("color13", "#bb9af7")
        c14 = p.get("color14", "#b4f9f8")
        c15 = p.get("color15", "#c0caf5")

        # Generar las 16 clases CSS para los swatches y los bloques ANSI
        swatch_rules = []
        for i in range(16):
            chex = p.get(f"color{i}", "#888888")
            h = chex.lstrip('#')
            if len(h) == 6:
                r_i = int(h[0:2], 16)
                g_i = int(h[2:4], 16)
                b_i = int(h[4:6], 16)
                lum = (0.299 * r_i + 0.587 * g_i + 0.114 * b_i) / 255.0
            else:
                lum = 0.5
            tcol = "#0a0a0f" if lum > 0.45 else "#f0f0f5"
            swatch_rules.append(
                f".ansi-color-{i} {{ background-color: {chex}; background-image: none; color: {tcol}; }}"
            )
        ansi_swatches_css = "\n".join(swatch_rules)

        css_str = f"""
        /* Ventana Principal y Marco Base */
        window.background, .app-window {{
            background-color: {bg};
            color: {fg};
        }}

        /* Panel Lateral de Controles (Izquierdo) */
        .controls-sidebar {{
            background-color: {_hex_to_rgba_css(c0, 0.85)};
            border-radius: 14px;
            padding: 12px;
            border: 1px solid {_hex_to_rgba_css(c8, 0.40)};
        }}

        .section-header-title {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 10px;
            font-weight: 700;
            color: {c7};
            letter-spacing: 0.08em;
        }}

        .section-badge {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 10px;
            font-weight: 700;
            color: {c4};
        }}

        .slider-section-card {{
            background-color: {_hex_to_rgba_css(bg, 0.70)};
            border-radius: 10px;
            padding: 8px 10px;
            border: 1px solid {_hex_to_rgba_css(c8, 0.30)};
        }}

        .slider-label {{
            font-family: 'Inter', sans-serif;
            font-size: 11px;
            color: {fg};
        }}

        .slider-val-tag {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 10.5px;
            font-weight: 700;
            color: {c4};
        }}

        .micro-reset-btn {{
            border-radius: 9999px;
            background-color: {_hex_to_rgba_css(c8, 0.35)};
            color: {fg};
            padding: 2px 4px;
            min-width: 18px;
            min-height: 18px;
            border: none;
        }}
        .micro-reset-btn:hover {{
            background-color: {_hex_to_rgba_css(c8, 0.60)};
        }}

        /* Matriz de 16 Colores ANSI */
        .swatch-grid-card {{
            background-color: {_hex_to_rgba_css(bg, 0.70)};
            border-radius: 10px;
            padding: 8px;
            border: 1px solid {_hex_to_rgba_css(c8, 0.30)};
        }}

        .ansi-swatch-btn {{
            border-radius: 6px;
            min-height: 28px;
            min-width: 32px;
            border: 1px solid rgba(255, 255, 255, 0.10);
            font-family: 'JetBrains Mono', monospace;
            font-size: 10px;
            font-weight: 700;
        }}
        .ansi-swatch-btn.selected-swatch {{
            border: 2px solid {fg};
            box-shadow: 0 0 8px {_hex_to_rgba_css(c4, 0.60)};
        }}

        {ansi_swatches_css}

        .hsl-adjuster-card {{
            background-color: {_hex_to_rgba_css(c0, 0.60)};
            border-radius: 8px;
            padding: 6px 10px;
            border: 1px solid {_hex_to_rgba_css(c8, 0.25)};
        }}

        /* Botones de Acción Inferiores */
        .btn-pill-secondary {{
            background-color: {_hex_to_rgba_css(c8, 0.35)};
            color: {fg};
            border-radius: 9999px;
            padding: 6px 12px;
            font-family: 'Inter', sans-serif;
            font-size: 11px;
            border: 1px solid {_hex_to_rgba_css(c8, 0.40)};
        }}
        .btn-pill-secondary:hover {{
            background-color: {_hex_to_rgba_css(c8, 0.55)};
        }}

        .btn-pill-primary {{
            background-color: {c4};
            color: {bg};
            border-radius: 9999px;
            padding: 8px 16px;
            font-family: 'Inter', sans-serif;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.04em;
            border: none;
        }}
        .btn-pill-primary:hover {{
            opacity: 0.90;
        }}

        /* ================= PREVISUALIZACIÓN ALL-IN-ONE ================= */
        .preview-canvas-card {{
            background-color: {_hex_to_rgba_css(c0, 0.85)};
            border-radius: 14px;
            padding: 12px;
            border: 1px solid {_hex_to_rgba_css(c8, 0.40)};
        }}

        /* 1. Mini-Waybar */
        .waybar-window {{
            background-color: transparent;
            padding: 0 2px;
        }}
        .waybar-island {{
            background-color: {_hex_to_rgba_css(c0, 0.90)};
            border: 1px solid {_hex_to_rgba_css(c12, 0.35)};
            border-radius: 14px;
            padding: 2px 8px;
        }}
        .ws-btn {{
            font-family: 'JetBrainsMono Nerd Font', monospace;
            font-size: 11px;
            font-weight: 600;
            padding: 0 4px;
            color: {fg};
        }}
        .ws-btn.active {{
            color: {c12};
            background-color: {_hex_to_rgba_css(c12, 0.20)};
            border-radius: 8px;
        }}
        .waybar-mod {{
            font-family: 'JetBrainsMono Nerd Font', monospace;
            font-size: 11px;
            font-weight: 600;
            padding: 0 4px;
            color: {fg};
        }}
        .mod-clock {{
            color: {c12};
            font-weight: bold;
        }}
        .mod-controls {{
            color: {c10};
        }}
        .mod-network {{
            color: {c12};
        }}
        .mod-battery {{
            color: {c10};
        }}

        /* 2. Mini-Terminal (Kitty) */
        .term-window-card {{
            background-color: {bg};
            border-radius: 10px;
            border: 2px solid {c4};
            box-shadow: 0 4px 16px {_hex_to_rgba_css(c4, 0.25)};
        }}

        .term-titlebar {{
            background-color: {c0};
            padding: 5px 10px;
            border-bottom: 1px solid {_hex_to_rgba_css(c8, 0.35)};
        }}
        .term-dot {{ border-radius: 9999px; min-width: 8px; min-height: 8px; }}
        .term-dot-red {{ background-color: {c1}; }}
        .term-dot-yellow {{ background-color: {c3}; }}
        .term-dot-green {{ background-color: {c2}; }}
        .term-title-text {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 10px;
            color: {c7};
        }}

        .term-body {{
            padding: 10px 12px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            color: {fg};
        }}
        .term-user-host {{ color: {c4}; font-weight: bold; }}
        .term-dir {{ color: {c3}; }}
        .term-symbol {{ color: {c5}; font-weight: bold; }}
        .term-success {{ color: {c2}; font-weight: 600; }}
        .term-error {{ color: {c1}; font-weight: 600; }}

        .code-syntax-box {{
            background-color: {_hex_to_rgba_css(c0, 0.70)};
            border-radius: 6px;
            padding: 6px 10px;
            border: 1px solid {_hex_to_rgba_css(c8, 0.30)};
        }}

        .ansi-block-cell {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 9px;
            font-weight: bold;
            padding: 2px;
            border-radius: 3px;
        }}

        /* 3. Mini-Thunar (GTK4) */
        .thunar-shell-card {{
            background-color: {bg};
            border-radius: 10px;
            border: 1px solid {_hex_to_rgba_css(c8, 0.40)};
        }}
        .thunar-sidebar {{
            background-color: {c0};
            padding: 8px;
            border-right: 1px solid {_hex_to_rgba_css(c8, 0.35)};
        }}
        .thunar-place-item {{
            padding: 4px 8px;
            border-radius: 6px;
            font-family: 'Inter', sans-serif;
            font-size: 11px;
            color: {c7};
        }}
        .thunar-place-item.active {{
            background-color: {c4};
            color: {bg};
            font-weight: 700;
        }}

        .thunar-folder-card {{
            background-color: {c0};
            border-radius: 8px;
            padding: 6px 8px;
            border: 1px solid {_hex_to_rgba_css(c8, 0.30)};
        }}
        .thunar-folder-icon {{
            color: {c4};
            font-size: 22px;
            font-family: 'JetBrainsMono Nerd Font', monospace;
        }}
        .thunar-file-icon {{
            color: {fg};
            font-size: 22px;
            font-family: 'JetBrainsMono Nerd Font', monospace;
        }}
        .thunar-item-title {{
            font-family: 'Inter', sans-serif;
            font-size: 10px;
            font-weight: 600;
            color: {fg};
        }}
        """
        try:
            self.provider.load_from_string(css_str)
        except Exception:
            self.provider.load_from_data(css_str.encode('utf-8'))
        self._debounce_id = None
        return False
