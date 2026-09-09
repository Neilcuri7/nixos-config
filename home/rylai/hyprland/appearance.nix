{ lib, ... }:

{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us,es";
      kb_options = "grp:alt_shift_toggle";
      follow_mouse = 1;
      touchpad = {
        natural_scroll = true;
      };
      sensitivity = 0;
    };

    general = {
      gaps_in = 3;
      gaps_out = 6;
      border_size = 2;
      layout = "dwindle";
      "col.active_border" = lib.mkForce "$primary $secondary 45deg";
      "col.inactive_border" = lib.mkForce "$outline";
    };

    decoration = {
      rounding = 0;
      blur = {
        enabled = false;
        size = 2;
        passes = 1;
        new_optimizations = true;
      };
      shadow = {
        enabled = false;
      };
    };

    animations = {
      enabled = true;
      bezier = [
        "quick, 0.05, 0.9, 0.1, 1.0"
      ];
      animation = [
        "windows, 1, 3, quick, slide"
        "windowsIn, 1, 3, quick, slide"
        "windowsOut, 1, 2, quick, slide"
        "windowsMove, 1, 3, quick, slide"
        "border, 0"
        "fade, 1, 3, quick"
        "workspaces, 1, 3, quick, slide"
      ];
    };

    dwindle = {
      preserve_split = true;
    };

    windowrule = [
      "opacity 0.90 0.90, ^([tT]hunar)$"
    ];
  };
}
