import gi
gi.require_version('Gtk', '4.0')

from gi.repository import Gtk, Gdk, GLib
from typing import Dict, Any

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
                Gtk.StyleContext.add_provider_for_display(
                    display,
                    self.provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 100
                )
                self._display_attached = True

    def update_palette_css(self, palette_dict: Dict[str, str], waybar_opacity: float = 0.85, kitty_opacity: float = 0.85, hypr_border_width: int = 2):
        self._ensure_display()
        if self._debounce_id:
            GLib.source_remove(self._debounce_id)
        
        self._debounce_id = GLib.timeout_add(16, self._apply_palette_css, palette_dict, waybar_opacity, kitty_opacity, hypr_border_width)

    def _apply_palette_css(self, p: Dict[str, str], waybar_op: float, kitty_op: float, hypr_border: int):
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

        css_str = f"""
        /* Host Canvas & Chrome Base - Nordic Minimalist Theme */
        window.background, .app-window {{
            background-color: #0a0a0f;
            color: #e4e1ef;
        }}

        /* Unified Control Panel Elements */
        .controls-sidebar {{
            background-color: #14141e;
            border-radius: 16px;
            padding: 16px;
            border: 1px solid #1f2330;
        }}

        .section-header-title {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 10px;
            font-weight: 600;
            color: #c3c6d3;
            letter-spacing: 0.08em;
        }}

        .section-badge {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 10px;
            font-weight: 600;
            color: {c4};
        }}

        .slider-section-card {{
            background-color: #1b1b25;
            border-radius: 10px;
            padding: 10px 12px;
            border: 1px solid #1f2330;
        }}

        .slider-label {{
            font-family: 'Inter', sans-serif;
            font-size: 12px;
            color: #e4e1ef;
        }}

        .slider-val-tag {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            font-weight: 600;
            color: {c4};
        }}

        .micro-reset-btn {{
            border-radius: 9999px;
            background-color: #292934;
            color: #c3c6d3;
            padding: 2px 4px;
            min-width: 20px;
            min-height: 20px;
            border: none;
        }}
        .micro-reset-btn:hover {{
            background-color: #34343f;
            color: #e4e1ef;
        }}

        /* ANSI Swatches */
        .swatch-grid-card {{
            background-color: #1b1b25;
            border-radius: 10px;
            padding: 10px;
            border: 1px solid #1f2330;
        }}

        .ansi-swatch-btn {{
            border-radius: 8px;
            min-height: 36px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            font-weight: 600;
        }}
        .ansi-swatch-btn.selected-swatch {{
            border: 2px solid {c4};
            box-shadow: 0 0 10px {c4}60;
        }}

        .hsl-adjuster-card {{
            background-color: #1b1b25;
            border-radius: 8px;
            padding: 8px 12px;
            border: 1px solid #1f2330;
        }}

        /* Action Buttons */
        .btn-pill-secondary {{
            background-color: #292934;
            color: #e4e1ef;
            border-radius: 9999px;
            padding: 6px 14px;
            font-family: 'Inter', sans-serif;
            font-size: 12px;
            border: 1px solid #1f2330;
        }}
        .btn-pill-secondary:hover {{
            background-color: #34343f;
        }}

        .btn-pill-primary {{
            background-color: {c4};
            color: #0a0a0f;
            border-radius: 9999px;
            padding: 10px 18px;
            font-family: 'Inter', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.04em;
            box-shadow: 0 4px 16px {c4}40;
            border: none;
        }}
        .btn-pill-primary:hover {{
            filter: brightness(1.1);
        }}

        /* Right Canvas & Segmented Switcher */
        .preview-canvas-card {{
            background-color: #14141e;
            border-radius: 16px;
            padding: 16px;
            border: 1px solid #1f2330;
        }}

        .tab-pill-box {{
            background-color: #0d0d17;
            border-radius: 9999px;
            padding: 4px;
        }}

        .tab-pill-btn {{
            border-radius: 9999px;
            padding: 6px 18px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            font-weight: 600;
            color: #c3c6d3;
            border: none;
            background: transparent;
        }}
        .tab-pill-btn.active {{
            background-color: #1e1e2e;
            color: #e4e1ef;
            box-shadow: 0 2px 6px rgba(0,0,0,0.3);
        }}

        /* ================= VISTA 1: TERMINAL (KITTY) ================= */
        .term-window-card {{
            background-color: #0d0d17;
            border-radius: 12px;
            border: 1px solid #1f2330;
            box-shadow: 0 8px 32px rgba(0,0,0,0.6);
        }}

        .term-titlebar {{
            background-color: #1b1b25;
            padding: 8px 14px;
            border-bottom: 1px solid #1f2330;
        }}
        .term-dot {{ border-radius: 9999px; min-width: 10px; min-height: 10px; }}
        .term-dot-red {{ background-color: {c1}; }}
        .term-dot-yellow {{ background-color: {c3}; }}
        .term-dot-green {{ background-color: {c2}; }}
        .term-title-text {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            color: #c3c6d3;
        }}

        .term-body {{
            padding: 16px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 12px;
            color: {fg};
            line-height: 1.6;
        }}
        .term-user-host {{ color: {c4}; font-weight: bold; }}
        .term-dir {{ color: {c3}; }}
        .term-symbol {{ color: {c5}; font-weight: bold; }}
        .term-success {{ color: {c2}; font-weight: 600; }}
        .term-error {{ color: {c1}; font-weight: 600; }}

        .code-syntax-box {{
            background-color: rgba(18, 18, 28, 0.7);
            border-radius: 8px;
            padding: 10px 14px;
            border: 1px solid #1f2330;
        }}
        .syntax-kw {{ color: {c5}; font-weight: bold; }}
        .syntax-fn {{ color: {c4}; }}
        .syntax-str {{ color: {c2}; }}
        .syntax-type {{ color: {c3}; }}
        .syntax-var {{ color: {c6}; }}

        .ansi-block-cell {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 10px;
            font-weight: bold;
            padding: 4px;
            border-radius: 4px;
        }}

        /* ================= VISTA 2: DESKTOP / WAYBAR REAL MOCKUP ================= */
        .waybar-window {{
            background-color: transparent;
            padding: 4px 8px;
        }}
        .modules-left,
        .modules-center,
        .modules-right {{
            background-color: rgba(21, 22, 30, {waybar_op});
            border: 1px solid rgba(122, 162, 247, 0.30);
            border-color: {c12}4d;
            border-radius: 18px;
            padding: 3px 10px;
            margin: 0 4px;
        }}
        .waybar-workspaces {{
            padding: 0;
            margin: 0 2px;
        }}
        .ws-btn {{
            font-family: 'JetBrainsMono Nerd Font', monospace;
            font-size: 13px;
            font-weight: 600;
            padding: 0 6px;
            margin: 0 2px;
            border-radius: 12px;
            color: {fg};
            background-color: transparent;
        }}
        .ws-btn.active {{
            color: {c12};
            background-color: {c12}33;
            border-radius: 12px;
            min-width: 24px;
        }}
        .waybar-mod {{
            font-family: 'JetBrainsMono Nerd Font', monospace;
            font-size: 13px;
            font-weight: 600;
            padding: 2px 8px;
            margin: 0 2px;
            border-radius: 12px;
            color: {fg};
        }}
        .mod-clock {{
            color: {c12};
            font-weight: bold;
            font-size: 14px;
        }}
        .mod-stats {{
            color: {c12};
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
        .mod-tray {{
            color: {fg};
            margin-left: 4px;
        }}

        .hypr-active-window {{
            background-color: rgba(18, 18, 28, 0.95);
            border-radius: 12px;
            border: {hypr_border}px solid {c4};
            box-shadow: 0 8px 30px {c4}40;
        }}
        .contrast-badge {{
            background-color: #292934;
            color: #e4e1ef;
            padding: 4px 12px;
            border-radius: 6px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            font-weight: 600;
        }}
        .preview-content-card {{
            background-color: #1e1e2e;
            border-radius: 10px;
            padding: 14px;
            border: 1px solid #1f2330;
        }}

        /* ================= VISTA 3: THUNAR FILES ================= */
        .thunar-shell-card {{
            background-color: #12121c;
            border-radius: 12px;
            border: 1px solid #1f2330;
        }}
        .thunar-sidebar {{
            background-color: #0d0d17;
            padding: 12px;
            border-right: 1px solid #1f2330;
        }}
        .thunar-place-item {{
            padding: 7px 12px;
            border-radius: 8px;
            font-family: 'Inter', sans-serif;
            font-size: 13px;
            color: #c3c6d3;
        }}
        .thunar-place-item.active {{
            background-color: {c4};
            color: #0a0a0f;
            font-weight: 700;
        }}
        .thunar-place-item:hover:not(.active) {{
            background-color: #1b1b25;
            color: #e4e1ef;
        }}

        .thunar-folder-card {{
            background-color: #1e1e2e;
            border-radius: 12px;
            padding: 14px;
            border: 1px solid #1f2330;
        }}
        .thunar-folder-card:hover {{
            background-color: #292934;
            border-color: {c4};
        }}
        .thunar-folder-icon {{
            color: {c4};
            font-size: 34px;
            font-family: 'JetBrainsMono Nerd Font', monospace;
        }}
        .thunar-file-icon {{
            color: #c3c6d3;
            font-size: 34px;
            font-family: 'JetBrainsMono Nerd Font', monospace;
        }}
        .thunar-item-title {{
            font-family: 'Inter', sans-serif;
            font-size: 12px;
            font-weight: 600;
            color: #e4e1ef;
        }}
        .thunar-item-subtitle {{
            font-family: 'JetBrains Mono', monospace;
            font-size: 10px;
            color: #c3c6d3;
        }}

        /* Bottom Status Pill */
        .bottom-status-pill {{
            background-color: #0d0d17;
            border-radius: 8px;
            padding: 6px 14px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            color: #c3c6d3;
            border: 1px solid #1f2330;
        }}
        """
        try:
            self.provider.load_from_string(css_str)
        except Exception:
            self.provider.load_from_data(css_str.encode('utf-8'))
        self._debounce_id = None
        return False
