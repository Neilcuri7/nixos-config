#!/usr/bin/env bash
cd "$(dirname "$0")/.." || exit 1
exec nix shell .#nixosConfigurations.haimiya.pkgs.bats -c bats tests/shell
