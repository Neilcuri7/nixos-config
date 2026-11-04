{ config, ... }:

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
    configType = "hyprlang";

    settings = {
      source = [
        "${config.home.homeDirectory}/.config/hypr/colors.conf"
      ];
    };
  };
}
