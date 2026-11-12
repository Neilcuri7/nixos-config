{ config, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      }
    ];

    env = [
      { _args = [ "XCURSOR_THEME" "Natsuki" ]; }
      { _args = [ "XCURSOR_SIZE" "24" ]; }
      { _args = [ "HYPRCURSOR_THEME" "Natsuki" ]; }
      { _args = [ "HYPRCURSOR_SIZE" "24" ]; }
    ];

    on = [
      {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd("hyprctl setcursor Natsuki 24")
              hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
              hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
              hl.exec_cmd("${config.home.homeDirectory}/scripts/wallpaper.sh --restore")
              hl.exec_cmd("swaync")
              hl.exec_cmd("hypridle")
              hl.exec_cmd("wl-paste --type text --watch cliphist store")
              hl.exec_cmd("wl-paste --type image --watch cliphist store")
            end
          '')
        ];
      }
    ];
  };
}
