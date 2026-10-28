{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    plugins = {
      inherit (pkgs.yaziPlugins) smart-enter git;
    };

    initLua = ''
      require("git"):setup()
    '';

    keymap = {
      manager.prepend_keymap = [
        {
          on = [ "<C-h>" ];
          run = "hidden toggle";
          desc = "Alternar archivos ocultos";
        }
        {
          on = [ "l" ];
          run = "plugin smart-enter";
          desc = "Entrar al directorio o abrir archivo (smart-enter)";
        }
        {
          on = [ "<Enter>" ];
          run = "plugin smart-enter";
          desc = "Entrar al directorio o abrir archivo (smart-enter)";
        }
      ];
    };
    settings = {
      open = {
        prepend_rules = [
          { url = "*/"; use = [ "open" "reveal" ]; }
          { mime = "text/*"; use = [ "edit" "reveal" ]; }
          { mime = "application/json"; use = [ "edit" "reveal" ]; }
          { mime = "application/x-ndjson"; use = [ "edit" "reveal" ]; }
          { mime = "application/*toml"; use = [ "edit" "reveal" ]; }
          { mime = "application/x-yaml"; use = [ "edit" "reveal" ]; }
          { mime = "application/xml"; use = [ "edit" "reveal" ]; }
          { mime = "application/x-shellscript"; use = [ "edit" "reveal" ]; }
          { mime = "application/javascript"; use = [ "edit" "reveal" ]; }
          { mime = "application/typescript"; use = [ "edit" "reveal" ]; }
          { url = "*.*"; use = [ "edit" "reveal" ]; }
          { url = "*"; use = [ "edit" "reveal" ]; }
        ];
      };
      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";
          }
        ];
      };
      opener = {
        edit = [
          {
            run = "micro %s";
            block = true;
            desc = "micro";
            for = "unix";
          }
        ];
      };
    };
  };
}
