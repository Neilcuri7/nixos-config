import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Adw, Gdk

class ControlsPanel(Gtk.Box):
    def __init__(self, preview_panel, css_manager, *args, **kwargs):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, *args, **kwargs)
        self.preview_panel = preview_panel
        self.css_manager = css_manager

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

    def setup_adjustments_tab(self):
        page = Adw.PreferencesPage()
        group = Adw.PreferencesGroup(title="Ajustes de Color")

        # Brightness, Saturation, Contrast sliders
        self.brightness_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -100, 100, 1)
        self.brightness_scale.set_value(0)
        self.add_scale_row(group, "Luminosidad", self.brightness_scale)

        self.saturation_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -100, 100, 1)
        self.saturation_scale.set_value(0)
        self.add_scale_row(group, "Saturación", self.saturation_scale)

        self.contrast_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -50, 50, 1)
        self.contrast_scale.set_value(0)
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
        
        # 16 colors + bg + fg
        for i in range(16):
            btn = Gtk.ColorDialogButton()
            dialog = Gtk.ColorDialog()
            btn.set_dialog(dialog)
            btn.set_size_request(40, 40)
            grid.attach(btn, i % 4, i // 4, 1, 1)

        group.add(grid)
        page.add(group)
        self.tab_view.append(page)
        self.tab_view.get_page(page).set_title("Paleta")

    def setup_environment_tab(self):
        page = Adw.PreferencesPage()
        group = Adw.PreferencesGroup(title="Entorno")

        self.waybar_op = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.add_scale_row(group, "Waybar Opacidad", self.waybar_op)

        self.kitty_op = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.add_scale_row(group, "Kitty Opacidad", self.kitty_op)
        
        self.hypr_border = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 10, 1)
        self.add_scale_row(group, "Grosor Borde Hyprland", self.hypr_border)

        page.add(group)
        self.tab_view.append(page)
        self.tab_view.get_page(page).set_title("Entorno")

    def setup_action_bar(self):
        action_bar = Gtk.ActionBar()
        
        btn_restore = Gtk.Button(label="Restaurar")
        btn_save = Gtk.Button(label="Guardar Preset")
        btn_cancel = Gtk.Button(label="Cancelar")
        btn_apply = Gtk.Button(label="Aplicar al Sistema")
        btn_apply.add_css_class("suggested-action")
        
        action_bar.pack_start(btn_restore)
        action_bar.pack_start(btn_save)
        action_bar.pack_end(btn_apply)
        action_bar.pack_end(btn_cancel)
        
        self.append(action_bar)
