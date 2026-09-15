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

  home.activation.createMicroTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.config/micro/colorschemes
    if [ ! -f $HOME/.config/micro/colorschemes/current-theme.micro ]; then
      $DRY_RUN_CMD cat << 'EOF' > $HOME/.config/micro/colorschemes/current-theme.micro
color-link default "#e5e9f0,default"
color-link comment "#4c566a,default"
color-link identifier "#bf616a,default"
color-link constant "#d08770,default"
color-link constant.string "#a3be8c,default"
color-link constant.number "#d08770,default"
color-link statement "#b48ead,default"
color-link symbol "#88c0d0,default"
color-link preproc "#81a1c1,default"
color-link type "#ebcb8b,default"
color-link special "#88c0d0,default"
color-link underlined "#81a1c1,default"
color-link error "bold #bf616a,default"
color-link todo "bold #ebcb8b,default"
color-link statusline "#e5e9f0,#3b4252"
color-link tabbar "#d8dee9,#3b4252"
color-link line-number "#4c566a,default"
color-link current-line-number "bold #81a1c1,default"
color-link cursor-line "#434c5e,default"
color-link color-column "#434c5e,default"
color-link divider "#4c566a,default"
color-link indent-char "#4c566a,default"
EOF
    fi
  '';
}
