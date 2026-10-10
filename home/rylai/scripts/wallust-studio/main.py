import sys
import gi

gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Adw, Gio

from ui.window import WallustStudioWindow

class WallustStudioApplication(Adw.Application):
    def __init__(self):
        super().__init__(application_id='com.rylai.WallustStudio',
                         flags=Gio.ApplicationFlags.FLAGS_NONE)

    def do_activate(self):
        win = self.props.active_window
        if not win:
            win = WallustStudioWindow(application=self)
        win.present()

def main():
    app = WallustStudioApplication()
    return app.run(sys.argv)

if __name__ == '__main__':
    sys.exit(main())
