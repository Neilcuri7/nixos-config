# Consolidated EGM Review Report

**Target:** `docs/superpowers/plans/2026-11-11-estandar-ui-wallpaper.md` (304 lines)
**Mode:** Consolidated report (uninterrupted). Split at line 86: FeatureRange 1-85, DetailedRange 86-304.
**GoldfishContext:** the 11 repository files the user approved. The design canvas (a private URL) was excluded.
**Date:** 2026-11-11

## Stage status

| Stage | Report | Reviewers (all completed) | Verdict |
|---|---|---|---|
| 5 Initial Zoom Out | `zoom_out_report.md` | egm-zoom-out, egm-inventive-catalyst | Pass with revisions |
| 6 Comprehension | `comprehension_report.md` | egm-comprehension | 0 🔴, 8 🟡, 12 🟢 |
| 7 Critic | `critic_report.md` | egm-design, egm-structural, egm-style | **FAIL** (design, structural) |
| 8 Intermediate Zoom Out | `intermediate_zoom_out_report.md` | egm-zoom-out | Pass with revisions; triage of the other stages |
| 9 Implementation Readiness | `implementation_readiness_report.md` | egm-implementation-readiness, egm-codebase-details, egm-style | **FAIL** / not ready |

No reviewer failed or was left out.

## Overall finding

The plan's direction holds up. Every reviewer agrees on four points:
- removing `theme-switcher.sh` fixes the login-time race at its source;
- grep tests are a proportionate guard;
- moving Rofi styling into `rofi.rasi` is right;
- the `wallpaper.sh` CLI stays the same.

**The plan cannot be executed as written.**
- Several tests cannot pass as they are written.
- Some decisions are still left to the implementer: the daemon, SwayNC, wlogout, `selected`, and what happens to the window after Apply.
- Task 6 adds UI that already exists or that can never be seen.

Stage 8 shows that most of the fixes **remove** material from the plan.

---

## Consolidated actions by priority

### 🔴 Blockers (resolve before executing)

| # | Action | Origin |
|---|---|---|
| A1 | **Wallust Studio after "Apply"**: drop the `Adw.Toast` and keep apply-then-close (`controls_panel.py:351`). Also drop the HeaderBar and the Rofi preview row. Limit R3 to: radius 0, a 1 px outline in place of `border 2px` + `box-shadow`, no 🔄 emoji, and focus selects the swatch. Mark as "keep" what already exists: the 8×2 matrix, HSL, Ctrl+S/R/Esc. | IR-B1, CD-M11, CD-M12, ZO8-3, ZO8-4, ZO-N2, CD-N8 |
| A2 | **Add "Alternativas consideradas"** (reduced form, 4 bullets): swaybg (no transitions), hyprpaper (no fade), mpvpaper (video pipeline, heavy on Kaveri), `tokens.nix` (rejected because it is a second template engine, which contradicts AGENTS.md §2). | DE-B1, ST-B1, IC-1 |
| A3 | **Add "Riesgos y mitigaciones"** (3-4 bullets): (1) `awww` missing from the pinned nixpkgs → Task 0 is a gate; if it fails, stay on swaybg with no fade. (2) The daemon dies mid-session → `ensure_daemon` runs on every call (A4). (3) Rollback: `git revert` or the previous NixOS generation. (4) Legacy state migration (A9). | DE-B2, ST-M1, IR-N1 |

### 🟡 Major

