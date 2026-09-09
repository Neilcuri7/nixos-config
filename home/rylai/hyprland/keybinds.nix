{ config, ... }:

let
  modifier = "SUPER";
in
{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = modifier;
    "$terminal" = "kitty";
    "$fileManager" = "thunar";
    "$menu" = "rofi -show drun -show-icons -theme ${config.home.homeDirectory}/.config/rofi/config.rasi";
    "$browser" = "brave";

    bind = [
      "$mainMod, Return, exec, $terminal"
      "$mainMod, W, exec, $browser"
      "$mainMod, E, exec, $fileManager"
      "$mainMod, V, exec, ${config.home.homeDirectory}/scripts/rofi-clipboard.sh"
      "$mainMod, N, exec, swaync-client -t -sw"
      "$mainMod SHIFT, N, exec, swaync-client -C"
      "$mainMod, Q, killactive,"
      "$mainMod, F, fullscreen,"
      "$mainMod CTRL, F, fullscreen, 1"
      "$mainMod, P, pseudo,"
      "$mainMod SHIFT, P, pin"
      "$mainMod, T, exec, kitty yazi"
      "$mainMod, S, exec, grim -g \"$(slurp)\" - | swappy -f -"
      "$mainMod, equal, exec, grim - | swappy -f -"
      "$mainMod, H, exec, ${config.home.homeDirectory}/scripts/hypr-cheatsheet.sh"
      "$mainMod SHIFT, W, exec, ${config.home.homeDirectory}/scripts/wallpaper.sh --select"
      "$mainMod SHIFT, Return, exec, $menu"
      "$mainMod SHIFT, F, togglefloating,"
      "$mainMod SHIFT, L, exec, swaylock"
      "$mainMod SHIFT, X, exec, wlogout"
      "$mainMod SHIFT, T, exec, ${config.home.homeDirectory}/scripts/theme-switcher.sh menu"
      "$mainMod SHIFT, O, exec, hyprpicker -a -f hex"
      "$mainMod SHIFT, G, exec, ${config.home.homeDirectory}/scripts/gamemode.sh"
      "$mainMod SHIFT, I, layoutmsg, togglesplit"

      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"
      "$mainMod, l, movefocus, r"
      "$mainMod, k, movefocus, u"
      "$mainMod, j, movefocus, d"

      "$mainMod SHIFT, left, movewindow, l"
      "$mainMod SHIFT, right, movewindow, r"
      "$mainMod SHIFT, up, movewindow, u"
      "$mainMod SHIFT, down, movewindow, d"
      "$mainMod SHIFT, h, movewindow, l"
      "$mainMod SHIFT, l, movewindow, r"
      "$mainMod SHIFT, k, movewindow, u"
      "$mainMod SHIFT, j, movewindow, d"

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

      "$mainMod, space, togglespecialworkspace,"
      "$mainMod SHIFT, space, movetoworkspace, special"

      "ALT, Z, exec, gsr-ui-cli toggle-show"
      "ALT, F9, exec, gsr-ui-cli toggle-record"
      "ALT, F7, exec, gsr-ui-cli toggle-pause"
      "SHIFT ALT, F10, exec, gsr-ui-cli toggle-replay"
      "ALT, F10, exec, gsr-ui-cli replay-save"
      "ALT, F11, exec, gsr-ui-cli replay-save-1-min"
      "ALT, F12, exec, gsr-ui-cli replay-save-10-min"
    ];

    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    binde = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
      ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
    ];
  };
}
