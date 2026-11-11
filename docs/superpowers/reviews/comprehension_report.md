# Stage 6: Comprehension Report

Target: `docs/superpowers/plans/2026-11-11-estandar-ui-wallpaper.md`. FeatureRange 1-85, DetailedRange 86-304.
Reviewer: egm-comprehension (completed). It read only the target document.

### What this proposes
The plan removes the fixed theme selector (`theme-switcher.sh`, `themes.json`, the Super+Shift+T binding). After that, Wallust generating colours from the current wallpaper is the only colour source. It sets one visual standard for Rofi, Waybar, SwayNC, Kitty and Wallust Studio: square corners, 0.90 surface opacity, and tints derived from `color4`/`color12`. The standard is written into `AGENTS.md` and enforced by grep-based bats tests rather than a template engine. It replaces `swaybg` with `awww` so wallpaper changes fade in about 0.6 s. Wallpaper changes run one at a time under `flock`, and a daemon is guaranteed at login. It resizes the Super+H cheatsheet so it fits a 1366×768 screen. It restyles Wallust Studio: square CSS, keyboard navigation of the 16-slot ANSI grid, a header, a toast, and a Rofi preview. The work is split into eight tasks (0-7), each starting with a failing test, and each task is assigned to a subagent.

### How the existing system works, per this document
Today colour comes from two places: a fixed-theme selector (`theme-switcher.sh` reading `themes.json`, opened with Super+Shift+T and labelled "Menú de temas") and Wallust run on the wallpaper. `wallpaper.sh` sets the wallpaper with `swaybg`, replacing the old process with `sleep 0.15` + `kill`. It writes `active_theme.txt` without an atomic write, copies the image to `$CURRENT_WALLPAPER`, and has no lock. At login, `autostart.nix` starts `wallpaper.sh --restore` and `theme-switcher.sh init` in parallel. Visual surfaces disagree: radii of 16/20/18 px, Rofi alpha `ee`, Kitty at 0.80, and Rofi scripts that override colours inline. The cheatsheet uses `width: 950px; lines: 17`, which is taller than the usable screen height. Wallust Studio is a Python GTK4/libadwaita app; its CSS is built in `css_manager._apply_palette_css`, and its preview panel includes a "mini Thunar" that reads `themes.json`.

Every section could be paraphrased, so there is no Blocker from the paraphrase check.

### Findings

| ID | Sev | Lines | Finding |
|---|---|---|---|
| CO-1 | 🟡 | 302 | The final grep names `matugen`, `desktop-tools.nix` and `converter-shell.nix`, but Task 3 never mentions removing `matugen-wallpaper`. |
| CO-2 | 🟡 | 141, 171 | The saved Wallust Studio profile (`profiles/<sha256>.json`) is never explained: what the hash is computed over, whether this branch already exists, and what the profile contains. |
| CO-3 | 🟡 | 107-112, 174-179 | Tests need stubs that the Task 1 harness does not provide: an `awww` stub that exits 1 only for `query`, a `wallust` stub with sleep and START/END markers, and a `theme-sync` stub that writes to the log. |
| CO-4 | 🟡 | 169-176, 209-211, 248 | Test bodies are elided with `…`. `cheatsheet rows are compact` reads `$STUB_LOG` without ever running the script. |
| CO-5 | 🟡 | 157 vs 59, 121 | The Task 3 diagnosis checks for the `theme-switcher init` race, but Task 2 has already removed it. |
| CO-6 | 🟡 | 183, 289 | Removing `cp -L $CURRENT_WALLPAPER` may break `wallust_bridge.get_current_wallpaper()`. The document does not say which source that function reads, and the state paths are not given. |
| CO-7 | 🟡 | 203-207 | The tests cover `rofi-clipboard.sh` and `appearance.nix`, but neither file is in the file map or the Modify lists. Line 9 says the Hyprland config is Lua, yet the test greps a `.nix` file. |
| CO-8 | 🟡 | 11, 21, 143, 221-222, 287 | Design references can only be reached through the external canvas: HUD, the Wallust Studio artboard, Monolito/Retícula, `t2`, and the 860 px move. |
| CO-9 | 🟢 | 35 | The document never says what `theme-sync.sh` reloads. |
| CO-10 | 🟢 | 157 | "A8" is not defined. |
| CO-11 | 🟢 | 7 | `awww` is not explained, nor why it needs a daemon. |
| CO-12 | 🟢 | 121, 141 | `AGENTS.md` §1/§2 are cited without quoting their current content. |
| CO-13 | 🟢 | 130-131, 141 | The `--exclude=preview_panel.py` exclusion is not in the Step 1 code. |
| CO-14 | 🟢 | 170 | `setup_sandbox` does not create `~/.local/state/theme/`. |
| CO-15 | 🟢 | 156 | "`hyprctl dispatch exit` no; …" is confusing. |
| CO-16 | 🟢 | 3, 50-57, 304 | The agents (`superpowers:*`, `engineering-agents:*`, "sesión principal") are not defined. |
| CO-17 | 🟢 | 279 | "Clean process" is not achievable with `unittest discover`, which runs every test in one process; a subprocess is needed. |
| CO-18 | 🟢 | 223 | `@surface`/`@outline` are not defined (their source template is not named). |
| CO-19 | 🟢 | 110, 113 | `jq` is not used. `tests/python/` is not created in Task 1. |
| CO-20 | 🟢 | 294 | `**/*.py` needs `shopt -s globstar`. |

Verdict: 0 Blockers, 8 Major, 12 Nits. FeatureRange is clear. The gaps are in DetailedRange.
