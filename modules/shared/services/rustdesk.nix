{ config, lib, pkgs, ... }:

let
  cfg = config.myPlatform.services.rustdesk;
in
{
  options.myPlatform.services.rustdesk = {
    enable = lib.mkEnableOption "RustDesk remote desktop client";
    enableService = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable RustDesk background systemd service for unattended access";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall ports for RustDesk direct LAN connections";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.rustdesk-flutter
    ];

    systemd.services.rustdesk = lib.mkIf cfg.enableService {
      description = "RustDesk background service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "systemd-user-sessions.service" ];
      path = [ "/run/wrappers" pkgs.coreutils ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.rustdesk-flutter}/bin/rustdesk --service";
        Restart = "always";
        RestartSec = "5s";
        KillMode = "mixed";
      };
    };

    networking.firewall = lib.mkIf (cfg.enableService && cfg.openFirewall) {
      allowedTCPPorts = [ 21115 21116 21117 21118 21119 ];
      allowedUDPPorts = [ 21116 ];
    };
  };
}
