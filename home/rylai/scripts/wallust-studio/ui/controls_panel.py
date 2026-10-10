import os
import json
import tempfile
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
        super().__init__(orientation=Gtk.Orientation.VERTICAL, *args, **kwargs)
        self.preview_panel = preview_panel
        self.css_manager = css_manager

        self.base_palette = load_current_palette()
        self.current_palette = self.base_palette.create_adjusted_copy()
        self.color_buttons = []
        self.selected_color_idx = 4  # Default to accent color4 (Blue)
        self._updating_palette = False

        # Tab view
        self.tab_view = Adw.TabView()
        self.tab_bar = Adw.TabBar(view=self.tab_view)
        
        self.append(self.tab_bar)

        # Scrolled window for content
        scrolled = Gtk.ScrolledWindow(hexpand=True, vexpand=True)
        scrolled.set_child(self.tab_view)
        
        self.append(scrolled)
        
        # Tabs
        self.setup_adjustments_tab()
        self.setup_palette_tab()
        self.setup_environment_tab()

        # Bottom action bar
        self.setup_action_bar()

        # Initial live preview update
        GLib.idle_add(self._update_preview)

    def setup_adjustments_tab(self):
        page = Adw.PreferencesPage()
        group = Adw.PreferencesGroup(title="Variación Global de Color")

        # Tonalidad / Hue Shift
        self.hue_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -180, 180, 1)
        self.hue_scale.set_value(0)
        self.hue_scale.connect("value-changed", self._on_adjustment_changed)
        self.add_scale_row(group, "Rotación de Tono (Hue)", self.hue_scale, default_val=0)

        # Temperatura (Cálido / Frío)
        self.temp_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -50, 50, 1)
        self.temp_scale.set_value(0)
        self.temp_scale.connect("value-changed", self._on_adjustment_changed)
        self.add_scale_row(group, "Temperatura (Cálido / Frío)", self.temp_scale, default_val=0)

        # Luminosidad
        self.brightness_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -100, 100, 1)
        self.brightness_scale.set_value(0)
        self.brightness_scale.connect("value-changed", self._on_adjustment_changed)
        self.add_scale_row(group, "Luminosidad / Brillo", self.brightness_scale, default_val=0)

        # Saturación
        self.saturation_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -100, 100, 1)
        self.saturation_scale.set_value(0)
        self.saturation_scale.connect("value-changed", self._on_adjustment_changed)
        self.add_scale_row(group, "Saturación / Intensidad", self.saturation_scale, default_val=0)

        # Contraste
        self.contrast_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -50, 50, 1)
        self.contrast_scale.set_value(0)
        self.contrast_scale.connect("value-changed", self._on_adjustment_changed)
        self.add_scale_row(group, "Contraste", self.contrast_scale, default_val=0)

        page.add(group)
        self.tab_view.append(page)
        self.tab_view.get_page(page).set_title("Ajustes")

    def add_scale_row(self, group, title, scale, default_val=0, reset_callback=None):
        row = Adw.ActionRow(title=title)
        scale.set_hexpand(True)
        scale.set_draw_value(True)
        
        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        box.append(scale)
        
        reset_btn = Gtk.Button(icon_name="view-refresh-symbolic")
        reset_btn.set_tooltip_text("Restaurar valor inicial")
        if reset_callback:
            reset_btn.connect("clicked", lambda b: reset_callback(scale))
        else:
            reset_btn.connect("clicked", lambda b: scale.set_value(default_val))
        box.append(reset_btn)
        
        row.add_suffix(box)
        group.add(row)

    def setup_palette_tab(self):
        page = Adw.PreferencesPage()
        
        # Grid Selector Group
        self.grid_group = Adw.PreferencesGroup(title="Seleccionar Color ANSI para Ajustar")
        self.color_grid = Gtk.Grid(column_spacing=8, row_spacing=8, halign=Gtk.Align.CENTER)
        self.color_buttons = []
        
        for i in range(16):
            btn = Gtk.Button()
            btn.set_size_request(42, 38)
            btn.connect("clicked", self._on_select_color_to_edit, i)
            
            # Label inside button
            lbl = Gtk.Label(label=str(i))
            lbl.add_css_class("ansi-btn-label")
            btn.set_child(lbl)
            
            self.color_buttons.append(btn)
            self.color_grid.attach(btn, i % 4, i // 4, 1, 1)

        self.grid_group.add(self.color_grid)
        page.add(self.grid_group)

        # Fine Tuning Group
        self.fine_group = Adw.PreferencesGroup(title="Ajuste Continuo de Color (Sin saltos)")
        
        self.color_name_row = Adw.ActionRow(title="Color Seleccionado", subtitle="Color 4 (Acento Principal)")
        
        # Color preview indicator
        self.color_indicator = Gtk.Box()
        self.color_indicator.set_size_request(28, 28)
        self.color_name_row.add_prefix(self.color_indicator)
        self.fine_group.add(self.color_name_row)

        # Sliders for individual color with reset to initial color values
        self.color_hue_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 360, 1)
        self.color_hue_scale.connect("value-changed", self._on_single_color_slider_changed)
        self.add_scale_row(self.fine_group, "Tono (Hue 0° - 360°)", self.color_hue_scale, reset_callback=self._reset_single_color_hue)

        self.color_sat_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.color_sat_scale.connect("value-changed", self._on_single_color_slider_changed)
        self.add_scale_row(self.fine_group, "Saturación (0% - 100%)", self.color_sat_scale, reset_callback=self._reset_single_color_sat)

        self.color_lum_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.color_lum_scale.connect("value-changed", self._on_single_color_slider_changed)
        self.add_scale_row(self.fine_group, "Luminosidad (0% - 100%)", self.color_lum_scale, reset_callback=self._reset_single_color_lum)

        page.add(self.fine_group)
        self.tab_view.append(page)
        self.tab_view.get_page(page).set_title("Paleta")

        # Connect preview panel tab change to filter relevant colors
        if hasattr(self.preview_panel, "stack"):
            self.preview_panel.stack.connect("notify::visible-child-name", self._on_preview_tab_changed)

        self._update_color_swatches_ui()
        self._sync_single_color_sliders()

    def _reset_single_color_hue(self, scale):
        hex_val = getattr(self.base_palette, f"color{self.selected_color_idx}", "#888888")
        r, g, b = hex_to_rgb(hex_val)
        h, l, s = colorsys.rgb_to_hls(r, g, b)
        scale.set_value(int(h * 360))

    def _reset_single_color_sat(self, scale):
        hex_val = getattr(self.base_palette, f"color{self.selected_color_idx}", "#888888")
        r, g, b = hex_to_rgb(hex_val)
        h, l, s = colorsys.rgb_to_hls(r, g, b)
        scale.set_value(int(s * 100))

    def _reset_single_color_lum(self, scale):
        hex_val = getattr(self.base_palette, f"color{self.selected_color_idx}", "#888888")
        r, g, b = hex_to_rgb(hex_val)
        h, l, s = colorsys.rgb_to_hls(r, g, b)
        scale.set_value(int(l * 100))

    def setup_environment_tab(self):
        page = Adw.PreferencesPage()
        group = Adw.PreferencesGroup(title="Entorno y Opacidad")

        self.waybar_op = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 10, 100, 1)
        self.waybar_op.set_value(90)
        self.waybar_op.connect("value-changed", self._on_env_changed)
        self.add_scale_row(group, "Waybar Opacidad", self.waybar_op, default_val=90)

        self.kitty_op = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 10, 100, 1)
        self.kitty_op.set_value(80)
        self.kitty_op.connect("value-changed", self._on_env_changed)
        self.add_scale_row(group, "Kitty Opacidad", self.kitty_op, default_val=80)
        
        self.hypr_border = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 10, 1)
        self.hypr_border.set_value(2)
        self.hypr_border.connect("value-changed", self._on_env_changed)
        self.add_scale_row(group, "Grosor Borde Hyprland", self.hypr_border, default_val=2)

        page.add(group)
        self.tab_view.append(page)
        self.tab_view.get_page(page).set_title("Entorno")

    def setup_action_bar(self):
        action_bar = Gtk.ActionBar()
        
        btn_restore = Gtk.Button(label="Restaurar")
        btn_restore.connect("clicked", lambda b: self.restore_defaults())
        
        btn_save = Gtk.Button(label="Guardar Preset")
        btn_save.connect("clicked", lambda b: self.save_preset())
        
        btn_cancel = Gtk.Button(label="Cancelar")
        btn_cancel.connect("clicked", lambda b: self.cancel())
        
        btn_apply = Gtk.Button(label="Aplicar al Sistema")
        btn_apply.add_css_class("suggested-action")
        btn_apply.connect("clicked", lambda b: self.apply_to_system())
        
        action_bar.pack_start(btn_restore)
        action_bar.pack_start(btn_save)
        action_bar.pack_end(btn_apply)
        action_bar.pack_end(btn_cancel)
        
        self.append(action_bar)

    def _on_preview_tab_changed(self, stack, param):
        current_tab = stack.get_visible_child_name()
        # Filter/highlight relevant ANSI buttons according to preview tab
        if current_tab == "desktop":
            self.grid_group.set_title("Colores Relevantes: Desktop / Waybar (Borde, CPU, RAM, Audio, Batería)")
            relevant = {1, 2, 3, 4, 6, 12}
            for i, btn in enumerate(self.color_buttons):
                btn.set_opacity(1.0 if i in relevant else 0.35)
            if self.selected_color_idx not in relevant:
                self.selected_color_idx = 4
                self._sync_single_color_sliders()
        elif current_tab == "thunar":
            self.grid_group.set_title("Colores Relevantes: Thunar / Carpetas (Acento 4, Tarjetas 0/8, Texto 7)")
            relevant = {0, 4, 7, 8, 12}
            for i, btn in enumerate(self.color_buttons):
                btn.set_opacity(1.0 if i in relevant else 0.35)
            if self.selected_color_idx not in relevant:
                self.selected_color_idx = 4
                self._sync_single_color_sliders()
        else: # terminal
            self.grid_group.set_title("Seleccionar Color ANSI para Ajustar (Todos 0-15)")
            for btn in self.color_buttons:
                btn.set_opacity(1.0)
        self._update_color_swatches_ui()

    def _on_select_color_to_edit(self, btn, idx):
        self.selected_color_idx = idx
        self._sync_single_color_sliders()
        self._update_color_swatches_ui()

    def _sync_single_color_sliders(self):
        hex_val = getattr(self.current_palette, f"color{self.selected_color_idx}", "#888888")
        r, g, b = hex_to_rgb(hex_val)
        h, l, s = colorsys.rgb_to_hls(r, g, b)
        
        self._updating_palette = True
        self.color_hue_scale.set_value(int(h * 360))
        self.color_sat_scale.set_value(int(s * 100))
        self.color_lum_scale.set_value(int(l * 100))
        
        # Color description tag
        role_map = {
            0: "Fondo oscuro / Superficie",
            1: "Rojo / Error / CPU",
            2: "Verde / Éxito / Audio",
            3: "Amarillo / Alerta / RAM",
            4: "Azul / Acento Principal",
            5: "Magenta / Acento Secundario",
            6: "Cian / Batería / Info",
            7: "Texto / Foreground",
            8: "Gris / Bordes sutiles",
            12: "Azul Claro / Reloj / Resaltado"
        }
        role_text = f" — {role_map[self.selected_color_idx]}" if self.selected_color_idx in role_map else ""
        self.color_name_row.set_subtitle(f"Color {self.selected_color_idx} ({hex_val}){role_text}")
        self._updating_palette = False

    def _on_single_color_slider_changed(self, scale):
        if self._updating_palette:
            return
        h = self.color_hue_scale.get_value() / 360.0
        s = self.color_sat_scale.get_value() / 100.0
        l = self.color_lum_scale.get_value() / 100.0
        
        r, g, b = colorsys.hls_to_rgb(h, l, s)
        hex_val = rgb_to_hex(r, g, b)
        
        setattr(self.current_palette, f"color{self.selected_color_idx}", hex_val)
        setattr(self.base_palette, f"color{self.selected_color_idx}", hex_val)
        
        role_map = {
            0: "Fondo oscuro / Superficie",
            1: "Rojo / Error / CPU",
            2: "Verde / Éxito / Audio",
            3: "Amarillo / Alerta / RAM",
            4: "Azul / Acento Principal",
            5: "Magenta / Acento Secundario",
            6: "Cian / Batería / Info",
            7: "Texto / Foreground",
            8: "Gris / Bordes sutiles",
            12: "Azul Claro / Reloj / Resaltado"
        }
        role_text = f" — {role_map[self.selected_color_idx]}" if self.selected_color_idx in role_map else ""
        self.color_name_row.set_subtitle(f"Color {self.selected_color_idx} ({hex_val}){role_text}")
        
        self._update_color_swatches_ui()
        self._update_preview()

    def _on_adjustment_changed(self, scale):
        b = self.brightness_scale.get_value()
        s = self.saturation_scale.get_value()
        c = self.contrast_scale.get_value()
        h = self.hue_scale.get_value()
        t = self.temp_scale.get_value()

        self.current_palette = self.base_palette.create_adjusted_copy(
            brightness_val=b,
            saturation_val=s,
            contrast_val=c,
            hue_shift_val=h,
            temperature_val=t,
        )
        
        self._update_color_swatches_ui()
        self._sync_single_color_sliders()
        self._update_preview()

    def _update_color_swatches_ui(self):
        for i, btn in enumerate(self.color_buttons):
            hex_col = getattr(self.current_palette, f"color{i}", "#888888")
            # Set background color of the swatch
            provider = Gtk.CssProvider()
            border = "3px solid white" if i == self.selected_color_idx else "1px solid rgba(255,255,255,0.2)"
            css = f"button {{ background-color: {hex_col}; border-radius: 8px; border: {border}; color: rgba(255,255,255,0.9); font-weight: bold; font-size: 11px; }}"
            provider.load_from_string(css)
            btn.get_style_context().add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 200)

    def _on_env_changed(self, scale):
        self._update_preview()

    def _update_preview(self):
        waybar_op = self.waybar_op.get_value() / 100.0
        kitty_op = self.kitty_op.get_value() / 100.0
        hypr_b = int(self.hypr_border.get_value())
        self.css_manager.update_palette_css(
            self.current_palette.to_dict(),
            waybar_opacity=waybar_op,
            kitty_opacity=kitty_op,
            hypr_border_width=hypr_b
        )

    def apply_to_system(self):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            f.write(self.current_palette.to_wallust_json())
            temp_path = f.name

        try:
            wall_path = wallust_bridge.get_current_wallpaper()
            if wall_path and os.path.exists(wall_path):
                profile_manager.save_profile(wall_path, json.loads(self.current_palette.to_wallust_json()))
            
            system_sync.apply_and_reload(temp_path, self.current_palette.color4)
        finally:
            if os.path.exists(temp_path):
                try:
                    os.unlink(temp_path)
                except Exception:
                    pass

    def save_preset(self):
        wall_path = wallust_bridge.get_current_wallpaper()
        if wall_path and os.path.exists(wall_path):
            profile_manager.save_profile(wall_path, json.loads(self.current_palette.to_wallust_json()))

    def restore_defaults(self):
        self.brightness_scale.set_value(0)
        self.saturation_scale.set_value(0)
        self.contrast_scale.set_value(0)
        self.hue_scale.set_value(0)
        self.temp_scale.set_value(0)
        self.base_palette = load_current_palette()
        self.current_palette = self.base_palette.create_adjusted_copy()
        
        self._update_color_swatches_ui()
        self._sync_single_color_sliders()
        self._update_preview()

    def cancel(self):
        root = self.get_root()
        if root and hasattr(root, "close"):
            root.close()
