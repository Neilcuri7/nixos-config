#!/usr/bin/env bash
# Wallust Studio launcher script
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
exec python3 "$SCRIPT_DIR/wallust-studio/main.py" "$@"
