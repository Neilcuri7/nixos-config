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
        self.set_default_size(960, 580)

        # Main Layout
        self.split_view = Adw.NavigationSplitView()
        self.split_view.set_max_sidebar_width(380)
        self.split_view.set_min_sidebar_width(340)
        
        # CSS Manager
        self.css_manager = CSSManager()
        
        # Panels
        self.preview_panel = PreviewPanel()
        self.controls_panel = ControlsPanel(self.preview_panel, self.css_manager)

        # Setup Sidebar (Controls)
        sidebar_page = Adw.NavigationPage.new(self.controls_panel, "Controls")
        self.split_view.set_sidebar(sidebar_page)
        
        # Setup Content (Preview)
        content_page = Adw.NavigationPage.new(self.preview_panel, "Preview")
        self.split_view.set_content(content_page)

        self.set_content(self.split_view)

        self.setup_shortcuts()

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

        # Tabs (1, 2, 3)
        for i in range(1, 4):
            action_tab = Gio.SimpleAction.new(f"tab{i}", None)
            action_tab.connect("activate", lambda action, param, idx=i: self.on_tab(idx))
            self.add_action(action_tab)
            self.get_application().set_accels_for_action(f"win.tab{i}", [str(i)])

    def on_apply(self, action, param):
        self.controls_panel.apply_to_system()

    def on_cancel(self, action, param):
        self.close()

    def on_restore(self, action, param):
        self.controls_panel.restore_defaults()

    def on_tab(self, idx):
        pages = self.controls_panel.tab_view.get_n_pages()
        if 1 <= idx <= pages:
            page = self.controls_panel.tab_view.get_nth_page(idx - 1)
            self.controls_panel.tab_view.set_selected_page(page)
