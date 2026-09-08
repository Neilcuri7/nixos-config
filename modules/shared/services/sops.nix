{ config, lib, pkgs, ... }:

{
  options.myPlatform.services.sops = {
    enable = lib.mkEnableOption "Sops-nix secret management";
    ageKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "/home/rylai/.config/sops/age/keys.txt";
      description = "Path to the age key file used for decryption";
    };
  };

  config = lib.mkIf config.myPlatform.services.sops.enable {
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = config.myPlatform.services.sops.ageKeyFile;
      gnupg.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

    environment.systemPackages = [ pkgs.sops pkgs.age ];
  };
}