| # | Action | Origin |
|---|---|---|
| A4 | **One owner for the daemon**: `ensure_daemon` in **set and restore**; remove `exec_cmd("awww-daemon")` from autostart. Start it detached with `setsid -f awww-daemon`, wait up to 2 s, and on timeout send `notify-send` and exit 1. Add the test `set starts daemon when query fails`. | ZO-1, IC-2, ZO8-5, IR-M4, CD-M5, SY-M8 |
| A5 | **Harness**: `setup_sandbox` must also create `~/.local/state/theme`, set `XDG_RUNTIME_DIR=$BATS_TEST_TMPDIR`, and install a `theme-sync.sh` stub that logs `theme-sync $*`. Add a `stub_script <cmd> <body>` helper for custom stubs. `run.sh` does `cd` to the repo root, runs only bats (no Python), and drops `jq`. Add `smoke.bats` to the file map. | IR-M1/M2/M3, CD-M1-M4, CO-3, CO-14, CO-19, SD-M1, IR-N5, CD-N9 |
| A6 | **Remove `style_tokens.py`, `slot_nav.py` and the Python tests**: edit the literals in `css_manager.py` (radius 0 including `9999px`, no `box-shadow`, window background 0.90). Add `css_manager.py` to `style-standard.bats`. Implement focus = selection with `Gtk.EventControllerFocus` calling `_on_select_color_to_edit(self.color_buttons[idx], idx)`. | ZO-4, ZO8-1, ZO8-2, IR-M12, CD-M10, SD-M10, CO-17, IR-N8 |
| A7 | **SwayNC opacity, once only**: set the template to `cc-bg`/`noti-bg` 0.90; in `services.nix:100` use `background: @cc-bg;`. Add the negative test `! grep 'alpha(@cc-bg' services.nix`. Nested cards keep their alpha on purpose. Waybar: change `alpha(@surface, 0.85)` to 0.90, and use a negative grep for any other surface alpha. | ZO-2, IC-1 (cheap), IR-M9, CD-M9, SD-M9 |
| A8 | **Full scope of R2**: name wlogout (`services.nix:23`) and `appearance.nix` (as a regression guard, already at 0). Add the line "no exceptions: dots/pills/close-button become square". Add `rofi-clipboard.sh` to the file map (it already complies). | ZO-N3, DE-M3, IR-M7, CD-M8, SD-M8, CO-7, ZO8-7, IR-N6 |
| A9 | **Legacy state**: Task 3 removes `THEME_STATE_DIR`/`ACTIVE_THEME_FILE`, their `mkdir`, and the `matugen-wallpaper` branch. Add a manual step at the end of Task 3: `wallpaper.sh --set "$(cat ~/.local/state/wallpaper/current_path.txt)"` then `rm -r ~/.local/state/theme`. No permanent migration code. | DE-M1, IR-M6, CD-M7, IR-M3 |
| A10 | **The `current` file**: also remove the `current` fallback in `wallust_bridge.py:13-15` and in `restore_wallpaper`. Fallback order becomes `current_path.txt` → first file in the directory (state that the intermediate fallback is removed on purpose). Manual step: `rm ~/.local/state/wallpaper/current`. | CO-6, IR-M5, CD-M6, SD-M4, ZO8-9 |
| A11 | **rofi-colors.rasi, explicit edit**: `background {{background}}e6`, `input-bg` 0.12, `selected-accent` 0.20, `border-col` 0.35. **Delete `selected`** (unused). List which grid rules from `wallpaper.sh` move to `rofi.rasi` (selection state only). Grid rules (centering, `element-icon size`, `orientation`) stay in `-theme-str`. Rewrite the rule as "scripts never override color, border, or radius". | ZO8-8, DE-M4, IR-M8, IR-M10, CD-N7, SD-M7 |
| A12 | **Monolito values in the plan**, so it does not depend on the canvas: window `width 520px; padding 0; border 1px @border-col`; mainbox `spacing 0`; inputbar `padding 14px 16px`, bottom border 1 px; listview `lines 8; padding 8px; spacing 2px`; element `padding 10px`; selected = `@selected-accent` background + `border 1px @accent`. | IR-M11, DE-M5, ST-M5, SY-M1/M2, CO-8 |
| A13 | **Cheatsheet**: merge "rows are compact" into the test that actually runs the script. Use **82%** in Task 0 too. Base the width on the longest row (`hypr-cheatsheet.sh:19`, about 84 characters × about 8 px at 10pt ≈ 680 px < 765 px). Call the 750 px figure an "estimate" and state the Waybar height. Keep `prompt`/`entry` at 10.5. Set `lines` explicitly if Task 0 says it applies. | IR-M14, CD-N4, CD-N6, IR-N2, SD-M5, SD-M6, SY-M7, IR-N7 |
| A14 | **Task 2, rename and clean up**: rename the `themes.json` label in `preview_panel.py:215` to `wallust.toml` in Task 2 and keep `setup_mini_thunar`. This removes the `--exclude` and the dependency from Task 2 to Task 6. Delete the whole `default.nix:76-79` block. | ZO-3, CO-13, CD-N2, SD-N2 |
| A15 | **Task 7, final grep**: add `--exclude-dir=tests`, drop the `matugen` exception, and exclude `AGENTS.md` §5 (it lists those names on purpose). | CO-1, ZO-N5, ZO8-10, IR-M13, CD-M13, SD-M12 |
| A16 | **Mandatory gate**: add `bash tests/run.sh` to AGENTS.md §5 and to the plan's Global Constraints. Do not wire it into `nix flake check`. | DE-M7 |
| A17 | **Measurable requirements**: R3 = A1's criteria. R4 = "fade 0.6 s at 30 fps, one `wallust` per change, `--restore` without wallust, daemon on demand". R5 = "fixed window 56%×82% of the monitor, no `lines: 17`/`950px`". Add a 2-line problem statement and non-goals (chinatsu sizing, a lock shared with Studio, a token engine, typography). | SY-M1/M3/M4, ST-M2/M3, DE-N1, DE-M6, DE-M2 (as a non-goal) |
| A18 | **Task 3 diagnosis**: reduce it to "reproduce two `--set` calls before the change, as a before/after record". Remove the items Task 2 already resolves. Fix the line number from 81 to 78. Drop "A8/lento" and the "race over templates" claim. | ZO8-6, CO-5, IR-M6, CD-N1, CD-N3, SD-M2, SD-M3 |
| A19 | **New Python files and the flake**: no longer needed if A6 is adopted. If any new `.py` remains, run `git add` before `home-manager switch`. | IR-N8 |

### 🟢 Nits (apply as a batch)

