{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      allow_remote_control = "yes";
      background_opacity = "0.80";
    };
    extraConfig = ''
      include ~/.config/kitty/current-theme.conf
    '';
  };

  programs.wlogout = {
    enable = true;
    style = ''
      @import "colors.css";

      * {
        background-image: none;
        box-shadow: none;
        font-family: "JetBrainsMono Nerd Font", monospace;
      }

      window {
        background-color: alpha(@background, 0.85);
      }

      button {
        color: @foreground;
        background-color: alpha(@surface, 0.6);
        border: 2px solid alpha(@outline, 0.4);
        border-radius: 16px;
        margin: 12px;
        transition: all 0.2s ease-in-out;
      }

      button:focus, button:active, button:hover {
        color: @primary;
        background-color: alpha(@primary, 0.2);
        border-color: @primary;
      }
    '';
    layout = [
      {
        label = "shutdown";
        action = "sleep 1; systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "reboot";
        action = "sleep 1; systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
      {
        label = "logout";
        action = "sleep 1; hyprctl dispatch exit";
        text = "Exit";
        keybind = "e";
      }
      {
        label = "suspend";
        action = "sleep 1; systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "lock";
        action = "sleep 1; swaylock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "sleep 1; systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
    ];
  };

  programs.swaylock = {
    enable = true;
    settings = {
      daemonize = true;
      show-failed-attempts = true;
      clock = true;
      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;
      grace = 0;
      fade-in = 0;
    };
  };

  services.swaync = {
    enable = true;
    style = ''
      @import "colors.css";

      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
        box-shadow: none;
      }

      .control-center {
        background: alpha(@cc-bg, 0.9);
        border: 1px solid @border-color;
        border-radius: 18px;
        padding: 12px;
      }

      .control-center-list {
        background: transparent;
      }

      .floating-notifications {
        background: transparent;
      }

      .notification-row {
        outline: none;
        margin: 6px 12px;
      }

      .notification {
        background: @noti-bg;
        border: 1px solid alpha(@border-color, 0.4);
        border-radius: 14px;
        padding: 10px;
        transition: all 0.2s ease-in-out;
      }

      .notification:hover {
        background: @noti-bg-hover;
        border-color: @accent-color;
      }

      .notification-content {
        color: @text-color;
      }

      .notification-default-action {
        color: @text-color;
      }

      .notification-action {
        color: @text-color;
        border: 1px solid @border-color;
        border-radius: 8px;
        background: alpha(@noti-bg-hover, 0.8);
      }

      .notification-action:hover {
        background: alpha(@accent-color, 0.3);
      }

      .close-button {
        color: @text-color;
        border-radius: 100%;
        background: transparent;
      }

      .close-button:hover {
        color: @accent-color;
      }

      .widget-title {
        color: @text-color;
        font-weight: bold;
        font-size: 15px;
        margin: 6px;
      }

      .widget-title > button {
        color: @text-color;
        border: 1px solid alpha(@border-color, 0.5);
        border-radius: 10px;
        padding: 4px 8px;
        background: alpha(@noti-bg, 0.6);
      }

      .widget-title > button:hover {
        background: alpha(@accent-color, 0.25);
        color: @accent-color;
      }

      .widget-dnd {
        margin: 6px;
        border-radius: 12px;
        background: alpha(@noti-bg, 0.6);
        color: @text-color;
        padding: 6px 10px;
      }

      .widget-dnd > switch {
        border-radius: 12px;
        background: alpha(@noti-bg-hover, 0.8);
        border: 1px solid alpha(@border-color, 0.5);
      }

      .widget-dnd > switch:checked {
        background: @accent-color;
      }

      .widget-mpris {
        background: alpha(@noti-bg, 0.8);
        border: 1px solid alpha(@border-color, 0.3);
        border-radius: 14px;
        padding: 10px;
        margin: 6px;
        color: @text-color;
      }

      .widget-volume,
      .widget-backlight {
        background: alpha(@noti-bg, 0.6);
        border: 1px solid alpha(@border-color, 0.25);
        border-radius: 12px;
        padding: 8px;
        margin: 6px;
        color: @text-color;
      }
    '';
    settings = {
      positionX = "right";
      positionY = "top";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 10;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = false;
      control-center-width = 400;
      control-center-height = 600;
      notification-window-width = 450;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
      widgets = [
        "title"
        "mpris"
        "volume"
        "backlight"
        "dnd"
        "notifications"
      ];
      widget-config = {
        title = {
          text = "Notifications 🍃";
          clear-all-button = true;
          button-text = "󰆴";
        };
        dnd = {
          text = "Do Not Disturb";
        };
        label = {
          max-lines = 1;
          text = "Notifications 🍃";
        };
        mpris = {
          image-size = 96;
          image-radius = 7;
        };
        volume = {
          label = "󰕾";
        };
        backlight = {
          label = "󰃟";
        };
      };
    };
  };
}
