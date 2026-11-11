# Stage 5: Initial Zoom Out Report

Target: `docs/superpowers/plans/2026-11-11-estandar-ui-wallpaper.md` (full file, lines 1-304)
Reviewers: egm-zoom-out (completed), egm-inventive-catalyst (completed)
Standard: zoom-out-standard

## egm-zoom-out

Verdict: pass with revisions. No blockers, 4 majors, 7 nits.

| ID | Sev | Lines | Finding | Proposed simplification |
|---|---|---|---|---|
| ZO-1 | 🟡 | 150, 182, 184-185 | Two places start `awww-daemon` (autostart `exec_cmd` plus `ensure_daemon`). `exec_cmd` returns immediately, so at login a second daemon can start. `--set` has no `ensure_daemon`. | Keep one: `ensure_daemon` in both `set` and `restore`, no autostart line. |
| ZO-2 | 🟡 | 31, 77, 211, 223 | SwayNC alpha is applied twice: `services.nix:100` `alpha(@cc-bg, 0.9)` on top of the template 0.90 gives about 0.81. The test only checks the template. 0.90 is a literal in 5 layers. | Set each token in one place. Put the alpha in the existing Wallust templates (`waybar-colors.css`, `kitty-colors.conf`). |
| ZO-3 | 🟡 | 141, 262, 291 | Deleting `setup_mini_thunar` only to remove a fake `themes.json` label is a symptom fix. It also creates the temporary exclusion and a dependency from Task 2 to Task 6. | Rename the label in Task 2 and keep the preview. |
| ZO-4 | 🟡 | 71, 79, 262-279, 288 | `style_tokens.py`: its constants are never used and the module exists only to make the code testable (YAGNI). | Edit the literals in `css_manager.py` and add the file to `style-standard.bats`. |
| ZO-N1 | 🟢 | 80, 268, 290 | `slot_nav.py` may duplicate GTK4's built-in arrow-key focus movement. | Check this in Task 0. Use a private method instead of a new module. |
| ZO-N2 | 🟢 | 290 | Task 6 restates widgets that already exist (8×2 matrix, HSL card, buttons). | List only the real changes: emoji, 1px outline in place of border + box-shadow, keyboard, toast. |
| ZO-N3 | 🟢 | 204, 206, 223 | wlogout (`services.nix:23`, 16px radius) is caught by the test but not named in the plan. | Name wlogout in R2. |
| ZO-N4 | 🟢 | 19, 143 | The canvas step is outside the repo and cannot be audited with `git diff`. | Move it to a follow-up outside the plan. |
| ZO-N5 | 🟢 | 302 | Task 7 Step 4 contradicts itself about `matugen-wallpaper`. | Remove the exception. |
| ZO-N6 | 🟢 | 40, 175, 183 | `flock` does not cover the "Aplicar" path in Wallust Studio. | Don't claim the lock is a guarantee for the whole system. |
| ZO-N7 | 🟢 | 206, 237, 253 | Low-level detail: regex, row-height arithmetic. | Move it to the research file. |

## egm-inventive-catalyst

No blockers (findings in REVIEW mode are advisory).

| ID | Sev | Lines | False compromise | Proposed transform | Costs |
|---|---|---|---|---|---|
| IC-1 | 🟡 | 7, 28-33, 194-223, 266 | "Single source of truth" vs "no template engine". The tokens are copied about 9 times, and the `grep -q` tests only prove that one matching line exists. SwayNC alpha stacks: about 0.81 for the control center and about 0.54 for the cards (`alpha(@noti-bg, 0.6/0.8)`, lines 173/184/200/210). | `home/rylai/theme/tokens.nix` interpolated by Nix into kitty, services, appearance, rofi and templates. Wallust Studio reads the generated `tokens.json`. Negative tests. Cheaper alternative: flatten every `alpha(@x, n)` wrapper and use negative greps. | Edit loop needs a rebuild; harder-to-read placeholders; larger scope. |
| IC-2 | 🟡 | 42, 150, 182-185, 174 | The daemon is protected only at login, and two launchers race. `--set` is not protected. | One owner: a `systemd.user` service with `Restart=on-failure`, or `ensure_daemon` as the only launcher in set and restore. Add test `set starts daemon when query fails`. | systemd: ordering against `WAYLAND_DISPLAY`. ensure_daemon: up to 2 s of latency, no restart. |
| IC-3 | 🟢 | 40, 175, 183, 187 | Strict queue with `flock -w 15`: picks that arrive in a burst run every pass on the A8. Past the timeout the script exits silently. | Coalescing: `pending_path.txt` + `flock -n`, and the last pick wins. Timeout triggers `notify-send`. | The exit code no longer means "applied"; more complex logic. |

## Overlap

- ZO-1 and IC-2 describe the same problem (duplicate daemon launch, `--set` not protected).
- ZO-2 and IC-1 describe the same problem (stacked alpha and tokens scattered across files).
