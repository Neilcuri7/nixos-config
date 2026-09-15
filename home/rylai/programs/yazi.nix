{ ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    keymap = {
      manager.prepend_keymap = [
        {
          on = [ "<C-h>" ];
          run = "hidden toggle";
          desc = "Alternar archivos ocultos";
        }
      ];
    };
    settings = {
      opener = {
        edit = [
          {
            run = ''micro "$@"'';
            block = true;
            desc = "micro";
            for = "unix";
          }
        ];
      };
    };
  };
}
