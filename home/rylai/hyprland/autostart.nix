{ config, ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      ",preferred,auto,1"
    ];

    env = [
      "XCURSOR_THEME,Natsuki"
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_THEME,Natsuki"
      "HYPRCURSOR_SIZE,24"
    ];

    exec-once = [
      "hyprctl setcursor Natsuki 24"
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "${config.home.homeDirectory}/scripts/wallpaper.sh --restore"
      "${config.home.homeDirectory}/scripts/theme-switcher.sh init"
      "swaync"
      "hypridle"
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"
    ];
  };
}
