{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/applications
    ../../modules/shared/environment/hyprland.nix
    ../../modules/shared/hardware
    ../../modules/shared/services/sops.nix
    ../../modules/shared/services/input-remapper.nix
  ];

  networking.hostName = "chinatsu";

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

  system.stateVersion = "24.11";
}
