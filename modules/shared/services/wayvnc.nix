{ config, lib, ... }:

let
  cfg = config.myPlatform.services.wayvnc;
in
{
  options.myPlatform.services.wayvnc = {
    enable = lib.mkEnableOption "acceso VNC (wayvnc) restringido a clientes Tailscale permitidos";
    allowedClients = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "IPs de Tailscale autorizadas a conectarse al puerto VNC 5900.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.extraCommands = lib.concatMapStrings (ip: ''
      iptables -I nixos-fw 1 -i tailscale0 -p tcp --dport 5900 -s ${ip} -j nixos-fw-accept
    '') cfg.allowedClients + ''
      iptables -I nixos-fw ${toString (builtins.length cfg.allowedClients + 1)} -p tcp --dport 5900 -j nixos-fw-refuse
    '';
    networking.firewall.extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 5900 -j nixos-fw-refuse 2>/dev/null || true
    '';
  };
}
