{ config, lib, pkgs, ... }:

{
  options.myPlatform.applications = {
    desktop.enable = lib.mkEnableOption "Desktop GUI Applications";
    tools.enable = lib.mkEnableOption "CLI Tools";
    dev.enable = lib.mkEnableOption "Development Environment Tools";
  };

  config = lib.mkMerge [
    (lib.mkIf config.myPlatform.applications.desktop.enable {
      environment.systemPackages = with pkgs; [
        firefox
        brave
        mpv
        zathura
        imv
        typora
        kdePackages.kate
      ];
    })

    (lib.mkIf config.myPlatform.applications.tools.enable {
      environment.systemPackages = with pkgs; [
        alacritty
        foot
        git
        ripgrep
        fd
        htop
        btop
        fastfetch
        unzip
        curl
        jq
        tree
        yazi
      ];
    })

    (lib.mkIf config.myPlatform.applications.dev.enable {
      environment.systemPackages = with pkgs; [
        neovim
        helix
        direnv
        gcc
        gnumake
      ];
    })
  ];
}
