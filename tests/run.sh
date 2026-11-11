#!/usr/bin/env bash
cd "$(dirname "$0")/.." || exit 1
PYTHONDONTWRITEBYTECODE=1 exec nix shell .#nixosConfigurations.haimiya.pkgs.bats .#nixosConfigurations.haimiya.pkgs.python3 -c sh -c 'bats tests/shell && python3 -m unittest discover -s tests/python -t tests/python'
