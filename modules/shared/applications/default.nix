{ config, lib, pkgs, inputs, ... }:

{
  options.myPlatform.applications = {
    desktop.enable = lib.mkEnableOption "Desktop GUI Applications";
    tools.enable = lib.mkEnableOption "CLI Tools";
    dev.enable = lib.mkEnableOption "Development Environment Tools";
    gaming.enable = lib.mkEnableOption "Steam and Gaming Tools";
    flatpak.enable = lib.mkEnableOption "Flatpak Support";
  };

  config = lib.mkMerge [
    (lib.mkIf config.myPlatform.applications.flatpak.enable {
      services.flatpak.enable = true;
    })
    (lib.mkIf config.myPlatform.applications.desktop.enable {
      programs.spicetify =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        in
        {
          enable = true;
          enabledExtensions = with spicePkgs.extensions; [
            adblock
            shuffle
          ];
        };

      environment.systemPackages = [
        pkgs.firefox
        pkgs.brave
        pkgs.mpv
        pkgs.zathura
        pkgs.imv
        pkgs.typora
        pkgs.kdePackages.kate
        pkgs.discord
        inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-ide
      ];
    })

    (lib.mkIf config.myPlatform.applications.tools.enable {
      environment.systemPackages = [
        pkgs.alacritty
        pkgs.foot
        pkgs.git
        pkgs.ripgrep
        pkgs.fd
        pkgs.htop
        pkgs.btop
        pkgs.fastfetch
        pkgs.unzip
        pkgs.curl
        pkgs.jq
        pkgs.tree
        pkgs.yazi
        pkgs.imagemagick
        pkgs.tinty
        pkgs.micro
        inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
      ];
    })

    (lib.mkIf config.myPlatform.applications.dev.enable {
      environment.systemPackages = with pkgs; [
        neovim
        helix
        direnv
        gcc
        gnumake
        docker-compose
      ];
    })

    (lib.mkIf config.myPlatform.applications.gaming.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };

      programs.gamemode.enable = true;

      environment.systemPackages = with pkgs; [
        protonup-qt
      ];
    })
  ];
}
