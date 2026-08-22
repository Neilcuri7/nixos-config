{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/applications
    ../../modules/shared/environment/hyprland.nix
    ../../modules/shared/hardware
    ../../modules/shared/services/sops.nix
  ];

  networking.hostName = "desktop";
  time.timeZone = "America/Bogota";
  time.hardwareClockInLocalTime = true;
  i18n.defaultLocale = "es_CO.UTF-8";

  services.tailscale.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "radeon.cik_support=0" "amdgpu.cik_support=1" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.enableRedistributableFirmware = true;

  networking.networkmanager.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  systemd.tmpfiles.rules = [
    "d /mnt/storage 0775 rylai users -"
    "z /mnt/storage 0775 rylai users -"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  myPlatform = {
    applications = {
      desktop.enable = true;
      tools.enable = true;
      dev.enable = true;
      gaming.enable = true;
      flatpak.enable = true;
    };
    environment.hyprland.enable = true;
    hardware = {
      bluetooth.enable = true;
      pipewire.enable = true;
      power.enable = false;
    };
    services.sops.enable = true;
  };

  virtualisation.docker.enable = true;

  programs.zsh.enable = true;

  users.users.rylai = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" ];
  };

  # Configuración de Stylix (Tema Nord unificado)
  stylix = {
    enable = true;
    image = ../../home/rylai/assets/wallpapers/877911.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    polarity = "dark";
    opacity = {
      terminal = 0.90;
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
