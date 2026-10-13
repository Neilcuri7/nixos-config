#!/usr/bin/env bash
# Wallust Studio launcher script
if command -v wallust-studio &>/dev/null && [ "$(command -v wallust-studio)" != "$0" ]; then
    exec wallust-studio "$@"
fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
exec python3 "$SCRIPT_DIR/wallust-studio/main.py" "$@"
