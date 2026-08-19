{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/applications
    ../../modules/shared/environment/sway.nix
    ../../modules/shared/hardware
    ../../modules/shared/services/sops.nix
  ];

  networking.hostName = "desktop";
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "es_CO.UTF-8";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  myPlatform = {
    applications = {
      desktop.enable = true;
      tools.enable = true;
      dev.enable = true;
    };
    environment.sway.enable = true;
    hardware = {
      bluetooth.enable = true;
      pipewire.enable = true;
      power.enable = false;
    };
    services.sops.enable = true;
  };

  users.users.rylai = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  system.stateVersion = "24.11";
}
