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
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=14, *args, **kwargs)
        self.preview_panel = preview_panel
        self.css_manager = css_manager
        self.set_margin_start(16)
        self.set_margin_end(12)
        self.set_margin_top(16)
        self.set_margin_bottom(16)
        self.add_css_class("controls-sidebar")

        self.initial_palette = load_current_palette()
        self.base_palette = self.initial_palette.create_adjusted_copy()
        self.current_palette = self.base_palette.create_adjusted_copy()
        self.color_buttons = []
        self.selected_color_idx = 4  # Default to accent color4 (Blue)
        self._updating_palette = False

        # Continuous Scrolled Area
        scrolled = Gtk.ScrolledWindow(hexpand=True, vexpand=True)
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        
        self.flow_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
        self.flow_box.set_hexpand(True)
        scrolled.set_child(self.flow_box)
        self.append(scrolled)

        # Build Unified Sections (Sugerencia A: Sin Pestañas)
        self.setup_chromatic_calibration_section()
        self.setup_ansi_matrix_section()
        self.setup_environment_section()

        # Fixed Bottom Action Bar
        self.setup_bottom_actions()

        # Connect preview panel tab change to filter relevant colors
        if hasattr(self.preview_panel, "stack"):
            self.preview_panel.stack.connect("notify::visible-child-name", self._on_preview_tab_changed)

        # Initial live preview update
        GLib.idle_add(self._update_preview)

    # ================= 1. CALIBRACIÓN CROMÁTICA =================
    def setup_chromatic_calibration_section(self):
        section = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)

        # Header
        head = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        lbl_title = Gtk.Label(label="CALIBRACIÓN CROMÁTICA", xalign=0)
        lbl_title.add_css_class("section-header-title")
        lbl_badge = Gtk.Label(label="ALG: K-MEANS++", xalign=1)
        lbl_badge.add_css_class("section-badge")
        lbl_title.set_hexpand(True)
        head.append(lbl_title)
        head.append(lbl_badge)
        section.append(head)

        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        card.add_css_class("slider-section-card")

        # Hue Shift (-180 a +180)
        self.hue_scale, self.hue_val_lbl = self._create_slider_row(
            card, "Hue Shift", -180, 180, 0, "°", self._on_adjustment_changed, default_val=0
        )

        # Temperatura (-50 a +50)
        self.temp_scale, self.temp_val_lbl = self._create_slider_row(
            card, "Temperatura (Cálido/Frío)", -50, 50, 0, "K", self._on_adjustment_changed, default_val=0
        )

        # Brillo (-50 a +50)
        self.brightness_scale, self.bright_val_lbl = self._create_slider_row(
            card, "Brillo", -50, 50, 0, "%", self._on_adjustment_changed, default_val=0
        )

        # Saturación (-50 a +50)
        self.saturation_scale, self.sat_val_lbl = self._create_slider_row(
            card, "Saturación", -50, 50, 0, "%", self._on_adjustment_changed, default_val=0
        )

        # Contraste (-50 a +50)
        self.contrast_scale, self.contrast_val_lbl = self._create_slider_row(
            card, "Contraste", -50, 50, 0, "%", self._on_adjustment_changed, default_val=0
        )

        section.append(card)
        self.flow_box.append(section)

    def _create_slider_row(self, container, label_text, min_v, max_v, cur_v, unit, callback, default_val=0):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)

        top_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        lbl = Gtk.Label(label=label_text, xalign=0)
        lbl.add_css_class("slider-label")
        lbl.set_hexpand(True)
        top_row.append(lbl)

        val_tag = Gtk.Label(label=f"{cur_v}{unit}", xalign=1)
        val_tag.add_css_class("slider-val-tag")
        top_row.append(val_tag)

        reset_btn = Gtk.Button(label="↺")
        reset_btn.add_css_class("micro-reset-btn")
        reset_btn.set_tooltip_text("Restaurar valor neutral")
        reset_btn.set_margin_start(6)
        top_row.append(reset_btn)

        scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, min_v, max_v, 1)
        scale.set_value(cur_v)
        scale.set_draw_value(False)
        scale.set_hexpand(True)

        def on_change(s):
            val = int(s.get_value())
            prefix = "+" if val > 0 and unit != "K" else ""
            val_tag.set_text(f"{prefix}{val}{unit}")
            callback(s)

        scale.connect("value-changed", on_change)
        reset_btn.connect("clicked", lambda b: scale.set_value(default_val))

        box.append(top_row)
        box.append(scale)
        container.append(box)
        return scale, val_tag

    # ================= 2. MATRIZ ANSI 16-COLOR =================
    def setup_ansi_matrix_section(self):
        section = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)

        head = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        self.ansi_title = Gtk.Label(label="MATRIZ ANSI 16-COLOR", xalign=0)
        self.ansi_title.add_css_class("section-header-title")
        self.ansi_title.set_hexpand(True)
        
        self.slot_badge = Gtk.Label(label="04 : PRIMARIO (#7aa2f7)", xalign=1)
        self.slot_badge.add_css_class("section-badge")
        head.append(self.ansi_title)
        head.append(self.slot_badge)
        section.append(head)

        grid_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        grid_card.add_css_class("swatch-grid-card")

        self.color_grid = Gtk.Grid(column_spacing=6, row_spacing=6)
        self.color_grid.set_halign(Gtk.Align.FILL)
        self.color_buttons = []

        for i in range(16):
            btn = Gtk.Button()
            btn.set_hexpand(True)
            btn.add_css_class("ansi-swatch-btn")
            btn.connect("clicked", self._on_select_color_to_edit, i)

            lbl = Gtk.Label(label=f"{i:02d}")
            lbl.add_css_class("section-header-title")
            btn.set_child(lbl)

            self.color_buttons.append(btn)
            self.color_grid.attach(btn, i % 4, i // 4, 1, 1)

        grid_card.append(self.color_grid)

        # Micro-Sliders HSL para la ranura seleccionada
        self.hsl_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.hsl_box.add_css_class("hsl-adjuster-card")

        hsl_header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        self.hsl_slot_title = Gtk.Label(label="SLOT 04 : PRIMARY ACCENT", xalign=0)
        self.hsl_slot_title.add_css_class("section-badge")
        self.hsl_slot_title.set_hexpand(True)
        self.hsl_hex_tag = Gtk.Label(label="#7aa2f7", xalign=1)
        self.hsl_hex_tag.add_css_class("slider-val-tag")
        hsl_header.append(self.hsl_slot_title)
        hsl_header.append(self.hsl_hex_tag)
        self.hsl_box.append(hsl_header)

        sliders_grid = Gtk.Grid(column_spacing=8, row_spacing=4)
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
        self.flow_box.append(section)

        self._update_color_swatches_ui()
        self._sync_single_color_sliders()

    # ================= 3. ENTORNO & COMPOSITOR =================
    def setup_environment_section(self):
        section = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)

        head = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        lbl_title = Gtk.Label(label="ENTORNO & COMPOSITOR", xalign=0)
        lbl_title.add_css_class("section-header-title")
        lbl_badge = Gtk.Label(label="WAYLAND / HYPRLAND", xalign=1)
        lbl_badge.add_css_class("section-badge")
        lbl_title.set_hexpand(True)
        head.append(lbl_title)
        head.append(lbl_badge)
        section.append(head)

        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        card.add_css_class("slider-section-card")

        self.waybar_op, self.op_val_lbl = self._create_slider_row(
            card, "Opacidad de Superficies / Waybar", 30, 100, 85, "%", self._on_env_changed, default_val=85
        )

        self.hypr_border, self.border_val_lbl = self._create_slider_row(
            card, "Ancho Borde Ventanas Hyprland", 0, 8, 2, "px", self._on_env_changed, default_val=2
        )

        section.append(card)
        self.flow_box.append(section)

    # ================= 4. ACCIONES (BOTTOM) =================
    def setup_bottom_actions(self):
        bottom_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        bottom_box.set_margin_top(6)

        row_triplet = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        row_triplet.set_homogeneous(True)

        btn_restore = Gtk.Button(label="Restaurar")
        btn_restore.add_css_class("btn-pill-secondary")
        btn_restore.connect("clicked", lambda b: self.restore_defaults())

        btn_save = Gtk.Button(label="Guardar Preset")
        btn_save.add_css_class("btn-pill-secondary")
        btn_save.connect("clicked", lambda b: self.save_preset())

        btn_cancel = Gtk.Button(label="Cancelar")
        btn_cancel.add_css_class("btn-pill-secondary")
        btn_cancel.connect("clicked", lambda b: self.cancel())

        row_triplet.append(btn_restore)
        row_triplet.append(btn_save)
        row_triplet.append(btn_cancel)
        bottom_box.append(row_triplet)

        btn_apply = Gtk.Button(label="🔄  APLICAR AL SISTEMA")
        btn_apply.add_css_class("btn-pill-primary")
        btn_apply.connect("clicked", lambda b: self.apply_to_system())
        bottom_box.append(btn_apply)

        self.append(bottom_box)

    # ================= LÓGICA DE CONTROL & REACTIVIDAD =================
    def _on_adjustment_changed(self, scale):
        if self._updating_palette:
            return
        
        hue_shift = self.hue_scale.get_value()
        temp_shift = self.temp_scale.get_value()
        brightness = self.brightness_scale.get_value()
        saturation = self.saturation_scale.get_value()
        contrast = self.contrast_scale.get_value()

        self.current_palette = self.base_palette.create_adjusted_copy(
            hue_shift=hue_shift,
            temp_shift=temp_shift,
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

            self.slot_badge.set_text(f"{self.selected_color_idx:02d} : PRIMARIO ({hex_val})")
            self.hsl_slot_title.set_text(f"SLOT {self.selected_color_idx:02d} : PRIMARY ACCENT")
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
            color_hex = getattr(self.current_palette, f"color{i}", "#888888")
            
            # Highlight selected slot
            if i == self.selected_color_idx:
                btn.add_css_class("selected-swatch")
            else:
                btn.remove_css_class("selected-swatch")

            # Inline style to color swatch button
            css_provider = Gtk.CssProvider()
            r, g, b = hex_to_rgb(color_hex)
            luminance = 0.299 * r + 0.587 * g + 0.114 * b
            txt_color = "#0a0a0f" if luminance > 0.45 else "#e4e1ef"
            btn_css = f"button {{ background-color: {color_hex}; color: {txt_color}; }}"
            css_provider.load_from_data(btn_css.encode('utf-8'))
            btn.get_style_context().add_provider(css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 150)

    def _on_select_color_to_edit(self, btn, idx):
        self.selected_color_idx = idx
        self._sync_single_color_sliders()
        self._update_color_swatches_ui()

    def _on_env_changed(self, scale):
        self._update_preview()

    def _on_preview_tab_changed(self, stack, param):
        current_tab = stack.get_visible_child_name()
        if current_tab == "waybar":
            relevant = {1, 2, 4, 5, 6, 12}
            for i, btn in enumerate(self.color_buttons):
                btn.set_opacity(1.0 if i in relevant else 0.35)
        elif current_tab == "thunar":
            relevant = {0, 4, 7, 8, 12}
            for i, btn in enumerate(self.color_buttons):
                btn.set_opacity(1.0 if i in relevant else 0.35)
        else:
            for btn in self.color_buttons:
                btn.set_opacity(1.0)
        self._update_color_swatches_ui()

    def _update_preview(self):
        palette_dict = self.current_palette.to_css_vars()
        waybar_op = self.waybar_op.get_value() / 100.0
        hypr_border = int(self.hypr_border.get_value())
        self.css_manager.update_palette_css(
            palette_dict,
            waybar_opacity=waybar_op,
            kitty_opacity=0.85,
            hypr_border_width=hypr_border
        )

    def restore_defaults(self):
        self.base_palette = self.initial_palette.create_adjusted_copy()
        self.current_palette = self.base_palette.create_adjusted_copy()
        self._updating_palette = True
        try:
            self.hue_scale.set_value(0)
            self.temp_scale.set_value(0)
            self.brightness_scale.set_value(0)
            self.saturation_scale.set_value(0)
            self.contrast_scale.set_value(0)
            self.waybar_op.set_value(85)
            self.hypr_border.set_value(2)
        finally:
            self._updating_palette = False
        self._update_color_swatches_ui()
        self._sync_single_color_sliders()
        self._update_preview()

    def save_preset(self):
        wallpaper_path = profile_manager.get_current_wallpaper()
        if wallpaper_path:
            profile_manager.save_profile(wallpaper_path, self.current_palette.to_wallust_json())

    def cancel(self):
        root = self.get_root()
        if root and hasattr(root, "close"):
            root.close()

    def apply_to_system(self):
        wallpaper_path = profile_manager.get_current_wallpaper()
        if wallpaper_path:
            profile_manager.save_profile(wallpaper_path, self.current_palette.to_wallust_json())
        system_sync.apply_and_reload(self.current_palette.to_wallust_json())
        self.cancel()
