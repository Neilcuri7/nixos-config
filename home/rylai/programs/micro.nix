{ lib, ... }:

{
  stylix.targets.micro.enable = false;

  programs.micro = {
    enable = true;
    settings = {
      colorscheme = lib.mkForce "current-theme";
      tabsize = 4;
      tabstospaces = true;
      savecursor = true;
      softwrap = true;
      scrollbar = false;
      cursorline = true;
    };
  };
}
