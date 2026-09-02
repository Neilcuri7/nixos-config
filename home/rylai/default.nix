{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hyprland
    ./theme/desktop-tools.nix
    inputs.airi.homeModules.ai
  ];

  # Home Manager - Configuración de Usuario Solamente (REGLA #9)
  # Prohibido usar home.packages. Todos los paquetes se declaran en NixOS.

  home.username = "rylai";
  home.homeDirectory = "/home/rylai";

  # Asegurar directorio base para la activación de codex en airi
  home.file.".codex/.keep".text = "";

  programs.bash = {
    enable = true;
    shellAliases = {
      brave-dev = "brave --remote-debugging-port=9222 --user-data-dir=\"$HOME/.config/brave-dev\" &>/dev/null & disown";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      brave-dev = "brave --remote-debugging-port=9222 --user-data-dir=\"$HOME/.config/brave-dev\" &>/dev/null & disown";
    };
    history = {
      size = 10000;
      share = true;
    };
  };

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
        email = "u20231b866@upc.edu.pe";
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
    EDITOR = "micro";
    VISUAL = "kwrite";
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
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        type = "auto";
        padding = {
          top = 1;
          left = 2;
        };
      };
      display = {
        separator = " :  ";
      };
      modules = [
        "break"
        {
          type = "custom";
          format = "┌─ Hardware ────────────────────────────────────────────────────────┐";
        }
        {
          type = "cpu";
          key = " CPU         ";
        }
        {
          type = "gpu";
          key = " GPU         ";
        }
        {
          type = "display";
          key = " Display     ";
        }
        {
          type = "disk";
          key = " Disk        ";
        }
        {
          type = "memory";
          key = " Memory      ";
        }
        {
          type = "custom";
          format = "└───────────────────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌─ Software ────────────────────────────────────────────────────────┐";
        }
        {
          type = "os";
          key = " OS          ";
        }
        {
          type = "kernel";
          key = " Kernel      ";
        }
        {
          type = "packages";
          key = " Packages    ";
        }
        {
          type = "shell";
          key = " Shell       ";
        }
        {
          type = "custom";
          format = "└───────────────────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌─ DE / WM ─────────────────────────────────────────────────────────┐";
        }
        {
          type = "de";
          key = " DE          ";
        }
        {
          type = "wm";
          key = " WM          ";
        }
        {
          type = "terminal";
          key = " Terminal    ";
        }
        {
          type = "custom";
          format = "└───────────────────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌─ Uptime / Age ────────────────────────────────────────────────────┐";
        }
        {
          type = "uptime";
          key = " Uptime      ";
        }
        {
          type = "custom";
          format = "└───────────────────────────────────────────────────────────────────┘";
        }
        "break"
      ];
    };
  };

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "y";
    settings = {
      opener = {
        edit = [
          {
            run = "micro \"$@\"";
            block = true;
            for = "unix";
          }
        ];
      };
    };
  };

  home.file.".config/themes.json" = {
    source = ./theme/themes.json;
    force = true;
  };

  home.stateVersion = "24.11";
}
