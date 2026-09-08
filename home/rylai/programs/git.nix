{ config, pkgs, ... }:

{
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
}
