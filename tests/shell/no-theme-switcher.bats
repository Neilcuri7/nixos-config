setup() { load helpers; }
@test "no references to the fixed theme selector remain" {
  run grep -rnE 'theme-switcher|themes\.json|Menú de temas' "$REPO" \
      --exclude-dir=.git --exclude-dir=docs --exclude-dir=tests --exclude-dir=.superpowers
  [ "$status" -eq 1 ]
}
@test "theme files are gone" {
  [ ! -e "$REPO/home/rylai/scripts/theme-switcher.sh" ]
  [ ! -e "$REPO/home/rylai/theme/themes.json" ]
}
@test "AGENTS.md requires running the test suite" {
  grep -qF 'bash tests/run.sh' "$REPO/AGENTS.md"
}
