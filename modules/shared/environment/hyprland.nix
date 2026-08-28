{ config, lib, pkgs, inputs, ... }:

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

    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    services.gvfs.enable = true; # Para automontaje y papelera
    services.tumbler.enable = true; # Para miniatura de imágenes

    environment.systemPackages = with pkgs; [
      inputs.ags.packages.${pkgs.system}.default
      swaybg
      matugen
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
      cliphist
      brightnessctl
      playerctl
      pamixer
      kitty
      xdg-terminal-exec
      xdg-utils
      gnome-calendar
      yad
      glib
      dconf
      shared-mime-info
      desktop-file-utils
      xfce4-exo
      gh
    ];

    programs.dconf.enable = true;

    environment.sessionVariables = {
      TERMINAL = "kitty";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

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
