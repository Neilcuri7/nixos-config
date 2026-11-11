# Stage 9: Implementation Readiness Report

Target: `docs/superpowers/plans/2026-11-11-estandar-ui-wallpaper.md`, DetailedRange lines 86-304
Reviewers: egm-implementation-readiness (completed, FAIL, 1 🔴, 14 🟡, 8 🟢), egm-codebase-details (completed, not ready, 0 🔴, 13 🟡, 9 🟢), egm-style (completed, 0 🔴, 12 🟡, 9 🟢)
Standard: implementation-readiness-standard

## egm-implementation-readiness

| ID | Sev | Lines | Finding |
|---|---|---|---|
| IR-B1 | 🔴 | 289-294 | The toast can never be seen: `apply_to_system()` calls `cancel()`, which closes the window. There is no `Adw.ToastOverlay`. The plan advertises shortcuts but never specifies them (they turn out to already exist in `window.py`). Decision needed: does the window close after applying? |
| IR-M1 | 🟡 | 110, 113 | `tests/python/` does not exist. Python 3.12+ exits with code 5 when no tests run. `run.sh` does not `cd` to the repo root. |
| IR-M2 | 🟡 | 107-108 vs 175, 179, 239 | The `stub` helper cannot express what the tests need: `awww` exiting 1 only for `query`, `wallust` writing START/END, and `theme-sync` logging. |
| IR-M3 | 🟡 | 170, 183 | `~/.local/state/theme` is never created. The plan does not say what happens to `THEME_STATE_DIR`/`ACTIVE_THEME_FILE`. |
| IR-M4 | 🟡 | 182-185 | `ensure_daemon` has no defined behavior on timeout. `set` does not call it, and under `set -e` that aborts before `wallust`. The daemon is not detached (`setsid`/`nohup`). |
| IR-M5 | 🟡 | 183-184 | Removing `current` affects code that reads it but was not audited. The "como hoy" fallback statement is inaccurate. The stale file is left behind. |
| IR-M6 | 🟡 | 141, 157, 170 | No migration for a legacy `active_theme.txt` set to `nord`. The diagnosis in Task 3 contradicts Task 2. |
| IR-M7 | 🟡 | 206, 223 | wlogout (`services.nix:23`) makes the radius test fail. |
| IR-M8 | 🟡 | 209, 221-223 | No step edits `rofi-colors.rasi`. The `selected` variable is left undecided. |
| IR-M9 | 🟡 | 194, 211, 223 | The SwayNC edit has no step. `alpha(@cc-bg, 0.9)` applies the opacity twice. |
| IR-M10 | 🟡 | 222 | The grid rules (centering, cell background) cannot move into global `rofi.rasi` without centering drun and the clipboard picker too. List which rules move and which are deleted. |
| IR-M11 | 🟡 | 221, 287, 291 | Monolito values exist only in the canvas: padding, spacing, border color, lines, 48/40 px heights, the Rofi preview structure, and the outline style. |
| IR-M12 | 🟡 | 267, 290 | `box-shadow` (`css_manager.py:167, 265`) contradicts "no shadows". The `.thunar-*` rules are dead. `_hex_to_rgba_css` must move. |
| IR-M13 | 🟡 | 302 | The final grep matches `tests/shell/no-theme-switcher.bats`. The `matugen` exception contradicts the rest. |
| IR-M14 | 🟡 | 242-249 | `cheatsheet rows are compact` never runs the script, so it always fails. |
| IR-N1…N8 | 🟢 | 96, 97/244/253, 112, 121, 159/183, 207, 253, 262-294 | No fallback if `pkgs.awww` is missing. 80% vs 82%. `smoke.bats` not in the file map. No content for `default.nix`. Line 81 should be 78, and the lock should live in `$BATS_TEST_TMPDIR`. The `rounding` test already passes. Prompt/entry fonts are dropped. New Python files not added to git break the flake build. Need `globstar`. `EventControllerKey` must return `True`. |

## egm-codebase-details

