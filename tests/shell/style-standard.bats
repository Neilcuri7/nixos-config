setup() { load helpers; cd "$REPO"; }
SH=(home/rylai/scripts/wallpaper.sh home/rylai/scripts/hypr-cheatsheet.sh home/rylai/scripts/rofi-clipboard.sh)
STYLE=(home/rylai/hyprland/services.nix home/rylai/theme/wallust/templates/gtk-colors.css "${SH[@]}")
SOFT=(home/rylai/programs/rofi.rasi home/rylai/waybar/style.css)
@test "no non-zero border-radius" {
  run grep -nP 'border-radius:\s*+(?!0(px)?\s*;)' "${STYLE[@]}"
  [ "$status" -eq 1 ]
}
@test "rofi and waybar only use radius 0, 8px or 16px" {
  run grep -nP 'border-radius:\s*+(?!(0|8px|16px)(\s+(0|8px|16px))*\s*;)' "${SOFT[@]}"
  [ "$status" -eq 1 ]
}
@test "rofi: window 16px, inputbar top corners 16px, element 8px" {
  f=home/rylai/programs/rofi.rasi
  sed -n '/^window {/,/^}/p' "$f" | grep -qF 'border-radius: 16px;'
  sed -n '/^inputbar {/,/^}/p' "$f" | grep -qF 'border-radius: 16px 16px 0 0;'
  sed -n '/^element {/,/^}/p' "$f" | grep -qF 'border-radius: 8px;'
}
@test "waybar: module groups 16px, workspace buttons 8px" {
  f=home/rylai/waybar/style.css
  sed -n '/^\.modules-left,/,/^}/p' "$f" | grep -qF 'border-radius: 16px;'
  sed -n '/^#workspaces button {/,/^}/p' "$f" | grep -qF 'border-radius: 8px;'
  sed -n '/^#workspaces button\.active {/,/^}/p' "$f" | grep -qF 'border-radius: 8px;'
}
@test "regression guard: hyprland rounding stays 0" {
  grep -q 'rounding = 0;' home/rylai/hyprland/appearance.nix
}
@test "rofi template uses tokens" {
  f=home/rylai/theme/wallust/templates/rofi-colors.rasi
  grep -qE '^\s*background:\s*\{\{background\}\}e6;' "$f"
  grep -qE '^\s*input-bg:.*0\.12\);' "$f"
  grep -qE '^\s*selected-accent:.*0\.20\);' "$f"
  grep -qE '^\s*border-col:.*0\.35\);' "$f"
  ! grep -qE '^\s*selected:' "$f"
}
@test "kitty opacity is 0.90" {
  grep -qF 'background_opacity = "0.90"' home/rylai/programs/kitty.nix
}
@test "swaync surfaces are 0.90 and not re-alpha'd" {
  f=home/rylai/theme/wallust/templates/swaync-colors.css
  grep -qE '^@define-color cc-bg .*0\.90\);' "$f"
  grep -qE '^@define-color noti-bg .*0\.90\);' "$f"
  ! grep -qF 'alpha(@cc-bg' home/rylai/hyprland/services.nix
}
@test "waybar surface is 0.90 only" {
  grep -qF 'alpha(@surface, 0.90)' home/rylai/waybar/style.css
  ! grep -qP 'alpha\(@surface, (?!0\.90\))' home/rylai/waybar/style.css
}
@test "rofi scripts never override color, border or radius" {
  run grep -nE '(background-color|text-color|border(-color|-radius)?)\s*:' "${SH[@]}"
  [ "$status" -eq 1 ]
}
@test "studio css: no radius, no shadow, window at 0.90" {
  f=home/rylai/scripts/wallust-studio/ui/css_manager.py
  run grep -nP 'border-radius:\s*+(?!0(px)?\s*;)' "$f"
  [ "$status" -eq 1 ]
  ! grep -q 'box-shadow' "$f"
  sed -n '/window.background, .app-window/,/}}/p' "$f" | grep -qF '_hex_to_rgba_css(bg, 0.90)'
}
