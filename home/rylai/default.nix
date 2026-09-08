{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hyprland
    ./waybar
    ./programs
    ./theme/desktop-tools.nix
    inputs.airi.homeModules.ai
  ];

  # Home Manager - Configuración de Usuario Solamente (REGLA #9)
  # Prohibido usar home.packages. Todos los paquetes se declaran en NixOS.

  home.username = "rylai";
  home.homeDirectory = "/home/rylai";

  # Asegurar directorio base para la activación de codex en airi
  home.file.".codex/.keep".text = "";

  # Opción 3: Variables de entorno y MimeApps (Navegador predeterminado: Brave)
  home.sessionVariables = {
    BROWSER = "brave";
    TERMINAL = "kitty";
    TERM = "xterm-256color";
    EDITOR = "micro";
    VISUAL = "kate";
  };

  # Terminal por defecto para aplicaciones XDG / GLib / Thunar
  xdg.configFile."xdg-terminals.list".text = "kitty.desktop\n";

  dconf.settings = {
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "kitty";
      exec-arg = "-e";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "application/xhtml+xml" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "text/plain" = "org.kde.kate.desktop";
      "text/markdown" = "typora.desktop";
      "text/x-csrc" = "org.kde.kate.desktop";
      "text/x-c++src" = "org.kde.kate.desktop";
      "text/x-chdr" = "org.kde.kate.desktop";
      "text/x-java" = "org.kde.kate.desktop";
      "text/x-python" = "org.kde.kate.desktop";
      "text/x-script.python" = "org.kde.kate.desktop";
      "text/javascript" = "org.kde.kate.desktop";
      "application/javascript" = "org.kde.kate.desktop";
      "application/typescript" = "org.kde.kate.desktop";
      "text/css" = "org.kde.kate.desktop";
      "application/json" = "org.kde.kate.desktop";
      "application/x-shellscript" = "org.kde.kate.desktop";
      "text/x-shellscript" = "org.kde.kate.desktop";
      "text/rust" = "org.kde.kate.desktop";
      "text/x-go" = "org.kde.kate.desktop";
      "text/x-sql" = "org.kde.kate.desktop";
      "text/x-nix" = "org.kde.kate.desktop";
      "text/x-yaml" = "org.kde.kate.desktop";
      "application/x-yaml" = "org.kde.kate.desktop";
      "application/xml" = "org.kde.kate.desktop";
      "text/xml" = "org.kde.kate.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "image/heif" = "imv.desktop";
      "image/avif" = "imv.desktop";
    };
  };

  xdg.desktopEntries.brave-dev = {
    name = "Brave (Dev Mode)";
    genericName = "Web Browser";
    comment = "Brave Browser with Remote Debugging";
    exec = "brave --remote-debugging-port=9222 --user-data-dir=${config.home.homeDirectory}/.config/brave-dev %U";
    terminal = false;
    icon = "brave-browser";
    categories = [ "Network" "WebBrowser" ];
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };

  # Tema de Cursor (Natsuki)
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = "Natsuki";
    package = pkgs.stdenv.mkDerivation {
      name = "natsuki-cursor";
      src = ../../modules/shared/assets/cursors/Natsuki;
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
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };



  home.file.".config/themes.json" = {
    source = ./theme/themes.json;
    force = true;
  };

  home.file."Pictures/wallpapers" = {
    source = ../../modules/shared/assets/wallpapers;
    recursive = true;
  };

  home.file.".config/matugen" = {
    source = ./theme/matugen;
    recursive = true;
  };

  stylix.targets = {
    hyprland.enable = false;
    waybar.enable = false;
    kitty.enable = false;
    rofi.enable = false;
  };

  home.stateVersion = "24.11";
}
