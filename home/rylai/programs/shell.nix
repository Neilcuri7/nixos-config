{ ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      brave-dev = "brave --remote-debugging-port=9222 --user-data-dir=\"$HOME/.config/brave-dev\" &>/dev/null & disown";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      brave-dev = "brave --remote-debugging-port=9222 --user-data-dir=\"$HOME/.config/brave-dev\" &>/dev/null & disown";
    };
    history = {
      size = 10000;
      share = true;
    };
  };
}
