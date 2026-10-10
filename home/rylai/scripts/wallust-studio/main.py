import os
import sys
import glob

# Configurar automáticamente las rutas de typelibs de GObject Introspection en NixOS
_extra_gi_paths = [
    "/run/current-system/sw/lib/girepository-1.0",
    f"/etc/profiles/per-user/{os.environ.get('USER', 'rylai')}/lib/girepository-1.0",
    f"{os.path.expanduser('~')}/.nix-profile/lib/girepository-1.0",
]
for _pat in [
    "/nix/store/*-graphene-*/lib/girepository-1.0",
    "/nix/store/*-gtk4-*/lib/girepository-1.0",
    "/nix/store/*-libadwaita-*/lib/girepository-1.0",
    "/nix/store/*-pango-*/lib/girepository-1.0",
    "/nix/store/*-gdk-pixbuf-*/lib/girepository-1.0",
    "/nix/store/*-glib-*/lib/girepository-1.0",
    "/nix/store/*-gobject-introspection-*/lib/girepository-1.0",
]:
    _extra_gi_paths.extend(glob.glob(_pat))

_current_gi = os.environ.get("GI_TYPELIB_PATH", "").split(":")
for _p in _extra_gi_paths:
    if _p and os.path.isdir(_p) and _p not in _current_gi:
        _current_gi.append(_p)
os.environ["GI_TYPELIB_PATH"] = ":".join(filter(None, _current_gi))

# Asegurar que el directorio de wallust-studio esté en sys.path
_script_dir = os.path.dirname(os.path.abspath(__file__))
if _script_dir not in sys.path:
    sys.path.insert(0, _script_dir)

import gi

gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Adw, Gio

from ui.window import WallustStudioWindow

class WallustStudioApplication(Adw.Application):
    def __init__(self):
        super().__init__(application_id='com.rylai.WallustStudio',
                         flags=Gio.ApplicationFlags.NON_UNIQUE)

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
