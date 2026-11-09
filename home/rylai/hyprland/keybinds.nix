{ config, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
  modifier = "SUPER";
  mkBind = keys: dsp: { _args = [ keys (mkLuaInline dsp) ]; };
  mkBindOpts = keys: dsp: opts: { _args = [ keys (mkLuaInline dsp) opts ]; };
  workspaces = [
    { key = "1"; ws = 1; }
    { key = "2"; ws = 2; }
    { key = "3"; ws = 3; }
    { key = "4"; ws = 4; }
    { key = "5"; ws = 5; }
    { key = "6"; ws = 6; }
    { key = "7"; ws = 7; }
    { key = "8"; ws = 8; }
    { key = "9"; ws = 9; }
    { key = "0"; ws = 10; }
  ];
in
{
  wayland.windowManager.hyprland.settings = {
    mainMod = { _var = modifier; };
    terminal = { _var = "kitty"; };
    fileManager = { _var = "thunar"; };
    menu = { _var = "rofi -show drun -show-icons -theme ${config.home.homeDirectory}/.config/rofi/config.rasi"; };
    browser = { _var = "brave"; };

    bind = [
      (mkBind "${modifier} + Return" "hl.dsp.exec_cmd(terminal)")
      (mkBind "${modifier} + W" "hl.dsp.exec_cmd(browser)")
      (mkBind "${modifier} + E" "hl.dsp.exec_cmd(fileManager)")
      (mkBind "${modifier} + V" "hl.dsp.exec_cmd(${lib.strings.escapeNixString "${config.home.homeDirectory}/scripts/rofi-clipboard.sh"})")
      (mkBind "${modifier} + N" "hl.dsp.exec_cmd(\"swaync-client -t -sw\")")
      (mkBind "${modifier} + SHIFT + N" "hl.dsp.exec_cmd(\"swaync-client -C\")")
      (mkBind "${modifier} + Q" "hl.dsp.window.close()")
      (mkBind "${modifier} + F" "hl.dsp.window.fullscreen()")
      (mkBind "${modifier} + CTRL + F" "hl.dsp.window.fullscreen({ mode = \"maximized\" })")
      (mkBind "${modifier} + P" "hl.dsp.window.pseudo()")
      (mkBind "${modifier} + SHIFT + P" "hl.dsp.window.pin()")
      (mkBind "${modifier} + T" "hl.dsp.exec_cmd(\"kitty yazi\")")
      (mkBind "${modifier} + S" "hl.dsp.exec_cmd(\"grim -g \\\"$(slurp)\\\" - | swappy -f -\")")
      (mkBind "${modifier} + equal" "hl.dsp.exec_cmd(\"grim - | swappy -f -\")")
      (mkBind "${modifier} + H" "hl.dsp.exec_cmd(${lib.strings.escapeNixString "${config.home.homeDirectory}/scripts/hypr-cheatsheet.sh"})")
      (mkBind "${modifier} + SHIFT + W" "hl.dsp.exec_cmd(${lib.strings.escapeNixString "${config.home.homeDirectory}/scripts/wallpaper.sh --select"})")
      (mkBind "${modifier} + SHIFT + C" "hl.dsp.exec_cmd(${lib.strings.escapeNixString "${config.home.homeDirectory}/scripts/wallust-studio.sh"})")
      (mkBind "${modifier} + SHIFT + Return" "hl.dsp.exec_cmd(menu)")
      (mkBind "${modifier} + SHIFT + F" "hl.dsp.window.float({ action = \"toggle\" })")
      (mkBind "${modifier} + SHIFT + L" "hl.dsp.exec_cmd(\"swaylock\")")
      (mkBind "${modifier} + SHIFT + X" "hl.dsp.exec_cmd(\"wlogout\")")
      (mkBind "${modifier} + SHIFT + T" "hl.dsp.exec_cmd(${lib.strings.escapeNixString "${config.home.homeDirectory}/scripts/theme-switcher.sh menu"})")
      (mkBind "${modifier} + SHIFT + O" "hl.dsp.exec_cmd(\"hyprpicker -a -f hex\")")
      (mkBind "${modifier} + SHIFT + G" "hl.dsp.exec_cmd(${lib.strings.escapeNixString "${config.home.homeDirectory}/scripts/gamemode.sh"})")
      (mkBind "${modifier} + SHIFT + I" "hl.dsp.layout(\"togglesplit\")")

      (mkBind "${modifier} + left" "hl.dsp.focus({ direction = \"left\" })")
      (mkBind "${modifier} + right" "hl.dsp.focus({ direction = \"right\" })")
      (mkBind "${modifier} + up" "hl.dsp.focus({ direction = \"up\" })")
      (mkBind "${modifier} + down" "hl.dsp.focus({ direction = \"down\" })")
      (mkBind "${modifier} + h" "hl.dsp.focus({ direction = \"left\" })")
      (mkBind "${modifier} + l" "hl.dsp.focus({ direction = \"right\" })")
      (mkBind "${modifier} + k" "hl.dsp.focus({ direction = \"up\" })")
      (mkBind "${modifier} + j" "hl.dsp.focus({ direction = \"down\" })")

      (mkBind "${modifier} + SHIFT + left" "hl.dsp.window.move({ direction = \"left\" })")
      (mkBind "${modifier} + SHIFT + right" "hl.dsp.window.move({ direction = \"right\" })")
      (mkBind "${modifier} + SHIFT + up" "hl.dsp.window.move({ direction = \"up\" })")
      (mkBind "${modifier} + SHIFT + down" "hl.dsp.window.move({ direction = \"down\" })")
      (mkBind "${modifier} + SHIFT + h" "hl.dsp.window.move({ direction = \"left\" })")
      (mkBind "${modifier} + SHIFT + l" "hl.dsp.window.move({ direction = \"right\" })")
      (mkBind "${modifier} + SHIFT + k" "hl.dsp.window.move({ direction = \"up\" })")
      (mkBind "${modifier} + SHIFT + j" "hl.dsp.window.move({ direction = \"down\" })")

      (mkBind "${modifier} + space" "hl.dsp.workspace.toggle_special()")
      (mkBind "${modifier} + SHIFT + space" "hl.dsp.window.move({ workspace = \"special\" })")

      (mkBind "ALT + Z" "hl.dsp.exec_cmd(\"gsr-ui-cli toggle-show\")")
      (mkBind "ALT + F9" "hl.dsp.exec_cmd(\"gsr-ui-cli toggle-record\")")
      (mkBind "ALT + F7" "hl.dsp.exec_cmd(\"gsr-ui-cli toggle-pause\")")
      (mkBind "SHIFT + ALT + F10" "hl.dsp.exec_cmd(\"gsr-ui-cli toggle-replay\")")
      (mkBind "ALT + F10" "hl.dsp.exec_cmd(\"gsr-ui-cli replay-save\")")
      (mkBind "ALT + F11" "hl.dsp.exec_cmd(\"gsr-ui-cli replay-save-1-min\")")
      (mkBind "ALT + F12" "hl.dsp.exec_cmd(\"gsr-ui-cli replay-save-10-min\")")
      (mkBind "${modifier} + D" "hl.dsp.exec_cmd([=[bash -c \"URL=\$(cat \${XDG_RUNTIME_DIR:-/run/user/\$UID}/aoi_backend_url 2>/dev/null || echo \${AOI_BACKEND_URL:-http://127.0.0.1:8000}); curl -s -X POST \\\"\$URL/api/v1/audio/ptt/start\\\"\"]=])")
      (mkBindOpts "${modifier} + D" "hl.dsp.exec_cmd([=[bash -c \"URL=\$(cat \${XDG_RUNTIME_DIR:-/run/user/\$UID}/aoi_backend_url 2>/dev/null || echo \${AOI_BACKEND_URL:-http://127.0.0.1:8000}); curl -s -X POST \\\"\$URL/api/v1/audio/ptt/stop\\\"\"]=])" { release = true; })

      (mkBindOpts "${modifier} + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
      (mkBindOpts "${modifier} + mouse:273" "hl.dsp.window.resize()" { mouse = true; })

      (mkBindOpts "XF86AudioRaiseVolume" "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+\")" { repeating = true; })
      (mkBindOpts "XF86AudioLowerVolume" "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")" { repeating = true; })
      (mkBindOpts "XF86AudioMute" "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")" { repeating = true; })
      (mkBindOpts "XF86MonBrightnessUp" "hl.dsp.exec_cmd(\"brightnessctl set +5%\")" { repeating = true; })
      (mkBindOpts "XF86MonBrightnessDown" "hl.dsp.exec_cmd(\"brightnessctl set 5%-\")" { repeating = true; })
    ]
    ++ (map (w: mkBind "${modifier} + ${w.key}" "hl.dsp.focus({ workspace = ${toString w.ws} })") workspaces)
    ++ (map (w: mkBind "${modifier} + SHIFT + ${w.key}" "hl.dsp.window.move({ workspace = ${toString w.ws} })") workspaces)
    ++ (map (w: mkBind "${modifier} + CTRL + ${w.key}" "hl.dsp.window.move({ workspace = ${toString w.ws}, follow = false })") workspaces);
  };
}
