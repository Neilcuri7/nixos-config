{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/applications
    ../../modules/shared/environment/hyprland.nix
    ../../modules/shared/hardware
    ../../modules/shared/services/sops.nix
  ];

  networking.hostName = "chinatsu";
  time.timeZone = "America/Bogota";
  time.hardwareClockInLocalTime = true;
  i18n.defaultLocale = "es_CO.UTF-8";

  services.tailscale.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  myPlatform = {
    applications = {
      desktop.enable = true;
      tools.enable = true;
      dev.enable = true;
      flatpak.enable = true;
    };
    environment.hyprland.enable = true;
    hardware = {
      bluetooth.enable = true;
      pipewire.enable = true;
      power.enable = true;
    };
    services.sops.enable = true;
  };

  virtualisation.docker.enable = true;

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  programs.zsh.enable = true;

  users.users.rylai = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" ];
  };

  # Configuración de Stylix (Tema unificado)
  stylix = {
    enable = true;
    image = ../../modules/shared/assets/wallpapers/877911.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    polarity = "dark";
    opacity = {
      terminal = 0.80;
      popups = 0.85;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
    };
  };

  system.stateVersion = "24.11";
}
