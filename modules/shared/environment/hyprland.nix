{ config, lib, pkgs, ... }:

{
  options.myPlatform.environment.hyprland = {
    enable = lib.mkEnableOption "Hyprland Wayland Compositor";
  };

  config = lib.mkIf config.myPlatform.environment.hyprland.enable {
    security.polkit.enable = true;

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      ags
      swaybg
      swaynotificationcenter
      rofi
      wlogout
      swaylock
      hypridle
      swayidle
      hyprpicker
      grim
      slurp
      swappy
      wl-clipboard
      brightnessctl
      playerctl
      pamixer
      kitty
      xdg-utils
    ];

    services.displayManager.defaultSession = "hyprland";
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.displayManager.autoLogin = {
      enable = true;
      user = "rylai";
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      noto-fonts
      font-awesome
    ];
  };
}
