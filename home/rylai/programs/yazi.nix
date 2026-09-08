{ ... }:

{
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
}
