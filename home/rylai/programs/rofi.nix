{ pkgs, ... }:

{
  home.packages = [ pkgs.rofi ];

  xdg.configFile."rofi/config.rasi".source = ./rofi.rasi;
}
