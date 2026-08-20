{ config, pkgs, ... }:

{
  imports = [
    ./hyprland
    ./theme/desktop-tools.nix
  ];

  # Home Manager - Configuración de Usuario Solamente (REGLA #9)
  # Prohibido usar home.packages. Todos los paquetes se declaran en NixOS.

  home.username = "rylai";
  home.homeDirectory = "/home/rylai";

  programs.bash.enable = true;

  # Opción 2: Configuración de Git con firma SSH
  programs.git = {
    enable = true;
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Neilcuri7";
        email = "20231b866@upc.edu.pe";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      commit.gpgsign = true;
      gpg.format = "ssh";
    };
  };

  # Opción 3: Variables de entorno y MimeApps (Navegador predeterminado: Brave)
  home.sessionVariables = {
    BROWSER = "brave";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "application/xhtml+xml" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
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
