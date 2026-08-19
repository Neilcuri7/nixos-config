{ config, lib, pkgs, ... }:

{
  options.myPlatform.environment.sway = {
    enable = lib.mkEnableOption "Sway Wayland Window Manager";
  };

  config = lib.mkIf config.myPlatform.environment.sway.enable {
    security.polkit.enable = true;

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        waybar
        mako
        wofi
        grim
        slurp
        wl-clipboard
      ];
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      noto-fonts
    ];
  };
}
