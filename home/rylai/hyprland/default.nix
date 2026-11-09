{ ... }:

{
  imports = [
    ./autostart.nix
    ./appearance.nix
    ./keybinds.nix
    ./swappy.nix
    ./services.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    configType = "lua";

    extraLuaFiles = {
      "00-colors" = {
        content = ''
          local ok, c = pcall(dofile, (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr/colors.lua")
          if ok and type(c) == "table" then
            _G.colors = c
          else
            _G.colors = {
              background = "rgb(1e1e2e)",
              foreground = "rgb(cdd6f4)",
              primary = "rgb(89b4fa)",
              secondary = "rgb(f5c2e7)",
              tertiary = "rgb(94e2d5)",
              error = "rgb(f38ba8)",
              surface = "rgb(45475a)",
              outline = "rgb(585b70)",
            }
          end
          return _G.colors
        '';
        autoLoad = true;
      };
    };
  };
}
