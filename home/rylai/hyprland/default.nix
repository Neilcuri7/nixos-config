{ config, pkgs, lib, ... }:

let
  modifier = "SUPER";
  wallpaperPath = ../assets/wallpapers/877911.png;
in
{
  # Teclado en español e inglés con Alt+Shift
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    configType = "hyprlang";

    settings = {
      "$mainMod" = modifier;
      "$terminal" = "kitty";
      "$fileManager" = "thunar";
      "$menu" = "rofi -show drun -show-icons -theme ${config.home.homeDirectory}/.config/rofi/config.rasi";
      "$browser" = "brave";

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
        "${config.home.homeDirectory}/scripts/init-wallpaper.sh"
        "${config.home.homeDirectory}/scripts/theme-switcher.sh init"
        "swaync"
        "ags"
        "hypridle"
        "wl-paste --type text --watch cliphist store" # Guardar texto en el historial
        "wl-paste --type image --watch cliphist store" # Guardar imágenes en el historial
      ];

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

      # Reglas de ventanas (Se deshabilitan temporalmente o se actualizan a la nueva sintaxis si es necesario)
      # windowrulev2 = [];

      # Atajos de Teclado (Keybindings de Lucifers_NIX)
      bind = [
        "$mainMod, Return, exec, $terminal"
        "$mainMod, W, exec, $browser"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, exec, ${config.home.homeDirectory}/scripts/rofi-clipboard.sh"
        "$mainMod, N, exec, swaync-client -t -sw" # Abrir/cerrar panel e historial de notificaciones
        "$mainMod SHIFT, N, exec, swaync-client -C" # Limpiar todas las notificaciones
        "$mainMod, Q, killactive,"
        "$mainMod, F, fullscreen,"
        "$mainMod CTRL, F, fullscreen, 1"
        "$mainMod, P, pseudo,"
        "$mainMod SHIFT, P, pin"
        "$mainMod SHIFT, E, exec, rofi -show emoji -theme ${config.home.homeDirectory}/.config/rofi/config.rasi"
        "$mainMod, T, exec, kitty yazi"
        "$mainMod, S, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$mainMod, H, exec, ${config.home.homeDirectory}/scripts/hypr-cheatsheet.sh"
        "$mainMod SHIFT, W, exec, ${config.home.homeDirectory}/scripts/rofi-wallpaper.sh"
        "$mainMod SHIFT, Return, exec, rofi -show drun -show-icons -theme ${config.home.homeDirectory}/.config/rofi/config.rasi"
        "$mainMod SHIFT, F, togglefloating,"
        "$mainMod SHIFT, L, exec, swaylock"
        "$mainMod SHIFT, X, exec, wlogout"
        "$mainMod SHIFT, T, exec, gsettings set org.gnome.desktop.interface color-scheme $([ \"$(gsettings get org.gnome.desktop.interface color-scheme)\" = \"'prefer-dark'\" ] && echo 'prefer-light' || echo 'prefer-dark')"
        "$mainMod SHIFT, O, exec, hyprpicker -a -f hex"
        "$mainMod SHIFT, G, exec, ${config.home.homeDirectory}/scripts/gamemode.sh"
        "$mainMod SHIFT, I, layoutmsg, togglesplit"

        # Mover foco entre ventanas
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # Mover ventana activa
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, j, movewindow, d"

        # Navegación por Workspaces (1-10)
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Mover ventana activa a Workspace (1-10)
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Enviar ventana activa a Workspace en segundo plano sin cambiar de workspace (1-10)
        "$mainMod CTRL, 1, movetoworkspacesilent, 1"
        "$mainMod CTRL, 2, movetoworkspacesilent, 2"
        "$mainMod CTRL, 3, movetoworkspacesilent, 3"
        "$mainMod CTRL, 4, movetoworkspacesilent, 4"
        "$mainMod CTRL, 5, movetoworkspacesilent, 5"
        "$mainMod CTRL, 6, movetoworkspacesilent, 6"
        "$mainMod CTRL, 7, movetoworkspacesilent, 7"
        "$mainMod CTRL, 8, movetoworkspacesilent, 8"
        "$mainMod CTRL, 9, movetoworkspacesilent, 9"
        "$mainMod CTRL, 0, movetoworkspacesilent, 10"

        # Special Workspace (Scratchpad)
        "$mainMod, space, togglespecialworkspace,"
        "$mainMod SHIFT, space, movetoworkspace, special"

        # GPU Screen Recorder (Wayland Workaround - Default UI hotkeys)
        "ALT, Z, exec, gsr-ui-cli toggle-show"
        "ALT, F9, exec, gsr-ui-cli toggle-record"
        "ALT, F7, exec, gsr-ui-cli toggle-pause"
        "SHIFT ALT, F10, exec, gsr-ui-cli toggle-replay"
        "ALT, F10, exec, gsr-ui-cli replay-save"
        "ALT, F11, exec, gsr-ui-cli replay-save-1-min"
        "ALT, F12, exec, gsr-ui-cli replay-save-10-min"
      ];

      # Mouse Binds
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Teclas Multimedia
      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
    };
  };

  # Copiar la configuración de AGS (Barra nativa de Lucifers_NIX)
  home.file.".config/ags" = {
    source = ./ags;
    recursive = true;
  };

  # Copiar la configuración del tema de Rofi
  home.file.".config/rofi/config.rasi" = {
    source = ../theme/rofi.rasi;
  };

  # Copiar scripts personalizados
  home.file."scripts" = {
    source = ../scripts;
    recursive = true;
    executable = true;
  };

  # Copiar wallpapers portables
  home.file.".config/wallpapers" = {
    source = ../assets/wallpapers;
    recursive = true;
  };



  # Configuración de Swappy para Screenshots
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