| ID | Sev | Lines | Finding |
|---|---|---|---|
| CD-M1 | 🟡 | 110, 113 | Same as IR-M1. The flake uses nixos-unstable, which means Python 3.13 and exit code 5. |
| CD-M2 | 🟡 | 102-103, 112 | `smoke.bats` is not in Create or the file map. |
| CD-M3 | 🟡 | 107, 170 | Same as IR-M3. |
| CD-M4 | 🟡 | 108, 174-179 | Same as IR-M2. |
| CD-M5 | 🟡 | 150, 182, 185 | Same as IR-M4. Autostart racing `ensure_daemon` starts a second daemon. |
| CD-M6 | 🟡 | 183-184, 154 | "como hoy" is inaccurate. `wallust_bridge.py:13-15` falls back to `current`, which would be stale forever. Studio does not call the `wallpaper.sh` CLI. |
| CD-M7 | 🟡 | 43, 157, 173 | Same as IR-M6. |
| CD-M8 | 🟡 | 204-223 | Same as IR-M7. |
| CD-M9 | 🟡 | 31, 211, 223 | Double alpha. Step 3 must change `.control-center` to `background: @cc-bg;`. |
| CD-M10 | 🟡 | 266-267, 288 | `_hex_to_rgba_css` lives in a module that imports `gi`. `box-shadow` stays. `.thunar-*` rules are dead. |
| CD-M11 | 🟡 | 290 | Same as IR-B1 (toast). |
| CD-M12 | 🟡 | 289 | There is no `Adw.HeaderBar`, so one would need `ToolbarView`. Missed reuse: `ControlsPanel._get_active_wallpaper()`. |
| CD-M13 | 🟡 | 302 | Same as IR-M13. `AGENTS.md:98` contains `matugen`, `desktop-tools.nix` and `converter-shell.nix` literally. |
| CD-N1 | 🟢 | 159 | The line should be 78, not 81. |
| CD-N2 | 🟢 | 73, 121 | The `themes.json` block in `default.nix` is lines 76-79. Deleting only 76-77 breaks Nix. |
| CD-N3 | 🟢 | 157 | `--restore` does not write templates, so "race over templates" overstates it. |
| CD-N4 | 🟢 | 248 | Same as IR-M14. |
| CD-N5 | 🟢 | 207 | The rounding test already passes. |
| CD-N6 | 🟢 | 97, 253 | 80% vs 82%. The longest line is `hypr-cheatsheet.sh:19` at about 84 characters. |
| CD-N7 | 🟢 | 198 | `selected` is omitted. The "size/layout only" rule is broken by the plan itself. |
| CD-N8 | 🟢 | 262, 290 | Paths are not relative to the repo. Some items already exist and should be marked "keep". `_on_select_color_to_edit(btn, idx)` needs the button. `Return` triggers `win.apply`. |
| CD-N9 | 🟢 | 183 | The lock is shared with the live session in bats. Studio does not take the lock. |

Confirmed accurate: `keybinds.nix:51`, `autostart.nix:34`, `hyprland.nix:33`, `services.nix:153`, `preview_panel.py:215`, `default.nix:144`, kitty 0.80, rofi `ee`, gtk 4px, waybar 0.85, window 880×500, Ctrl+S/R/Esc, `950px`/`lines: 17`, `hypr-cheatsheet.sh:44`, AGENTS.md §1/§2, sleep 0.15 + kill, `current_path.txt` written atomically.

## egm-style (DetailedRange)

| ID | Sev | Lines | Finding |
|---|---|---|---|
| SD-M1 | 🟡 | 113 | Same as IR-M1. |
| SD-M2 | 🟡 | 159 | Line 81 should be 78. |
| SD-M3 | 🟡 | 157 | `restore` does not run wallust. "A8" is not defined. "lento" has no measurement. |
| SD-M4 | 🟡 | 184 | "como hoy" is inaccurate, because the intermediate fallback is removed. |
| SD-M5 | 🟡 | 237 | Says "medida" but the figures are estimates. The bar height is not given. |
| SD-M6 | 🟡 | 253 | The width should be justified by the full row, not by the key column. |
| SD-M7 | 🟡 | 198 vs 222, 253 | The closed list of override properties contradicts what the plan itself does. `@selected` is omitted. |
| SD-M8 | 🟡 | 206, 223 | wlogout. |
| SD-M9 | 🟡 | 211, 223 | Double alpha. |
| SD-M10 | 🟡 | 267 vs 27 | `box-shadow`. |
| SD-M11 | 🟡 | 294 | `**` needs `globstar`. |
| SD-M12 | 🟡 | 302 | The `matugen` exception contradicts the rest. |
| SD-N1…N9 | 🟢 | 112, 141, 156, 174, 143/221, 225, 272-283, 279, 110/295 | "asserta". `--exclude` is missing from the code. The parenthetical "dispatch exit" is confusing. Inline stub parenthetical. Canvas labels. Says "mismo fondo" where it should be "misma opacidad". Pseudocode vs TestCase. "Clean process". `jq` is unused, and "hud" is jargon. |
