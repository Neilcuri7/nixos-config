{ lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  wayland.windowManager.hyprland.settings = {
    config = {
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
        col = {
          active_border = lib.mkForce {
            colors = [
              (mkLuaInline "_G.colors.primary")
              (mkLuaInline "_G.colors.secondary")
            ];
            angle = 45;
          };
          inactive_border = lib.mkForce (mkLuaInline "_G.colors.outline");
        };
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
      };

      dwindle = {
        preserve_split = true;
      };
    };

    curve = [
      {
        _args = [
          "quick"
          {
            type = "bezier";
            points = [
              [ 0.05 0.9 ]
              [ 0.1 1.0 ]
            ];
          }
        ];
      }
    ];

    animation = [
      { leaf = "windows"; enabled = true; speed = 3; bezier = "quick"; style = "slide"; }
      { leaf = "windowsIn"; enabled = true; speed = 3; bezier = "quick"; style = "slide"; }
      { leaf = "windowsOut"; enabled = true; speed = 2; bezier = "quick"; style = "slide"; }
      { leaf = "windowsMove"; enabled = true; speed = 3; bezier = "quick"; style = "slide"; }
      { leaf = "border"; enabled = false; }
      { leaf = "fade"; enabled = true; speed = 3; bezier = "quick"; }
      { leaf = "workspaces"; enabled = true; speed = 3; bezier = "quick"; style = "slide"; }
    ];

    window_rule = [
      {
        name = "thunar-opacity";
        match.class = "^(?i)(thunar)$";
        opacity = "0.90 0.90";
      }
      {
        name = "wallust-studio";
        match.class = "^(?i)(.*walluststudio.*)$";
        float = true;
        center = true;
        size = "880 500";
      }
    ];
  };
}
