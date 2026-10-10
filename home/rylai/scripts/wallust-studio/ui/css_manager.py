import gi
gi.require_version('Gtk', '4.0')

from gi.repository import Gtk, Gdk, GLib
from typing import Dict, Any

class CSSManager:
    def __init__(self):
        self.provider = Gtk.CssProvider()
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            self.provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        self._debounce_id = None

    def update_palette_css(self, palette_dict: Dict[str, str], waybar_opacity: float = 0.9, kitty_opacity: float = 0.9, hypr_border_width: int = 2):
        if self._debounce_id:
            GLib.source_remove(self._debounce_id)
        
        self._debounce_id = GLib.timeout_add(16, self._apply_palette_css, palette_dict, waybar_opacity, kitty_opacity, hypr_border_width)

    def _apply_palette_css(self, p: Dict[str, str], waybar_op: float, kitty_op: float, hypr_border: int):
        bg = p.get("background", "#1e1e2e")
        fg = p.get("foreground", "#cdd6f4")
        c0 = p.get("color0", "#45475a")
        c1 = p.get("color1", "#f38ba8")
        c2 = p.get("color2", "#a6e3a1")
        c3 = p.get("color3", "#f9e2af")
        c4 = p.get("color4", "#89b4fa")
        c5 = p.get("color5", "#f5c2e7")
        c6 = p.get("color6", "#94e2d5")
        c7 = p.get("color7", "#bac2de")
        c8 = p.get("color8", "#585b70")
        c9 = p.get("color9", "#f38ba8")
        c10 = p.get("color10", "#a6e3a1")
        c11 = p.get("color11", "#f9e2af")
        c12 = p.get("color12", "#89b4fa")
        c13 = p.get("color13", "#f5c2e7")
        c14 = p.get("color14", "#94e2d5")
        c15 = p.get("color15", "#a6adc8")

        css_str = f"""
        /* Base Wallust Studio Theme */
        .preview-term-window {{
            background-color: {bg};
            border-radius: 12px;
            border: 1px solid {c8};
            box-shadow: 0 8px 24px rgba(0,0,0,0.4);
        }}
        .term-title-btn {{ border-radius: 9999px; }}
        .term-btn-close {{ background-color: {c1}; }}
        .term-btn-min {{ background-color: {c3}; }}
        .term-btn-max {{ background-color: {c2}; }}
        .term-window-title {{ color: {c7}; font-size: 11px; font-weight: bold; }}
        .term-separator {{ background-color: {c8}; }}
        .term-prompt-text {{ color: {c4}; font-family: monospace; font-size: 13px; font-weight: bold; }}
        .term-cursor {{ background-color: {fg}; }}

        /* ANSI Grid Styles (Inspirado en la captura del usuario) */
        .ansi-grid-header {{ color: {c7}; font-family: monospace; font-size: 11px; font-weight: bold; padding: 2px 4px; }}
        .ansi-grid-row-lbl {{ color: {c8}; font-family: monospace; font-size: 11px; padding-right: 6px; }}
        .ansi-cell {{ font-family: monospace; font-size: 11px; border-radius: 4px; }}

        .cell-bg-0 {{ background-color: transparent; }}
        .cell-bg-1 {{ background-color: {c0}; }}
        .cell-bg-2 {{ background-color: {c1}; }}
        .cell-bg-3 {{ background-color: {c2}; }}
        .cell-bg-4 {{ background-color: {c3}; }}
        .cell-bg-5 {{ background-color: {c4}; }}
        .cell-bg-6 {{ background-color: {c5}; }}
        .cell-bg-7 {{ background-color: {c6}; }}
        .cell-bg-8 {{ background-color: {c7}; }}

        .cell-fg-0 {{ color: {c0}; }}
        .cell-fg-1 {{ color: {c1}; }}
        .cell-fg-2 {{ color: {c2}; }}
        .cell-fg-3 {{ color: {c3}; }}
        .cell-fg-4 {{ color: {c4}; }}
        .cell-fg-5 {{ color: {c5}; }}
        .cell-fg-6 {{ color: {c6}; }}
        .cell-fg-7 {{ color: {c7}; }}

        /* Mockup Waybar */
        .mock-waybar {{
            background-color: {bg};
            border-radius: 10px;
            padding: 4px 10px;
            border: 1px solid {c8};
        }}
        .mock-module {{
            background-color: {c0};
            border-radius: 8px;
            padding: 4px 10px;
            color: {fg};
            font-size: 12px;
        }}
        .mock-workspaces .mock-ws-btn {{
            padding: 2px 8px;
            border-radius: 6px;
            color: {c7};
        }}
        .mock-workspaces .mock-ws-btn.active {{
            background-color: {c4};
            color: {bg};
            font-weight: bold;
        }}
        .mock-clock {{
            background-color: transparent;
            font-weight: bold;
            color: {c12};
        }}

        /* Mockup Hyprland Window */
        .mock-hyprland-active-window {{
            background-color: {bg};
            border-radius: 12px;
            border: {hypr_border}px solid {c4};
            box-shadow: 0 4px 20px {c4}40;
        }}
        .mock-hypr-title {{
            color: {c4};
            font-weight: bold;
            font-size: 14px;
        }}
        .mock-sample-card {{
            background-color: {c0};
            border-radius: 8px;
            padding: 12px;
        }}
        .mock-card-heading {{ color: {c12}; font-weight: bold; font-size: 13px; }}
        .mock-file-subtext {{ color: {c7}; font-size: 11px; }}

        /* Mockup Thunar */
        .mock-thunar-window {{
            background-color: {bg};
            border-radius: 12px;
            border: 1px solid {c8};
        }}
        .mock-thunar-sidebar {{
            background-color: {bg};
        }}
        .mock-sidebar-item {{
            padding: 6px 10px;
            border-radius: 6px;
            color: {fg};
            font-size: 13px;
        }}
        .mock-sidebar-item.selected {{
            background-color: {c4}26;
            color: {c4};
            font-weight: bold;
        }}
        .mock-pathbar {{
            background-color: {c0};
            border-radius: 6px;
            padding: 4px 8px;
            color: {c7};
            font-size: 12px;
        }}
        .mock-file-card {{
            background-color: {c0};
            border-radius: 8px;
            padding: 8px;
            border: 1px solid transparent;
        }}
        .mock-file-card:hover {{
            border-color: {c4};
        }}
        .mock-folder-icon {{
            color: {c4};
            font-weight: bold;
            font-size: 13px;
        }}
        """
        self.provider.load_from_data(css_str.encode('utf-8'))
        self._debounce_id = None
        return False

