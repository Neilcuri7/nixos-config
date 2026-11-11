setup() {
  load helpers; setup_sandbox
  stub_script rofi "cat >/dev/null; printf '%s\n' \"\$@\" >> '$STUB_LOG'"
}
@test "cheatsheet window is relative, fixed and compact" {
  run "$REPO/home/rylai/scripts/hypr-cheatsheet.sh"
  [ "$status" -eq 0 ]
  grep -qF 'window { width: 56%; height: 82%; }' "$STUB_LOG"
  grep -qF 'listview { scrollbar: true; }' "$STUB_LOG"
  grep -qF 'element { padding: 3px 10px; }' "$STUB_LOG"
  ! grep -qE 'width: 950px|lines: 17' "$STUB_LOG"
}
