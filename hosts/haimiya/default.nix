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

  networking.hostName = "haimiya";

  # Parámetros del Kernel y Gráficos AMD
  boot.kernelParams = [ "radeon.cik_support=0" "amdgpu.cik_support=1" ];

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.enableRedistributableFirmware = true;

  # Gestión de Energía
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Permisos de almacenamiento local
  systemd.tmpfiles.rules = [
    "d /mnt/storage 0755 rylai users -"
  ];

  # Módulos Funcionales
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
    services = {
      sops.enable = true;
      input-remapper.enable = true;
    };
  };

  # Dispositivos de entrada / Macros
  programs.ydotool.enable = true;
  hardware.uinput.enable = true;

  users.users.rylai.extraGroups = [ "input" "uinput" "ydotool" ];

  system.stateVersion = "24.11";
}
