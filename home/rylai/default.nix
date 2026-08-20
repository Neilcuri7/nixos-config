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
      credential."https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
      credential."https://gist.github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
    };
  };

  # Opción 3: Variables de entorno y MimeApps (Navegador predeterminado: Brave)
  home.sessionVariables = {
    BROWSER = "brave";
    TERMINAL = "kitty";
    TERM = "xterm-256color";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "application/xhtml+xml" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "text/plain" = "org.kde.kwrite.desktop";
      "text/markdown" = "typora.desktop";
      "text/x-csrc" = "org.kde.kwrite.desktop";
      "text/x-c++src" = "org.kde.kwrite.desktop";
      "text/x-chdr" = "org.kde.kwrite.desktop";
      "text/x-java" = "org.kde.kwrite.desktop";
      "text/x-python" = "org.kde.kwrite.desktop";
      "text/x-script.python" = "org.kde.kwrite.desktop";
      "text/javascript" = "org.kde.kwrite.desktop";
      "application/javascript" = "org.kde.kwrite.desktop";
      "application/typescript" = "org.kde.kwrite.desktop";
      "text/css" = "org.kde.kwrite.desktop";
      "application/json" = "org.kde.kwrite.desktop";
      "application/x-shellscript" = "org.kde.kwrite.desktop";
      "text/x-shellscript" = "org.kde.kwrite.desktop";
      "text/rust" = "org.kde.kwrite.desktop";
      "text/x-go" = "org.kde.kwrite.desktop";
      "text/x-sql" = "org.kde.kwrite.desktop";
      "text/x-nix" = "org.kde.kwrite.desktop";
      "text/x-yaml" = "org.kde.kwrite.desktop";
      "application/x-yaml" = "org.kde.kwrite.desktop";
      "application/xml" = "org.kde.kwrite.desktop";
      "text/xml" = "org.kde.kwrite.desktop";
    };
  };

  # Tema de Cursor (Natsuki)
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = "Natsuki";
    package = pkgs.stdenv.mkDerivation {
      name = "natsuki-cursor";
      src = ./assets/cursors/Natsuki;
      installPhase = ''
        mkdir -p $out/share/icons/Natsuki
        cp -r * $out/share/icons/Natsuki/
      '';
    };
    size = 24;
  };

  # Configuración visual / Dotfiles en $HOME
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.stateVersion = "24.11";
}
