{ config, pkgs, lib, ... }:

let
  modifier = "Mod4"; # Tecla Super / Windows
  wallpaperPath = ../assets/wallpapers/877911.png;
in
{
  # 1. Configuración de Waybar
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 30;

      modules-left = [
        "sway/workspaces"
        "sway/mode"
      ];

      modules-center = [
        "clock"
      ];

      modules-right = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "battery"
        "sway/language"
      ];

      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{icon}";
        format-icons = {
          "1" = "一";
          "2" = "二";
          "3" = "三";
          "4" = "四";
          "5" = "五";
          "6" = "六";
          "7" = "七";
          "8" = "八";
          "9" = "九";
          "10" = "十";
        };
      };

      clock = {
        format = "󰥔 {:%a %b %d  %H:%M}";
        tooltip-format = "{:%Y-%m-%d}";
      };

      cpu = {
        format = " {usage}%";
        interval = 5;
      };

      memory = {
        format = " {}%";
        interval = 5;
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-icons = [ "" "" "" "" "" ];
      };

      network = {
        format-wifi = " {essid}";
        format-ethernet = " {ifname}";
        format-disconnected = " Desconectado";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = " Mudo";
        format-icons = {
          headphone = "";
          default = [ "" "" "" ];
        };
        on-click = "${lib.getExe pkgs.pavucontrol}";
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: #1d2021;
        color: #ebdbb2;
      }

      #workspaces button {
        padding: 0 8px;
        background: transparent;
        color: #ebdbb2;
        border-bottom: 2px solid transparent;
      }

      #workspaces button.focused {
        border-bottom: 2px solid #b8bb26;
        background: #3c3836;
      }

      #workspaces button.urgent {
        border-bottom: 2px solid #fabd2f;
      }

      #clock, #pulseaudio, #network, #cpu, #memory, #battery, #mode {
        padding: 0 10px;
        margin: 0 2px;
      }
    '';
  };

  # 2. Configuración de Sway
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures = {
      gtk = true;
      base = true;
    };
    xwayland = true;
    package = pkgs.sway;

    config = {
      inherit modifier;

      terminal = "kitty";
      menu = "${pkgs.wofi}/bin/wofi --show drun";

      # Fondo de pantalla y servicios de inicio
      startup = [
        { command = "${config.home.homeDirectory}/scripts/init-wallpaper.sh"; }
      ];

      # Integración con Waybar (Reemplaza swaybar nativo)
      bars = [
        { command = "${pkgs.waybar}/bin/waybar"; }
      ];

      # Teclado y Touchpad
      input = {
        "type:keyboard" = {
          xkb_layout = "us,es";
          xkb_options = "grp:alt_shift_toggle";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
          click_method = "button_areas";
        };
      };

      # Ocultar cursor tras inactividad
      seat."*".hide_cursor = "10000";

      # Bordes y Gaps
      gaps = {
        inner = 5;
        outer = 2;
        smartGaps = true;
      };

      window = {
        border = 2;
        titlebar = false;
        hideEdgeBorders = "smart";
      };

      # Reglas de ventanas flotantes
      floating = {
        border = 2;
        criteria = [
          { app_id = "pavucontrol"; }
          { app_id = "mpv"; }
          { app_id = "qalculate-gtk"; }
          { window_role = "pop-up"; }
          { title = "Steam - Update News"; }
        ];
      };

      # 10 Workspaces y Atajos de Teclado
      keybindings = let
        mod = modifier;
      in {
        # Terminal y Lanzador
        "${mod}+Return" = "exec kitty";
        "${mod}+d" = "exec ${pkgs.wofi}/bin/wofi --show drun";
        "${mod}+Shift+q" = "kill";

        # Navegación entre ventanas (Vim keys + Flechas)
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        # Mover ventanas (Vim keys + Flechas)
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        # Cambiar a Workspaces (1 al 10)
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        # Mover ventana a Workspaces (1 al 10)
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        # Distribución de ventanas (Layouts)
        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";

        # Scratchpad (Espacio de borrador)
        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";

        # Modos de teclado (Resize y System)
        "${mod}+r" = "mode resize";
        "${mod}+Shift+e" = "mode system";

        # Recargar Sway
        "${mod}+Shift+c" = "reload";

        # Capturas de Pantalla (Grim + Slurp + Swappy)
        "Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.swappy}/bin/swappy -f -";
        "${mod}+Print" = "exec ${pkgs.grim}/bin/grim - | ${pkgs.swappy}/bin/swappy -f -";

        # Teclas Multimedia (Volumen y Brillo)
        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute"        = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86MonBrightnessUp"   = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      };

      # Modos especiales de teclado
      modes = {
        resize = {
          "h" = "resize shrink width 10 px";
          "j" = "resize grow height 10 px";
          "k" = "resize shrink height 10 px";
          "l" = "resize grow width 10 px";
          "Left" = "resize shrink width 10 px";
          "Down" = "resize grow height 10 px";
          "Up" = "resize shrink height 10 px";
          "Right" = "resize grow width 10 px";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
        system = {
          "l" = "exec swaylock, mode default";
          "e" = "exec swaymsg exit, mode default";
          "r" = "exec systemctl reboot, mode default";
          "s" = "exec systemctl poweroff, mode default";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

      # Apariencia / Colores
      colors = {
        focused = {
          border = "#4c7899";
          background = "#285577";
          text = "#ffffff";
          indicator = "#2e9ef4";
          childBorder = "#285577";
        };
        focusedInactive = {
          border = "#333333";
          background = "#5f676a";
          text = "#ffffff";
          indicator = "#484e50";
          childBorder = "#5f676a";
        };
        unfocused = {
          border = "#333333";
          background = "#222222";
          text = "#888888";
          indicator = "#292d2e";
          childBorder = "#222222";
        };
      };
    };

    # Variables de entorno de sesión
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export XDG_CURRENT_DESKTOP=sway
    '';
  };

  # Configuración de Capturas con Swappy
  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=$HOME/Pictures/Screenshots
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=true
    line_size=5
    text_size=20
    text_font=sans-serif
    paint_mode=brush
    early_exit=false
    fill_shape=false
    auto_save=false
  '';
}
