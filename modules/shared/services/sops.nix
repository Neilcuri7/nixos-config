{ config, lib, pkgs, ... }:

{
  options.myPlatform.services.sops = {
    enable = lib.mkEnableOption "Sops-nix secret management";
  };

  config = lib.mkIf config.myPlatform.services.sops.enable {
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/rylai/.config/sops/age/keys.txt";
      gnupg.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

    environment.systemPackages = [ pkgs.sops pkgs.age ];
  };
}
