{ config, pkgs, ... }:

{
  # Home Manager - Configuración de Usuario Solamente (REGLA #9)
  # Prohibido usar home.packages. Todos los paquetes se declaran en NixOS.

  home.username = "rylai";
  home.homeDirectory = "/home/rylai";

  programs.bash.enable = true;
  programs.git = {
    enable = true;
    settings.user = {
      name = "Neilcuri7";
      email = "20231b866@upc.edu.pe";
    };
  };

  # Configuración visual / Dotfiles en $HOME
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  home.stateVersion = "24.11";
}
