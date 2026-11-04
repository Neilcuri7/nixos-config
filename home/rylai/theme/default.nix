{ config, lib, pkgs, ... }:

let
  wallustStudio = pkgs.writeShellScriptBin "wallust-studio" ''
    export GI_TYPELIB_PATH="${lib.makeSearchPath "lib/girepository-1.0" (with pkgs; [
      gtk4
      libadwaita
      graphene
      pango.out
      harfbuzz
      gdk-pixbuf
      librsvg
      glib.out
      gobject-introspection
      at-spi2-core
    ])}''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"
    export GSETTINGS_SCHEMA_DIR="${pkgs.gtk4}/share/gsettings-schemas/${pkgs.gtk4.name}/glib-2.0/schemas:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas''${GSETTINGS_SCHEMA_DIR:+:$GSETTINGS_SCHEMA_DIR}"
    exec ${pkgs.python3.withPackages (ps: [ ps.pygobject3 ps.coloraide ])}/bin/python3 "${config.home.homeDirectory}/scripts/wallust-studio/main.py" "$@"
  '';
in
{
  home.packages = with pkgs; [
    wallust
    papirus-folders
    gtk3
    wallustStudio
  ];

  # Configuración del Cursor
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = "Natsuki";
    package = pkgs.stdenv.mkDerivation {
      name = "natsuki-cursor";
      src = ../../../modules/shared/assets/cursors/Natsuki;
      installPhase = ''
        mkdir -p $out/share/icons/Natsuki
        cp -r * $out/share/icons/Natsuki/
      '';
    };
    size = 24;
  };

  # Configuración Base de GTK
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4 = {
      theme = null;
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
    };
  };

  # Archivos y Plantillas de Wallust
  home.file.".config/themes.json" = {
    source = ./themes.json;
    force = true;
  };

  home.file.".config/wallust" = {
    source = ./wallust;
    recursive = true;
  };

  # Stylix: Evitar sobreescritura de herramientas tematizadas dinámicamente por Wallust
  stylix.targets = {
    hyprland.enable = false;
    waybar.enable = false;
    kitty.enable = false;
    rofi.enable = false;
    micro.enable = false;
    gtk.enable = false;
    gnome.enable = false;
    yazi.enable = false;
  };
}