| # | Action | Origin |
|---|---|---|
| A20 | Rename `nix shell .#…pkgs` to "plan rule", not an AGENTS.md rule. | SY-M5 |
| A21 | Review Focus: drop "acentos" or add an accent case. Narrow #1 to concurrent `wallpaper.sh` calls. Narrow #5 to "does not change size". | SY-M6, SY-M7, DE-M2, ZO-N6, CD-N9 |
| A22 | Write complete test bodies, without `…`. Use `unittest.TestCase` only if Python remains. Use `find … -name '*.py'` instead of `**`. | CO-4, SD-N7, SD-M11, CO-20 |
| A23 | Mark the canvas step as a follow-up outside the plan, done by the main session. | ZO-N4, ST-N4, SY-N4 |
| A24 | Wording: "asserta" → "comprueba"; the "dispatch exit" parenthetical; "misma opacidad"; define `theme-sync.sh`, `awww`, Kaveri/A8, `theme-str`; font sizes in `pt`; the `cleanSourceWith` reason; reference by content instead of line number where possible. | SD-N1, SD-N3, SD-N6, CO-9, CO-10, CO-11, SY-N*, ST-N7 |

### Rejected (by the Stage 8 triage, with reasons)

| Proposal | Reason for rejecting |
|---|---|
| `tokens.nix` + generated `tokens.json` (IC-1) | A second template engine, which contradicts AGENTS.md §2. Adds a rebuild to every style tweak. |
| Coalescing queue `pending_path.txt` (IC-3) | Optimizes a case nobody reported. Exit code 0 would no longer mean "applied". |
| A `systemd.user` unit for `awww` (IC-2) | Ordering against `WAYLAND_DISPLAY` is fragile, and it creates a second owner of the daemon. |
| A lock shared with Wallust Studio (DE-M2) | Unlikely with a single user. It becomes a non-goal. |
| A full token→variable table (DE-M4) | One line about `selected` (A11) is enough. |
| Font token extended to Inter/Bold 12 (DE-N3) | Typography was not requested. |
| Wiring bats into `nix flake check` (DE-M7) | Needs a derivation, a `HOME` sandbox and stubs. Too much for a dotfiles repository. |
| Restructuring as a feature spec (ST-N*, SY-N* cosmetics) | This is a superpowers implementation plan. Only the reduced sections A2/A3/A17 are adopted. |

---

## Traceability matrix

| Raw finding | → Action |
|---|---|
| ZO-1, IC-2, ZO8-5, IR-M4, CD-M5, SY-M8 | A4 |
| ZO-2, IC-1, IR-M9, CD-M9, SD-M9 | A7 (IC-1 heavy variant rejected) |
| ZO-3, CO-13, SD-N2, CD-N2 | A14 |
| ZO-4, ZO8-1, ZO8-2, CO-17, IR-M12, CD-M10, SD-M10, IR-N8 | A6, A19 |
| ZO-N1 | A6 |
| ZO-N2, ZO8-3, ZO8-4, IR-B1, CD-M11, CD-M12, CD-N8 | A1 |
| ZO-N3, DE-M3, IR-M7, CD-M8, SD-M8, CO-7, ZO8-7, IR-N6 | A8 |
| ZO-N4, ST-N4, SY-N4 | A23 |
| ZO-N5, CO-1, ZO8-10, IR-M13, CD-M13, SD-M12 | A15 |
| ZO-N6, DE-M2, CD-N9 | A17 (non-goal), A21 |
| ZO-N7 | Rejected (keep the arithmetic as R5's justification) |
| IC-3 | Rejected |
| CO-2 | A24 (one line explaining the Studio profile: sha256 of the image content, already in `wallpaper.sh:62-69`) |
| CO-3, CO-14, CO-19, IR-M1/M2/M3, CD-M1-M4, SD-M1, IR-N5 | A5 |
| CO-4, IR-M14, CD-N4 | A13, A22 |
| CO-5, ZO8-6, CD-N1, CD-N3, SD-M2, SD-M3 | A18 |
| CO-6, IR-M5, CD-M6, SD-M4, ZO8-9 | A10 |
| CO-8, IR-M11, DE-M5, ST-M5, SY-M1, SY-M2 | A12, A1 |
| CO-9…CO-12, CO-15, CO-16, CO-18, SD-N*, SY-N*, ST-N* | A24 |
| CO-20, SD-M11 | A22 |
| DE-B1, ST-B1 | A2 |
| DE-B2, ST-M1, IR-N1 | A3 |
| DE-M1, IR-M6, CD-M7 | A9 |
| DE-M4, ZO8-8, IR-M8, IR-M10, CD-N7, SD-M7 | A11 |
| DE-M6, SY-M3, SY-M4, ST-M2, ST-M3, DE-N1, ST-M4 | A17 |
| DE-M7 | A16 |
| DE-N2 | A11 (accepted literals: `e6` in RASI, `0.90` in CSS/Nix) |
| DE-N3 | Rejected |
| DE-N4 | A24 (cite `hyprctl monitors` / `lscpu` from 2026-11-11) |
| SY-M5 | A20 |
| SY-M6, SY-M7 | A21 |
| SD-M5, SD-M6, CD-N6, IR-N2, IR-N7 | A13 |
| IR-N3, CD-M2 | A5 |
| IR-N4 | A14 |
