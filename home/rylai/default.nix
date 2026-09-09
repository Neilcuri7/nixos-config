{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hyprland
    ./waybar
    ./programs
    ./theme/desktop-tools.nix
    inputs.airi.homeModules.ai
  ];

  home.username = "rylai";
  home.homeDirectory = "/home/rylai";

  home.sessionVariables = {
    BROWSER = "brave";
    TERMINAL = "kitty";
    TERM = "xterm-256color";
    EDITOR = "micro";
    VISUAL = "kwrite";
  };

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

  home.file.".config/rofi/config.rasi" = {
    source = ./theme/rofi.rasi;
  };

  home.file."scripts" = {
    source = ./scripts;
    recursive = true;
    executable = true;
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
