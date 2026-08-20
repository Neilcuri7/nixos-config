{ ... }:

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
  i18n.defaultLocale = "es_CO.UTF-8";

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
    };
    environment.hyprland.enable = true;
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
