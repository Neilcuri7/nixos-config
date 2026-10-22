{ ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      allow_remote_control = "yes";
      background_opacity = "0.80";
    };
    extraConfig = ''
      include ~/.config/kitty/current-theme.conf
    '';
  };
}
