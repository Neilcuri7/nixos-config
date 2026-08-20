{ config, lib, pkgs, inputs, ... }:

{
  options.myPlatform.applications = {
    desktop.enable = lib.mkEnableOption "Desktop GUI Applications";
    tools.enable = lib.mkEnableOption "CLI Tools";
    dev.enable = lib.mkEnableOption "Development Environment Tools";
  };

  config = lib.mkMerge [
    (lib.mkIf config.myPlatform.applications.desktop.enable {
      environment.systemPackages = [
        pkgs.firefox
        pkgs.brave
        pkgs.mpv
        pkgs.zathura
        pkgs.imv
        pkgs.typora
        pkgs.kdePackages.kate
        inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default # Base App (GUI)
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
        inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli # CLI (agy)
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
