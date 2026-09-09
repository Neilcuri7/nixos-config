{ ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
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
}
