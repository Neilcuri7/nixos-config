import os
import json
import tempfile
import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Adw, Gdk, GLib

from color_engine import ColorPalette, load_current_palette
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
        group = Adw.PreferencesGroup(title="Ajustes de Color")

        # Brightness, Saturation, Contrast sliders
        self.brightness_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -100, 100, 1)
        self.brightness_scale.set_value(0)
        self.brightness_scale.connect("value-changed", self._on_adjustment_changed)
        self.add_scale_row(group, "Luminosidad", self.brightness_scale)

        self.saturation_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -100, 100, 1)
        self.saturation_scale.set_value(0)
        self.saturation_scale.connect("value-changed", self._on_adjustment_changed)
        self.add_scale_row(group, "Saturación", self.saturation_scale)

        self.contrast_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -50, 50, 1)
        self.contrast_scale.set_value(0)
        self.contrast_scale.connect("value-changed", self._on_adjustment_changed)
        self.add_scale_row(group, "Contraste", self.contrast_scale)

        page.add(group)
        self.tab_view.append(page)
        self.tab_view.get_page(page).set_title("Ajustes")

    def add_scale_row(self, group, title, scale):
        row = Adw.ActionRow(title=title)
        scale.set_hexpand(True)
        scale.set_draw_value(True)
        
        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        box.append(scale)
        
        reset_btn = Gtk.Button(icon_name="view-refresh-symbolic")
        reset_btn.connect("clicked", lambda b: scale.set_value(0))
        box.append(reset_btn)
        
        row.add_suffix(box)
        group.add(row)

    def setup_palette_tab(self):
        page = Adw.PreferencesPage()
        group = Adw.PreferencesGroup(title="Colores ANSI")

        grid = Gtk.Grid(column_spacing=6, row_spacing=6, halign=Gtk.Align.CENTER)
        self.color_buttons = []
        
        # 16 ANSI colors
        for i in range(16):
            btn = Gtk.ColorDialogButton()
            dialog = Gtk.ColorDialog()
            btn.set_dialog(dialog)
            btn.set_size_request(40, 40)
            
            # Set initial color
            hex_col = getattr(self.current_palette, f"color{i}", "#888888")
            rgba = Gdk.RGBA()
            rgba.parse(hex_col)
            btn.set_rgba(rgba)
            
            btn.connect("notify::rgba", self._on_color_btn_changed, i)
            self.color_buttons.append(btn)
            grid.attach(btn, i % 4, i // 4, 1, 1)

        group.add(grid)
        page.add(group)
        self.tab_view.append(page)
        self.tab_view.get_page(page).set_title("Paleta")

    def setup_environment_tab(self):
        page = Adw.PreferencesPage()
        group = Adw.PreferencesGroup(title="Entorno")

        self.waybar_op = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 10, 100, 1)
        self.waybar_op.set_value(90)
        self.waybar_op.connect("value-changed", self._on_env_changed)
        self.add_scale_row(group, "Waybar Opacidad", self.waybar_op)

        self.kitty_op = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 10, 100, 1)
        self.kitty_op.set_value(80)
        self.kitty_op.connect("value-changed", self._on_env_changed)
        self.add_scale_row(group, "Kitty Opacidad", self.kitty_op)
        
        self.hypr_border = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 10, 1)
        self.hypr_border.set_value(2)
        self.hypr_border.connect("value-changed", self._on_env_changed)
        self.add_scale_row(group, "Grosor Borde Hyprland", self.hypr_border)

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

    def _on_adjustment_changed(self, scale):
        b = self.brightness_scale.get_value()
        s = self.saturation_scale.get_value()
        c = self.contrast_scale.get_value()

        self.current_palette = self.base_palette.create_adjusted_copy(b, s, c)
        
        # Update palette button colors without triggering recursive events
        self._updating_palette = True
        for i, btn in enumerate(self.color_buttons):
            hex_col = getattr(self.current_palette, f"color{i}", "#888888")
            rgba = Gdk.RGBA()
            rgba.parse(hex_col)
            btn.set_rgba(rgba)
        self._updating_palette = False

        self._update_preview()

    def _on_color_btn_changed(self, btn, param, idx):
        if self._updating_palette:
            return
        rgba = btn.get_rgba()
        hex_val = '#{:02x}{:02x}{:02x}'.format(
            int(rgba.red * 255),
            int(rgba.green * 255),
            int(rgba.blue * 255)
        )
        setattr(self.current_palette, f"color{idx}", hex_val)
        setattr(self.base_palette, f"color{idx}", hex_val)
        self._update_preview()

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
        self.base_palette = load_current_palette()
        self.current_palette = self.base_palette.create_adjusted_copy()
        
        self._updating_palette = True
        for i, btn in enumerate(self.color_buttons):
            hex_col = getattr(self.current_palette, f"color{i}", "#888888")
            rgba = Gdk.RGBA()
            rgba.parse(hex_col)
            btn.set_rgba(rgba)
        self._updating_palette = False
        
        self._update_preview()

    def cancel(self):
        root = self.get_root()
        if root and hasattr(root, "close"):
            root.close()
