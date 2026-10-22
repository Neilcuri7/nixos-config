{ pkgs, ... }:

{
  # Localización y Zona Horaria
  time.timeZone = "America/Bogota";
  time.hardwareClockInLocalTime = true;
  i18n.defaultLocale = "es_CO.UTF-8";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Red y Firewall
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
  };
  services.tailscale.enable = true;

  # Servicios de Sistema
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # Configuración del Administrador de Paquetes Nix
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Virtualización
  virtualisation.docker.enable = true;

  # Shell y Usuario Base
  programs.zsh.enable = true;

  users.users.rylai = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" ];
  };

  # Stylix: Base del sistema para consola, fuentes y esquemas
  stylix = {
    enable = true;
    image = ./assets/wallpapers/angel.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    polarity = "dark";
    opacity = {
      terminal = 0.80;
      popups = 0.85;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
    };
  };
}
