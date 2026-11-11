setup() { load helpers; setup_sandbox; }
@test "stub records calls" {
  stub foo
  foo a b
  grep -qx "foo a b" "$STUB_LOG"
}
@test "stub_script runs custom body" {
  stub_script bar 'exit 7'
  run bar
  [ "$status" -eq 7 ]
}
@test "sandbox provides theme-sync stub" {
  "$HOME/scripts/theme-sync.sh" x
  grep -qx "theme-sync x" "$STUB_LOG"
}
