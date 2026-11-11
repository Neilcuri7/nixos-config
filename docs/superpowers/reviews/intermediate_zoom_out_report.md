# Stage 8: Intermediate Zoom Out Report

Target: `docs/superpowers/plans/2026-11-11-estandar-ui-wallpaper.md` (full file, lines 1-304)
Reviewer: egm-zoom-out (completed). Verdict: pass with revisions. 0 🔴, 5 🟡, 5 🟢.
Main point: most earlier findings are resolved by removing things from the plan, not by adding to it.

## A. New findings

| ID | Sev | Lines | Finding | Fix |
|---|---|---|---|---|
| ZO8-1 | 🟡 | 270-290 | `slot_nav.py` rebuilds what GTK4 already does: arrow keys move focus in a `Gtk.Grid`, and Space/Enter fire `clicked`. Risk: `window.py:45` binds `Return` to `win.apply`. | Add `Gtk.EventControllerFocus` (`enter`) to each swatch so it calls `_on_select_color_to_edit`. Remove `slot_nav.py` and its test. |
| ZO8-2 | 🟡 | 266-279, 288 | Dropping `style_tokens.py` empties `tests/python/`. That removes the unittest runner, Python from the harness, and the "clean process" test that cannot pass. | Add `css_manager.py` to the `FILES` in `style-standard.bats`, and grep for the 0.90 window background. |
| ZO8-3 | 🟡 | 290 | A toast shown after applying is never visible, because `apply_to_system()` closes the window (`controls_panel.py:351`). | Drop the toast. |
| ZO8-4 | 🟡 | 289-291 | Task 6 restates things that already exist (Ctrl+S/R/Esc, the 8×2 matrix, HSL, buttons). The Rofi preview row and the HeaderBar (about 46 px of 500) are speculative additions. | Limit R3 to: radius 0, a 1 px outline in place of `border 2px` + `box-shadow` (`css_manager.py:165-168`), no emoji (`controls_panel.py:221`), and focus selects the swatch. |
| ZO8-5 | 🟡 | 41, 150, 182-185 | The daemon needs a single owner. | Run `ensure_daemon` in both `set` and `restore`, and remove `exec_cmd("awww-daemon")`. Add the test `set starts daemon when query fails`. This also covers a daemon that crashes mid-session. |
| ZO8-6 | 🟢 | 156-160 | The diagnostic step is obsolete: Task 2 removes item 1, and Step 4 fixes items 2-4. | Cut it down to a before/after reproduction, or remove it. |
| ZO8-7 | 🟢 | 207 | `rounding = 0` already holds, so this test is a regression guard, not a failing test. | Label it as a guard, and add `appearance.nix` to the file map. |
| ZO8-8 | 🟢 | 32 | `selected` (0.20) is left orphaned, while `selected-accent` drops from 0.30 to 0.20. | Add one line saying whether `selected` is removed or kept. |
| ZO8-9 | 🟢 | 183 | CO-6 is not a real problem: `wallust_bridge.get_current_wallpaper()` reads `current_path.txt` first. | Say so in one clause. |
| ZO8-10 | 🟢 | 302 | The `matugen-wallpaper` exception is not needed. | Remove it. |

## B. Triage of earlier findings

**Adopt:**
- ZO-1/IC-2 → ZO8-5. The systemd unit is rejected.
- ZO-2/IC-1 (cheap variant): remove `alpha(@cc-bg, 0.9)` (`services.nix:100`), set the 0.90 alpha in the template, and add the negative grep `! grep 'alpha(@cc-bg' services.nix`. Nested cards keep their alpha because it is a design choice.
- ZO-3: rename the `themes.json` label in Task 2 and keep `setup_mini_thunar`. This removes the `--exclude` and the dependency from Task 2 to Task 6.
- ZO-4 → ZO8-2.
- ZO-N3/DE-M3 (part): name wlogout and `appearance.nix`, plus the line "no exceptions: dots/pills become squares".
- ZO-N4/DE-M5/SY-M2: move the canvas step to a follow-up outside the plan, and write R3's concrete criteria into the document.
- CO-3/CO-14/CO-19: `stub` takes an optional body or custom inline stubs, `setup_sandbox` creates `~/.local/state/theme`, and drop `jq`.
- CO-4: merge `cheatsheet rows are compact` into the first test, which is the one that actually runs the script.
- DE-M7: add `bash tests/run.sh` to AGENTS.md §5. Wiring it into `nix flake check` is rejected.
- SY-M5: label `nix shell .#…pkgs` as a plan rule.

**Adopt in reduced form (prose only):**
- DE-B1/ST-B1 Alternatives: four bullets (swaybg without transitions, hyprpaper without fade, mpvpaper is heavy on Kaveri, `tokens.nix` rejected).
- DE-B2/ST-M1 Risks: three bullets (Task 0 is the gate on `awww` and the plan stays on swaybg if it fails; daemon crash is covered by ZO8-5; rollback via `git revert` or a NixOS generation). Injection through `-theme-str` does not apply because the string is constant.
- DE-M1: a manual step for the legacy `active_theme.txt`: run `wallpaper.sh --set "$(cat …/current_path.txt)"` once, then `rm`. Permanent migration code is rejected.
- DE-N1/ST-M2/ST-M3: a two-line problem statement, plus non-goals (sizing for chinatsu, a lock shared with Studio, a token engine).

**Reject:**
- IC-1 `tokens.nix`: a second template layer that contradicts AGENTS.md §2.
- IC-3 coalescing: optimizes a burst case nobody reported, and breaks the meaning of the exit code. A timeout `notify-send` is optional.
- DE-M2/ZO-N6 shared lock with Studio: unlikely for a single user. Narrow Review Focus 1 to `wallpaper.sh` and list Studio as a non-goal.
- DE-M4 full token table: ZO8-8 is enough.
- DE-N3 extended fonts: typography was not requested.
- DE-M6 relative sizes for chinatsu: a non-goal is enough.
- ZO-N7: keep the cheatsheet arithmetic because it justifies R5.
- ST-N*, SY-N* cosmetic findings: only fix SY-M3/M4 (put the measurable targets into R4 and R5).

## Net effect
Removed: `style_tokens.py`, `slot_nav.py` and both Python tests, the unittest runner, the autostart daemon line, the `--exclude`, the canvas step, the toast, the Rofi preview row, the HeaderBar, and the obsolete diagnosis. Added: about 15 lines of prose, one negative grep, one daemon test, and one line in AGENTS.md §5.
