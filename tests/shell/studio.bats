setup() { load helpers; cd "$REPO/home/rylai/scripts/wallust-studio/ui"; }
@test "apply keeps the window open and toasts" {
  ! sed -n '/def apply_to_system/,/^    def /p' controls_panel.py | grep -q 'self.cancel()'
  grep -qF 'Colores aplicados' controls_panel.py
  grep -qF 'Adw.ToastOverlay' window.py
}
@test "original button and shortcut exist" {
  grep -qF '"Original"' controls_panel.py
  grep -qF 'load_wallpaper_original' controls_panel.py
  grep -qF '"<Ctrl><Shift>r"' window.py
}
@test "header shows the active wallpaper" {
  grep -qF 'Adw.WindowTitle' window.py
  grep -qF '_get_active_wallpaper' window.py
}
@test "apply button has no emoji and swatches select on focus" {
  ! grep -qF '🔄' controls_panel.py
  grep -qF 'Gtk.EventControllerFocus' controls_panel.py
}
