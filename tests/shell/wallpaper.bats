setup() {
  load helpers; setup_sandbox
  stub awww; stub awww-daemon; stub wallust; stub notify-send
  W="$HOME/Pictures/wallpapers"; : > "$W/a b.jpg"; : > "$W/fondo ñandú.jpg"
  S="$REPO/home/rylai/scripts/wallpaper.sh"
}
daemon_down_until_started() {
  stub_script awww "echo \"awww \$*\" >> '$STUB_LOG'; [ \"\$1\" = query ] && [ ! -e '$BATS_TEST_TMPDIR/up' ] && exit 1; exit 0"
  stub_script awww-daemon "echo awww-daemon >> '$STUB_LOG'; : > '$BATS_TEST_TMPDIR/up'"
}
@test "set uses awww fade transition" {
  run "$S" --set "$W/a b.jpg"
  [ "$status" -eq 0 ]
  grep -qF "awww img $W/a b.jpg --transition-type fade --transition-duration 0.6 --transition-fps 30" "$STUB_LOG"
}
@test "set passes exact path with spaces and accents to wallust" {
  run "$S" --set "$W/fondo ñandú.jpg"
  [ "$status" -eq 0 ]
  grep -qF "awww img $W/fondo ñandú.jpg" "$STUB_LOG"
  grep -qF "wallust run $W/fondo ñandú.jpg" "$STUB_LOG"
}
@test "set ignores legacy active_theme file" {
  printf nord > "$HOME/.local/state/theme/active_theme.txt"
  run "$S" --set "$W/a b.jpg"
  [ "$status" -eq 0 ]
  grep -q '^wallust run' "$STUB_LOG"
}
@test "set writes only current_path" {
  run "$S" --set "$W/a b.jpg"
  [ "$(cat "$HOME/.local/state/wallpaper/current_path.txt")" = "$W/a b.jpg" ]
  [ ! -e "$HOME/.local/state/wallpaper/current" ]
  [ ! -e "$HOME/.local/state/theme/active_theme.txt" ]
}
@test "set applies saved studio profile instead of wallust run" {
  h=$(sha256sum "$W/a b.jpg" | cut -d' ' -f1)
  mkdir -p "$HOME/.local/state/wallust-studio/profiles"
  echo '{}' > "$HOME/.local/state/wallust-studio/profiles/$h.json"
  run "$S" --set "$W/a b.jpg"
  grep -q '^wallust cs' "$STUB_LOG"
  ! grep -q '^wallust run' "$STUB_LOG"
}
@test "set on missing file fails without touching awww" {
  run "$S" --set /nope.jpg
  [ "$status" -eq 1 ]
  ! grep -q '^awww' "$STUB_LOG"
}
@test "theme-sync runs exactly once per set" {
  run "$S" --set "$W/a b.jpg"
  [ "$(grep -c '^theme-sync' "$STUB_LOG")" -eq 1 ]
}
@test "serializes concurrent set calls" {
  stub_script wallust "echo START >> '$STUB_LOG'; sleep 1; echo END >> '$STUB_LOG'"
  "$S" --set "$W/a b.jpg" & "$S" --set "$W/fondo ñandú.jpg" & wait
  [ "$(grep -E '^(START|END)$' "$STUB_LOG" | tr '\n' ,)" = "START,END,START,END," ]
}
@test "restore uses no transition and no wallust" {
  printf '%s' "$W/a b.jpg" > "$HOME/.local/state/wallpaper/current_path.txt"
  run "$S" --restore
  [ "$status" -eq 0 ]
  grep -qF -- "awww img $W/a b.jpg --transition-type none" "$STUB_LOG"
  ! grep -q '^wallust' "$STUB_LOG"
}
@test "restore ignores stale current copy" {
  : > "$HOME/.local/state/wallpaper/current"
  run "$S" --restore
  grep -qF "awww img $W/" "$STUB_LOG"
  ! grep -qF "awww img $HOME/.local/state/wallpaper/current" "$STUB_LOG"
}
@test "set starts daemon when query fails" {
  daemon_down_until_started
  run "$S" --set "$W/a b.jpg"
  [ "$status" -eq 0 ]
  [ "$(grep -c '^awww-daemon' "$STUB_LOG")" -eq 1 ]
  grep -q '^awww img' "$STUB_LOG"
}
@test "restore starts daemon when query fails" {
  daemon_down_until_started
  printf '%s' "$W/a b.jpg" > "$HOME/.local/state/wallpaper/current_path.txt"
  run "$S" --restore
  [ "$status" -eq 0 ]
  [ "$(grep -c '^awww-daemon' "$STUB_LOG")" -eq 1 ]
}
@test "daemon timeout notifies and fails" {
  stub awww 1
  run "$S" --set "$W/a b.jpg"
  [ "$status" -eq 1 ]
  grep -q '^notify-send' "$STUB_LOG"
  ! grep -q '^wallust' "$STUB_LOG"
}
@test "wallust_bridge has no stale current fallback" {
  ! grep -q '"current"' "$REPO/home/rylai/scripts/wallust-studio/wallust_bridge.py"
}
teardown() {
  [ -f "$BATS_TEST_TMPDIR/sleep.pid" ] && kill "$(cat "$BATS_TEST_TMPDIR/sleep.pid")" 2>/dev/null || true
}
@test "long-lived daemon does not inherit the lock" {
  stub_script awww "echo \"awww \$*\" >> '$STUB_LOG'; [ \"\$1\" = query ] && [ ! -e '$BATS_TEST_TMPDIR/up' ] && exit 1; exit 0"
  stub_script awww-daemon "echo awww-daemon >> '$STUB_LOG'; : > '$BATS_TEST_TMPDIR/up'; sleep 30 & echo \$! > '$BATS_TEST_TMPDIR/sleep.pid'"
  run "$S" --set "$W/a b.jpg"
  [ "$status" -eq 0 ]
  start=$SECONDS
  run "$S" --set "$W/fondo ñandú.jpg"
  [ "$status" -eq 0 ]
  [ $((SECONDS - start)) -lt 5 ]
  [ "$(grep -c '^awww img' "$STUB_LOG")" -eq 2 ]
}
@test "restore waits for a concurrent set" {
  printf '%s' "$W/a b.jpg" > "$HOME/.local/state/wallpaper/current_path.txt"
  stub_script wallust "echo START >> '$STUB_LOG'; sleep 1; echo END >> '$STUB_LOG'"
  "$S" --set "$W/fondo ñandú.jpg" & sleep 0.3
  "$S" --restore; wait
  end=$(grep -n '^END$' "$STUB_LOG" | cut -d: -f1)
  rest=$(grep -n 'transition-type none' "$STUB_LOG" | cut -d: -f1)
  [ "$rest" -gt "$end" ]
}
