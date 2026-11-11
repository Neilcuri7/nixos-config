**Status: resolved** (auto accept, 2026-11-11: 21 PROPOSE FIX aplicados; E1 → opción (a) mínima por defecto; 6 CONTEST y 1 DECLINE sin cambios)
**Actualización 2026-11-11:** el usuario cambió E1 a la opción (b) y añadió el botón "Original" (colores base del wallpaper, distinto de "Restaurar"). Tarea 6, R3, riesgos 6–7, Review Focus 6 y Tarea 0 Step 6 actualizados en el plan.

# Goldfish Annotated Review Report

**Target:** `docs/superpowers/plans/2026-11-11-estandar-ui-wallpaper.md` (full file, lines 1-304)
**Findings source:** `docs/superpowers/reviews/consolidated_review_report.md`. Raw findings with the same root cause are grouped under the consolidated action (A#). Every raw ID appears in the traceability matrix of that report.

Summary: 21 PROPOSE FIX · 6 CONTEST · 1 ESCALATE · 1 DECLINE

---

## ESCALATE (needs your decision)

### [E1] [`egm-implementation-readiness`, `egm-codebase-details`, `egm-zoom-out`]: Severity: Blocker
*   **Affected Scope:** Lines 258-295 (Task 6 Wallust Studio), line 21 (R3)
*   **Discrepancy Description:** The `Adw.Toast` shown after Apply can never be seen, because `apply_to_system()` closes the window (`controls_panel.py:351`). The HeaderBar and the Rofi preview row are new, speculative work. Task 6 also rebuilds things that already exist: the 8×2 matrix, HSL, and Ctrl+S/R/Esc. (IR-B1, CD-M11, CD-M12, ZO8-3, ZO8-4, ZO-N2)
*   **Rationale:** The plan leaves the post-Apply behavior to the implementer, and adds UI that has no clear purpose.
*   ***AI Suggestion:*** ESCALATE
*   ***Justification:*** The technical criticism is valid. But you asked to "mejorar apariencia **y usabilidad**". The scope the reviewers propose (radius 0, 1 px outline, no emoji, focus = selection) covers appearance but changes usability very little. Whether the window should stay open after Apply, and whether you want the header with the wallpaper name, are product decisions only you can make. Two options:
    *   **(a) Minimal** (the reviewers' option): apply then close; no toast, no header, no Rofi row.
    *   **(b) Usability+**: Apply **does not close** the window. A toast appears in an `Adw.ToastOverlay` that wraps `split_view` (`window.py:37`). Esc/Cancel still close it. Keep the header with the wallpaper name through `ControlsPanel._get_active_wallpaper()`. Drop the Rofi row.
*   ***Proposed Edit:*** Depends on your choice. Without an answer, (a) is applied.

---

## PROPOSE FIX

### [F1] A2: Alternatives considered: `egm-design`, `egm-structural`: Blocker
*   **Scope:** after line 23 (new section)
*   **Description:** Only one path is offered, with no rejected options documented. (DE-B1, ST-B1)
*   ***Justification:*** This is valid, and a human reader also needs to know why `awww` was chosen. A short version is enough, because this is an implementation plan.
*   ***Proposed Edit:*** New section `## Alternativas consideradas` with 4 bullets:
    *   `swaybg` with no changes: no transitions.
    *   `hyprpaper`: no fade.
    *   `mpvpaper`: video pipeline, too heavy for the R7.
    *   `tokens.nix` substituted by Nix: a second template engine, which AGENTS.md §2 forbids, and every style tweak would need a rebuild.

### [F2] A3: Risks and mitigations: `egm-design`, `egm-structural`: Blocker / Major
*   **Scope:** after the new section F1
*   **Description:** There is no analysis of risks, failures, or rollback. (DE-B2, ST-M1, IR-N1)
*   ***Proposed Edit:*** `## Riesgos y mitigaciones`:
    1.  `awww` is missing from the pinned nixpkgs → Task 0 is a gate; if it fails, keep `swaybg` with no fade and skip that part of Task 3.
    2.  The daemon dies mid-session → `ensure_daemon` on every `set`/`restore` (F3).
    3.  Rollback: `git revert` or the previous NixOS generation.
    4.  Leftover state from fixed themes → manual step (F7).
    5.  Injection through `-theme-str` does not apply: after Task 4 the string is constant.

### [F3] A4: Single daemon owner: `egm-zoom-out`, `egm-inventive-catalyst`, `egm-implementation-readiness`, `egm-codebase-details`: Major
*   **Scope:** lines 41, 150, 174, 182-185
*   **Description:** Two places start the daemon and they race at login. `--set` is not protected. Timeout behavior is undefined. (ZO-1, IC-2, ZO8-5, IR-M4, CD-M5, SY-M8)
*   ***Proposed Edit:***
    *   `ensure_daemon()` is called from `set_wallpaper` **and** `restore_wallpaper`. It starts `setsid -f awww-daemon`, then polls `awww query` every 0.1 s for up to 2 s. On timeout it runs `notify-send "Wallpapers" "awww-daemon no responde"` and `return 1`.
    *   Remove the autostart `exec_cmd("awww-daemon")` line.
    *   New test `set starts daemon when query fails`.
    *   Review Focus 2: "`--restore` y `--set` arrancan el daemon si no responde".

### [F4] A5: Test harness: `egm-comprehension`, `egm-implementation-readiness`, `egm-codebase-details`, `egm-style`: Major
*   **Scope:** lines 100-114
*   **Description:** `tests/python/` is missing and Python exits with code 5. `stub` is too limited. `~/.local/state/theme` is not created. `XDG_RUNTIME_DIR` is shared with the live session. `smoke.bats` is not in the file map. `jq` is unused. (IR-M1/M2/M3, CD-M1-M4, CO-3, CO-14, CO-19, SD-M1, IR-N3, IR-N5, CD-N9)
*   ***Proposed Edit:***
    *   `setup_sandbox` also creates `~/.local/state/{theme,wallpaper}`, exports `XDG_RUNTIME_DIR=$BATS_TEST_TMPDIR`, and installs `~/scripts/theme-sync.sh` that logs `theme-sync $*`.
    *   New helper `stub_script <cmd> <body>`.
    *   `run.sh` does `cd "$(dirname "$0")/.."` and runs `nix shell .#nixosConfigurations.haimiya.pkgs.bats -c bats tests/shell` only.
    *   Add `smoke.bats` to Create and to the file map.

### [F5] A6: Drop `style_tokens.py`, `slot_nav.py`, and the Python tests: `egm-zoom-out`: Major
*   **Scope:** lines 71, 79-81, 258-295
*   **Description:** These modules exist only to be testable. GTK4 already moves focus with the arrow keys. `box-shadow` violates "sin sombras". (ZO-4, ZO8-1, ZO8-2, IR-M12, CD-M10, SD-M10, CO-17, IR-N8, ZO-N1)
*   ***Proposed Edit:***
    *   Edit `css_manager.py` directly: every `border-radius` set to 0, no `box-shadow`, window background `_hex_to_rgba_css(bg, 0.90)`.
    *   Add `css_manager.py` to `FILES` in `style-standard.bats`, plus the tests `no box-shadow` and `studio window alpha 0.90`.
    *   Focus = selection: one `Gtk.EventControllerFocus` per swatch, whose `enter` handler calls `_on_select_color_to_edit(self.color_buttons[idx], idx)`.
    *   Remove the Python files and tests from the map. A19 is dropped.

### [F6] A7: SwayNC/Waybar opacity, single source: `egm-zoom-out`, `egm-inventive-catalyst`, `egm-implementation-readiness`, `egm-codebase-details`, `egm-style`: Major
*   **Scope:** lines 31, 77, 211-212, 223
*   **Description:** `alpha(@cc-bg, 0.9)` in `services.nix:100` applies a second alpha, giving about 0.81. The `grep -q` test only checks for one matching line. (ZO-2, IC-1 cheap variant, IR-M9, CD-M9, SD-M9)
*   ***Proposed Edit:***
    *   In `swaync-colors.css`, set `cc-bg` and `noti-bg` to 0.90.
    *   In `services.nix:100`, use `background: @cc-bg;`. Nested cards keep their current alpha on purpose (document this).
    *   In Waybar, change `alpha(@surface, 0.85)` to `0.90`.
    *   Negative tests: `! grep 'alpha(@cc-bg' services.nix` and `! grep -E 'alpha\(@surface, 0\.(?!90)' style.css`.

### [F7] A9: Leftover state: `egm-design`, `egm-implementation-readiness`, `egm-codebase-details`: Major
*   **Scope:** lines 43, 157, 170, 183
*   **Description:** If `active_theme.txt` says `nord`, the Nord templates survive. `THEME_STATE_DIR` is left unresolved. (DE-M1, IR-M6, CD-M7, IR-M3)
*   ***Proposed Edit:***
    *   Step 4 removes `THEME_STATE_DIR`, `ACTIVE_THEME_FILE`, their `mkdir`, and the `matugen-wallpaper` branch.
    *   New manual step at the end of Task 3: `wallpaper.sh --set "$(cat ~/.local/state/wallpaper/current_path.txt)" && rm -r ~/.local/state/theme`.

### [F8] A10: The `current` file: `egm-comprehension`, `egm-implementation-readiness`, `egm-codebase-details`, `egm-style`: Major
*   **Scope:** lines 183-184
*   **Description:** "como hoy" is inaccurate. `wallust_bridge.py:13-15` falls back to `current`, which would become stale. (CO-6, IR-M5, CD-M6, SD-M4)
*   ***Proposed Edit:***
    *   Remove the `current` fallback in both `wallpaper.sh` and `wallust_bridge.py`, and add that file to Modify.
    *   New order: `current_path.txt`, then the first file in the directory. Say that the intermediate step is removed on purpose.
    *   Manual step: `rm ~/.local/state/wallpaper/current`.
    *   Test: `restore ignores stale current copy`.

### [F9] A8: Full scope of R2: Major
*   **Scope:** lines 29, 61-82, 194, 204-207, 223
*   **Description:** wlogout makes the test fail. `appearance.nix` and `rofi-clipboard.sh` are not in the map. Round exceptions are not defined. (ZO-N3, DE-M3, IR-M7, CD-M8, SD-M8, CO-7, ZO8-7, IR-N6)
*   ***Proposed Edit:***
    *   R2 explicitly includes wlogout.
    *   Add the line "sin excepciones: dots, pills y close-button pasan a cuadrados".
    *   Add `appearance.nix` (label its test "guarda de regresión") and `rofi-clipboard.sh` (already compliant) to the map.

### [F10] A11: Explicit edit of `rofi-colors.rasi` and the override rule: Major
*   **Scope:** lines 32, 198, 209-210, 221-222
*   **Description:** No step edits the template. `selected` is orphaned. Moving grid rules to the global file would center drun. The "only size/layout" list contradicts the plan itself. (ZO8-8, DE-M4, IR-M8, IR-M10, CD-N7, SD-M7, DE-N2)
*   ***Proposed Edit:***
    *   Step 3 lists `background {{background}}e6`, `input-bg 0.12`, `selected-accent 0.20`, `border-col 0.35`, and **remove `selected`**.
    *   Only the selected state (`element selected …`) moves to `rofi.rasi`. Grid centering, `element-icon size` and `orientation` stay in `wallpaper.sh`'s `-theme-str`, without colors or borders.
    *   Rule: "los scripts nunca sobrescriben color, borde ni radio".
    *   Accepted literals: `e6` in RASI, `0.90` in CSS/Nix.

### [F11] A12: Monolito values in the document: Major
*   **Scope:** lines 11, 221
*   **Description:** Values only exist in the external canvas. (IR-M11, DE-M5, ST-M5, SY-M1/M2, CO-8)
*   ***Justification:*** The implementer subagent cannot open the private canvas, so the plan has to include the values.
*   ***Proposed Edit:*** `rofi.rasi`:
    *   `window { width: 520px; padding: 0; border: 1px; border-color: @border-col; border-radius: 0; }`
    *   `mainbox { spacing: 0; }`
    *   `inputbar { padding: 14px 16px; border: 0 0 1px 0; }`
    *   `listview { lines: 8; padding: 8px; spacing: 2px; }`
    *   `element { padding: 10px; border-radius: 0; }`
    *   `element selected { background-color: @selected-accent; border: 1px; border-color: @accent; }`
    *   The canvas becomes a visual reference only.

### [F12] A13: Cheatsheet: Major
*   **Scope:** lines 97, 228-256
*   **Description:** The "compact" test never runs the script. 80% vs 82%. Width is justified against the wrong row. Says "medida" for an estimate. Fonts are dropped. (IR-M14, CD-N4, CD-N6, IR-N2, SD-M5, SD-M6, SY-M7, IR-N7)
*   ***Proposed Edit:***
    *   Merge the two tests into one that runs the script.
    *   Use 82% in Task 0 too.
    *   Justify the width with the longest row: `hypr-cheatsheet.sh:19`, about 84 characters × about 8 px ≈ 680 px < 765 px.
    *   Say "Causa estimada" and give the Waybar height.
    *   Keep `prompt`/`entry` at 10.5pt.
    *   Add `nix flake check` to Step 4.

### [F13] A14: Task 2, rename instead of delete: Major
*   **Scope:** lines 73, 121, 141
*   **Description:** The fake `themes.json` label forces an `--exclude` and a Task 2→6 dependency. Deleting `default.nix:76-77` breaks the Nix syntax. (ZO-3, CO-13, CD-N2, SD-N2)
*   ***Proposed Edit:***
    *   Task 2 renames the label in `preview_panel.py:215` to `wallust.toml` and keeps `setup_mini_thunar`.
    *   Delete the whole `home.file.".config/themes.json"` block (`default.nix:76-79`).
    *   Remove the `--exclude`.

### [F14] A15: Final grep: Major
*   **Scope:** line 302
*   **Description:** The grep matches its own test file and `AGENTS.md:98`. The `matugen` exception contradicts itself. (CO-1, ZO-N5, ZO8-10, IR-M13, CD-M13, SD-M12)
*   ***Proposed Edit:*** `grep -rnE '…' --exclude-dir={.git,docs,tests} --exclude=AGENTS.md .`, with no exception.

### [F15] A16: Mandatory gate: `egm-design`: Major
*   **Scope:** lines 36, 82
*   **Description:** Nothing enforces running the style test. (DE-M7)
*   ***Proposed Edit:*** Add `bash tests/run.sh` to Global Constraints and to AGENTS.md §5 (Task 2).

### [F16] A17: Problem, non-goals, measurable requirements: `egm-style`, `egm-structural`, `egm-design`: Major
*   **Scope:** lines 5, 15-23
*   **Description:** R3, R4 and R5 cannot be measured. There is no problem statement or non-goals. (SY-M1/M3/M4, ST-M2/M3/M4, DE-N1, DE-M6)
*   ***Proposed Edit:***
    *   `## Problema` (2 lines): two color paths that race each other; visually inconsistent surfaces; the help window overflows the screen; changing wallpaper has no transition.
    *   R4 = "fade 0.6 s / 30 fps, un `wallust` por cambio, `--restore` sin wallust, daemon bajo demanda".
    *   R5 = "ventana fija 56%×82% del monitor".
    *   R3 = according to E1.
    *   `## No objetivos`: sizing for chinatsu, a lock shared with Wallust Studio, a token engine, typography.
    *   Add a data-flow line to Architecture.

### [F17] A18: Task 3 diagnosis: Major
*   **Scope:** lines 156-160
*   **Description:** The diagnosis is obsolete after Task 2, uses the wrong line number (81 should be 78), and makes unmeasured claims. (ZO8-6, CO-5, CD-N1, CD-N3, SD-M2, SD-M3)
*   ***Proposed Edit:*** Replace it with "reproducir dos `--set` seguidos antes del cambio y anotar `pgrep -c wallust` y si hay fotograma negro (registro antes/después)".

### [F18] A20: Rule attributed to AGENTS.md: `egm-style`: Major
*   **Scope:** line 34
*   **Description:** AGENTS.md does not contain the `nix shell .#…pkgs` rule. (SY-M5)
*   ***Proposed Edit:*** "Regla de este plan (compatible con AGENTS.md §3.2): …".

### [F19] A21: Review Focus: `egm-style`: Major
*   **Scope:** lines 40-44
*   **Description:** "acentos" has no test. #1 claims more than it covers. #5 does not prove the window fits. (SY-M6, SY-M7, DE-M2, ZO-N6)
*   ***Proposed Edit:***
    *   Add a test with `fondo ñandú.jpg`.
    *   #1: "dos `wallpaper.sh --set` concurrentes".
    *   #5: "no cambia de tamaño al filtrar; tamaño relativo ≤ 82% del alto".

### [F20] A22: Complete test bodies: `egm-comprehension`: Major
*   **Scope:** lines 169-176, 209-211
*   **Description:** Test bodies use `…`. `**` requires globstar. (CO-4, CO-20, SD-M11)
*   ***Proposed Edit:*** Write each test body out in full, with no ellipses. Replace `**` with `find … -name '*.py' -exec python3 -c 'import ast,sys;ast.parse(open(sys.argv[1]).read())' {} \;`.

### [F21] A23 + A24: Canvas and wording: Nit
*   **Scope:** lines 3, 7, 19, 112, 143, 156, 225, 84
*   **Description:** The canvas step is outside the repo, plus several wording problems. (ZO-N4, ST-N4, SY-N4, SD-N1/N3/N6, CO-2, CO-9-11, DE-N4, SY-N20)
*   ***Justification:*** Cheap, and it helps a human reader.
*   ***Proposed Edit:***
    *   Move the canvas step to `## Seguimiento fuera del plan`.
    *   Replace "asserta" with "comprueba", and "mismo fondo" with "misma opacidad".
    *   Rewrite the "dispatch exit" parenthetical.
    *   Add one-line definitions:
        *   `theme-sync.sh`: reloads Waybar/SwayNC/Kitty/GTK and the Papirus folders.
        *   `awww`: Wayland wallpaper daemon with transitions.
        *   A8-7650K/Kaveri: source is `lscpu` and `hyprctl monitors`, 2026-11-11.
        *   Studio profile: sha256 of the image contents.
    *   Correct the `cleanSourceWith` reason.

---

## CONTEST

### [C1] IC-1 `tokens.nix` + generated `tokens.json`: `egm-inventive-catalyst`: Major
*   ***Justification:*** AGENTS.md §2: "Do not add additional engines". The plan's own Architecture section (line 7) rejects it. Substituting tokens with Nix adds a rebuild to every style tweak. The duplication it targets is already closed by F6 and F10 (negative tests).

### [C2] IC-3 coalescing queue: `egm-inventive-catalyst`: Nit
*   ***Justification:*** Line 154 fixes the contract "misma CLI que hoy". With coalescing, exit code 0 would no longer mean "applied". Selecting from Rofi produces one call per selection (`wallpaper.sh:204-210`). `flock -w 15` plus F3's `notify-send` is enough.

### [C3] DE-M2 lock shared with Wallust Studio: `egm-design`: Major
*   ***Justification:*** Studio writes through `wallust cs` in `wallust_bridge.py:20-24`. With a single user, the chance of applying in Studio and selecting in Rofi in the same second is negligible. It is moved to Non-goals (F16), and Review Focus 1 is narrowed (F19).

### [C4] DE-M4 full token→variable table: `egm-design`: Major
*   ***Justification:*** F10 lists exactly which template variables change. A table per target would repeat what the tests already check.

### [C5] DE-N3 extended font token: `egm-design`: Nit
*   ***Justification:*** The user's request (R2) asks for "cuadrado, colores y transparencia", not typography. It goes to Non-goals.

### [C6] DE-M7 (part) bats inside `nix flake check`: `egm-design`: Major
*   ***Justification:*** It would need a derivation with a sandboxed `HOME` and stubs on the `PATH`. That is out of proportion for a dotfiles repository. F15 covers the gate through AGENTS.md §5.

## DECLINE

### [D1] Cosmetic structural/style nits (ST-N1…N7, SY-N1…N12 not covered by F21; ZO-N7): Nit
*   ***Justification:*** These concern heading language, bold metadata, line-number anchors and table columns. They do not change what gets built. This is a superpowers implementation plan, not a feature spec.
