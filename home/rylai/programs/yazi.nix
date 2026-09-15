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
      open = {
        rules = [
          { name = "*/"; use = [ "edit" "open" "reveal" ]; }
          { mime = "text/*"; use = [ "edit" "reveal" ]; }
          { mime = "application/json"; use = [ "edit" "reveal" ]; }
          { mime = "application/x-ndjson"; use = [ "edit" "reveal" ]; }
          { mime = "application/*toml"; use = [ "edit" "reveal" ]; }
          { mime = "application/x-yaml"; use = [ "edit" "reveal" ]; }
          { mime = "application/xml"; use = [ "edit" "reveal" ]; }
          { name = "*"; use = [ "edit" "open" "reveal" ]; }
        ];
      };
    };
  };
}
