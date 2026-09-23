{ config, lib, pkgs, ... }:

{
  options.myPlatform.services.input-remapper = {
    enable = lib.mkEnableOption "Input-remapper daemon and service for key/mouse remapping and macros";
  };

  config = lib.mkIf config.myPlatform.services.input-remapper.enable {
    services.input-remapper = {
      enable = true;
      enableUdevRules = true;
    };

    environment.systemPackages = [
      pkgs.input-remapper
    ];
  };
}
