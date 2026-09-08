{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = lib.mkForce (builtins.readFile ./style.css);
  };

  xdg.configFile."waybar/config.jsonc" = {
    source = ./config.jsonc;
    onChange = "${pkgs.procps}/bin/pkill -SIGUSR2 waybar || true";
  };
}
