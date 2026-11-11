import os
import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Adw, Gdk, Gio

from .controls_panel import ControlsPanel
from .preview_panel import PreviewPanel
from .css_manager import CSSManager

class WallustStudioWindow(Adw.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.set_title("Wallust Studio")
        self.set_default_size(880, 500)

        # Main Split Layout
        self.split_view = Adw.NavigationSplitView()
        self.split_view.set_min_sidebar_width(330)
        self.split_view.set_max_sidebar_width(360)
        
        # CSS Manager
        self.css_manager = CSSManager()
        
        # Panels
        self.preview_panel = PreviewPanel()
        self.controls_panel = ControlsPanel(self.preview_panel, self.css_manager)

        # Setup Sidebar (Controls)
        sidebar_page = Adw.NavigationPage.new(self.controls_panel, "Controls")
        self.split_view.set_sidebar(sidebar_page)
        
        # Setup Content (Preview All-in-One)
        content_page = Adw.NavigationPage.new(self.preview_panel, "Preview")
        self.split_view.set_content(content_page)

        # Cabecera con el wallpaper activo
        wallpaper = self.controls_panel._get_active_wallpaper()
        subtitle = os.path.basename(wallpaper) if wallpaper else "sin wallpaper"
        header = Adw.HeaderBar()
        header.set_title_widget(Adw.WindowTitle(title="Wallust Studio", subtitle=subtitle))

        # Toasts sobre el contenido
        self.toast_overlay = Adw.ToastOverlay()
        self.toast_overlay.set_child(self.split_view)

        toolbar_view = Adw.ToolbarView()
        toolbar_view.add_top_bar(header)
        toolbar_view.set_content(self.toast_overlay)

        self.set_content(toolbar_view)
        self.setup_shortcuts()

    def show_toast(self, text: str):
        self.toast_overlay.add_toast(Adw.Toast.new(text))

    def setup_shortcuts(self):
        # Apply (Ctrl+S / Enter)
        action_apply = Gio.SimpleAction.new("apply", None)
        action_apply.connect("activate", self.on_apply)
        self.add_action(action_apply)
        self.get_application().set_accels_for_action("win.apply", ["<Ctrl>s", "Return"])

        # Cancel (Esc)
        action_cancel = Gio.SimpleAction.new("cancel", None)
        action_cancel.connect("activate", self.on_cancel)
        self.add_action(action_cancel)
        self.get_application().set_accels_for_action("win.cancel", ["Escape"])

        # Restore (Ctrl+R)
        action_restore = Gio.SimpleAction.new("restore", None)
        action_restore.connect("activate", self.on_restore)
        self.add_action(action_restore)
        self.get_application().set_accels_for_action("win.restore", ["<Ctrl>r"])

        # Original del wallpaper (Ctrl+Shift+R)
        action_original = Gio.SimpleAction.new("original", None)
        action_original.connect("activate", self.on_original)
        self.add_action(action_original)
        self.get_application().set_accels_for_action("win.original", ["<Ctrl><Shift>r"])

    def on_apply(self, action, param):
        self.controls_panel.apply_to_system()

    def on_cancel(self, action, param):
        self.close()

    def on_restore(self, action, param):
        self.controls_panel.restore_defaults()

    def on_original(self, action, param):
        self.controls_panel.load_wallpaper_original()
