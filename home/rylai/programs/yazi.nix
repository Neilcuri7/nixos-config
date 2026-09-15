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
        {
          on = [ "<Enter>" ];
          run = "enter";
          desc = "Entrar a carpeta o abrir archivo";
        }
      ];
    };
    settings = {
      opener = {
        edit = [
          {
            run = ''if [ -f "$0" ]; then micro "$0" "$@"; else micro "$@"; fi'';
            block = true;
            desc = "micro";
            for = "unix";
          }
        ];
      };
    };
  };
}
