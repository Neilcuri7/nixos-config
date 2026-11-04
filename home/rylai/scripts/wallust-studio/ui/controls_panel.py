import os
import json
import colorsys
import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Adw, Gdk, GLib

from color_engine import ColorPalette, load_current_palette, hex_to_rgb, rgb_to_hex
import profile_manager
import wallust_bridge
import system_sync

class ControlsPanel(Gtk.Box):
    def __init__(self, preview_panel, css_manager, *args, **kwargs):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=10, *args, **kwargs)
        self.preview_panel = preview_panel
        self.css_manager = css_manager
        self.set_margin_start(12)
        self.set_margin_end(8)
        self.set_margin_top(12)
        self.set_margin_bottom(12)
        self.add_css_class("controls-sidebar")

        self.initial_palette = load_current_palette()
        self.base_palette = self.initial_palette.create_adjusted_copy()
        self.current_palette = self.base_palette.create_adjusted_copy()
        self.color_buttons = []
        self.selected_color_idx = 4  # Default to accent color4
        self._updating_palette = False

        # Secciones Principales
        self.setup_adjustments_section()
        self.setup_ansi_matrix_section()
        self.setup_bottom_actions()

        # Carga Inicial Síncrona Garantizada
        self._update_color_swatches_ui()
        self._sync_single_color_sliders()
        self._update_preview(immediate=True)

        self.connect("realize", lambda *_: self._update_preview(immediate=True))

    # ================= 1. AJUSTES GLOBALES =================
    def setup_adjustments_section(self):
        section = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)

        lbl_title = Gtk.Label(label="AJUSTE CROMÁTICO GLOBAL", xalign=0)
        lbl_title.add_css_class("section-header-title")
        section.append(lbl_title)

        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        card.add_css_class("slider-section-card")

        # Brillo (-50 a +50)
        self.brightness_scale, self.bright_val_lbl = self._create_compact_slider_row(
            card, "Brillo", -50, 50, 0, "%", self._on_adjustment_changed
        )

        # Saturación (-50 a +50)
        self.saturation_scale, self.sat_val_lbl = self._create_compact_slider_row(
            card, "Saturación", -50, 50, 0, "%", self._on_adjustment_changed
        )

        # Contraste (-50 a +50)
        self.contrast_scale, self.contrast_val_lbl = self._create_compact_slider_row(
            card, "Contraste", -50, 50, 0, "%", self._on_adjustment_changed
        )

        section.append(card)
        self.append(section)

    def _create_compact_slider_row(self, container, label_text, min_v, max_v, cur_v, unit, callback):
        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)

        lbl = Gtk.Label(label=label_text, xalign=0)
        lbl.add_css_class("slider-label")
        lbl.set_size_request(75, -1)
        row.append(lbl)

        scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, min_v, max_v, 1)
        scale.set_value(cur_v)
        scale.set_draw_value(False)
        scale.set_hexpand(True)
        row.append(scale)

        val_tag = Gtk.Label(label=f"{cur_v}{unit}", xalign=1)
        val_tag.add_css_class("slider-val-tag")
        val_tag.set_size_request(38, -1)
        row.append(val_tag)

        reset_btn = Gtk.Button(icon_name="view-refresh-symbolic")
        reset_btn.add_css_class("micro-reset-btn")
        reset_btn.set_tooltip_text("Restaurar valor neutral")
        row.append(reset_btn)

        def on_change(s):
            val = int(s.get_value())
            prefix = "+" if val > 0 else ""
            val_tag.set_text(f"{prefix}{val}{unit}")
            callback(s)

        scale.connect("value-changed", on_change)
        reset_btn.connect("clicked", lambda b: scale.set_value(0))

        container.append(row)
        return scale, val_tag

    # ================= 2. MATRIZ ANSI 16-COLOR =================
    def setup_ansi_matrix_section(self):
        section = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)

        head = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        lbl_title = Gtk.Label(label="MATRIZ ANSI (00 - 15)", xalign=0)
        lbl_title.add_css_class("section-header-title")
        lbl_title.set_hexpand(True)

        self.slot_badge = Gtk.Label(label="04 : PRIMARIO", xalign=1)
        self.slot_badge.add_css_class("section-badge")
        head.append(lbl_title)
        head.append(self.slot_badge)
        section.append(head)

        grid_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        grid_card.add_css_class("swatch-grid-card")

        # Grilla 8x2 compacta
        self.color_grid = Gtk.Grid(column_spacing=4, row_spacing=4)
        self.color_grid.set_halign(Gtk.Align.FILL)
        self.color_buttons = []

        for i in range(16):
            btn = Gtk.Button()
            btn.set_hexpand(True)
            btn.add_css_class("ansi-swatch-btn")
            btn.add_css_class(f"ansi-color-{i}")
            btn.connect("clicked", self._on_select_color_to_edit, i)

            lbl = Gtk.Label(label=f"{i:02d}")
            btn.set_child(lbl)

            self.color_buttons.append(btn)
            self.color_grid.attach(btn, i % 8, i // 8, 1, 1)

        grid_card.append(self.color_grid)

        # Micro-Sliders HSL para el color seleccionado
        self.hsl_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        self.hsl_box.add_css_class("hsl-adjuster-card")

        hsl_header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        self.hsl_slot_title = Gtk.Label(label="SLOT 04", xalign=0)
        self.hsl_slot_title.add_css_class("section-badge")
        self.hsl_slot_title.set_hexpand(True)
        self.hsl_hex_tag = Gtk.Label(label="#7aa2f7", xalign=1)
        self.hsl_hex_tag.add_css_class("slider-val-tag")
        hsl_header.append(self.hsl_slot_title)
        hsl_header.append(self.hsl_hex_tag)
        self.hsl_box.append(hsl_header)

        sliders_grid = Gtk.Grid(column_spacing=6, row_spacing=2)
        sliders_grid.set_hexpand(True)

        # H
        self.h_lbl = Gtk.Label(label="H: 220°", xalign=0)
        self.h_lbl.add_css_class("slider-val-tag")
        self.color_hue_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 360, 1)
        self.color_hue_scale.set_draw_value(False)
        self.color_hue_scale.set_hexpand(True)
        self.color_hue_scale.connect("value-changed", self._on_single_color_slider_changed)
        sliders_grid.attach(self.h_lbl, 0, 0, 1, 1)
        sliders_grid.attach(self.color_hue_scale, 0, 1, 1, 1)

        # S
        self.s_lbl = Gtk.Label(label="S: 88%", xalign=0)
        self.s_lbl.add_css_class("slider-val-tag")
        self.color_sat_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.color_sat_scale.set_draw_value(False)
        self.color_sat_scale.set_hexpand(True)
        self.color_sat_scale.connect("value-changed", self._on_single_color_slider_changed)
        sliders_grid.attach(self.s_lbl, 1, 0, 1, 1)
        sliders_grid.attach(self.color_sat_scale, 1, 1, 1, 1)

        # L
        self.l_lbl = Gtk.Label(label="L: 73%", xalign=0)
        self.l_lbl.add_css_class("slider-val-tag")
        self.color_lum_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.color_lum_scale.set_draw_value(False)
        self.color_lum_scale.set_hexpand(True)
        self.color_lum_scale.connect("value-changed", self._on_single_color_slider_changed)
        sliders_grid.attach(self.l_lbl, 2, 0, 1, 1)
        sliders_grid.attach(self.color_lum_scale, 2, 1, 1, 1)

        self.hsl_box.append(sliders_grid)
        grid_card.append(self.hsl_box)

        section.append(grid_card)
        self.append(section)

    # ================= 3. ACCIONES =================
    def setup_bottom_actions(self):
        bottom_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        bottom_box.set_margin_top(4)

        row_pair = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        row_pair.set_homogeneous(True)

        btn_restore = Gtk.Button(label="Restaurar")
        btn_restore.add_css_class("btn-pill-secondary")
        btn_restore.connect("clicked", lambda b: self.restore_defaults())

        btn_cancel = Gtk.Button(label="Cancelar")
        btn_cancel.add_css_class("btn-pill-secondary")
        btn_cancel.connect("clicked", lambda b: self.cancel())

        row_pair.append(btn_restore)
        row_pair.append(btn_cancel)
        bottom_box.append(row_pair)

        btn_apply = Gtk.Button(label="🔄  APLICAR AL SISTEMA")
        btn_apply.add_css_class("btn-pill-primary")
        btn_apply.connect("clicked", lambda b: self.apply_to_system())
        bottom_box.append(btn_apply)

        self.append(bottom_box)

    # ================= LÓGICA DE CONTROL & REACTIVIDAD =================
    def _on_adjustment_changed(self, scale):
        if self._updating_palette:
            return
        
        brightness = self.brightness_scale.get_value()
        saturation = self.saturation_scale.get_value()
        contrast = self.contrast_scale.get_value()

        self.current_palette = self.base_palette.create_adjusted_copy(
            brightness=brightness,
            saturation=saturation,
            contrast=contrast
        )
        self._update_color_swatches_ui()
        self._sync_single_color_sliders()
        self._update_preview()

    def _on_single_color_slider_changed(self, scale):
        if self._updating_palette:
            return

        h = self.color_hue_scale.get_value() / 360.0
        s = self.color_sat_scale.get_value() / 100.0
        l = self.color_lum_scale.get_value() / 100.0

        r, g, b = colorsys.hls_to_rgb(h, l, s)
        new_hex = rgb_to_hex(r, g, b)

        setattr(self.current_palette, f"color{self.selected_color_idx}", new_hex)
        setattr(self.base_palette, f"color{self.selected_color_idx}", new_hex)

        self._update_color_swatches_ui()
        self._sync_single_color_sliders(skip_sliders=True)
        self._update_preview()

    def _sync_single_color_sliders(self, skip_sliders=False):
        self._updating_palette = True
        try:
            hex_val = getattr(self.current_palette, f"color{self.selected_color_idx}", "#7aa2f7")
            r, g, b = hex_to_rgb(hex_val)
            h, l, s = colorsys.rgb_to_hls(r, g, b)

            h_deg = int(h * 360)
            s_pct = int(s * 100)
            l_pct = int(l * 100)

            self.slot_badge.set_text(f"{self.selected_color_idx:02d} : {hex_val}")
            self.hsl_slot_title.set_text(f"SLOT {self.selected_color_idx:02d}")
            self.hsl_hex_tag.set_text(hex_val)

            self.h_lbl.set_text(f"H: {h_deg}°")
            self.s_lbl.set_text(f"S: {s_pct}%")
            self.l_lbl.set_text(f"L: {l_pct}%")

            if not skip_sliders:
                self.color_hue_scale.set_value(h_deg)
                self.color_sat_scale.set_value(s_pct)
                self.color_lum_scale.set_value(l_pct)
        finally:
            self._updating_palette = False

    def _update_color_swatches_ui(self):
        for i in range(16):
            btn = self.color_buttons[i]
            if i == self.selected_color_idx:
                btn.add_css_class("selected-swatch")
            else:
                btn.remove_css_class("selected-swatch")

    def _on_select_color_to_edit(self, btn, idx):
        self.selected_color_idx = idx
        self._sync_single_color_sliders()
        self._update_color_swatches_ui()

    def _update_preview(self, immediate: bool = False):
        palette_dict = self.current_palette.to_dict()
        self.css_manager.update_palette_css(palette_dict, immediate=immediate)
        self.preview_panel.update_palette(self.current_palette)
        return False

    def restore_defaults(self):
        self.base_palette = self.initial_palette.create_adjusted_copy()
        self.current_palette = self.base_palette.create_adjusted_copy()
        self._updating_palette = True
        try:
            self.brightness_scale.set_value(0)
            self.saturation_scale.set_value(0)
            self.contrast_scale.set_value(0)
        finally:
            self._updating_palette = False
        self._update_color_swatches_ui()
        self._sync_single_color_sliders()
        self._update_preview(immediate=True)

    def _get_active_wallpaper(self):
        wp = None
        if hasattr(profile_manager, "get_current_wallpaper"):
            try:
                wp = profile_manager.get_current_wallpaper()
            except Exception:
                pass
        if not wp and hasattr(wallust_bridge, "get_current_wallpaper"):
            try:
                wp = wallust_bridge.get_current_wallpaper()
            except Exception:
                pass
        return wp

    def cancel(self):
        root = self.get_root()
        if root and hasattr(root, "close"):
            root.close()

    def apply_to_system(self):
        wallpaper_path = self._get_active_wallpaper()
        if wallpaper_path:
            try:
                profile_manager.save_profile(wallpaper_path, self.current_palette.to_wallust_json())
            except Exception as e:
                print(f"[wallust-studio] Advertencia al persistir perfil de wallpaper: {e}")
        accent_hex = getattr(self.current_palette, "color4", None)
        system_sync.apply_and_reload(self.current_palette.to_wallust_json(), accent_hex=accent_hex)
        self.cancel()
