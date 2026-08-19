{ config, lib, pkgs, ... }:

{
  options.myPlatform.hardware = {
    bluetooth.enable = lib.mkEnableOption "Bluetooth Support";
    pipewire.enable = lib.mkEnableOption "Pipewire Audio";
    power.enable = lib.mkEnableOption "Power Management Policy";
  };

  config = lib.mkMerge [
    (lib.mkIf config.myPlatform.hardware.bluetooth.enable {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
    })

    (lib.mkIf config.myPlatform.hardware.pipewire.enable {
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    })

    (lib.mkIf config.myPlatform.hardware.power.enable {
      services.tlp.enable = true;
      services.upower.enable = true;
    })
  ];
}
