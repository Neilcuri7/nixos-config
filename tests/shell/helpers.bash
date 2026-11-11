# Shared bats helpers. Usage: setup() { load helpers; setup_sandbox; }
REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"

stub_script() {
  local cmd="$1" body="$2"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  printf '#!/usr/bin/env bash\n%s\n' "$body" > "$BATS_TEST_TMPDIR/bin/$cmd"
  chmod +x "$BATS_TEST_TMPDIR/bin/$cmd"
}

stub() {
  local cmd="$1" code="${2:-0}"
  stub_script "$cmd" "echo \"$cmd \$*\" >> \"\$STUB_LOG\"; exit $code"
}

setup_sandbox() {
  export HOME="$BATS_TEST_TMPDIR/home"
  export STUB_LOG="$BATS_TEST_TMPDIR/calls.log"
  export XDG_RUNTIME_DIR="$BATS_TEST_TMPDIR"
  mkdir -p "$HOME/Pictures/wallpapers" "$HOME/.config/wallust" \
    "$HOME/.local/state/theme" "$HOME/.local/state/wallpaper" \
    "$HOME/scripts" "$BATS_TEST_TMPDIR/bin"
  : > "$HOME/.config/wallust/wallust.toml"
  : > "$STUB_LOG"
  printf '#!/usr/bin/env bash\necho "theme-sync $*" >> "$STUB_LOG"\n' > "$HOME/scripts/theme-sync.sh"
  chmod +x "$HOME/scripts/theme-sync.sh"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}
