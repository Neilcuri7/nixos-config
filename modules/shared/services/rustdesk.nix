{ config, lib, pkgs, ... }:

{
  options.myPlatform.services.rustdesk = {
    enable = lib.mkEnableOption "RustDesk remote desktop client and background service";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall ports for RustDesk direct LAN connections";
    };
  };

  config = lib.mkIf config.myPlatform.services.rustdesk.enable {
    environment.systemPackages = [
      pkgs.rustdesk-flutter
    ];

    systemd.services.rustdesk = {
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

    networking.firewall = lib.mkIf config.myPlatform.services.rustdesk.openFirewall {
      allowedTCPPorts = [ 21115 21116 21117 21118 21119 ];
      allowedUDPPorts = [ 21116 ];
    };
  };
}
