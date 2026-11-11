# Research: external contracts (Task 0)

Date 2026-11-11. Evaluated against `.#nixosConfigurations.haimiya.pkgs` (rofi 2.0.0, wallust 3.5.2, awww 0.12.1).

## Step 1 - awww version gate
Command: `nix eval --raw .#nixosConfigurations.haimiya.pkgs.awww.version` -> `0.12.1`
Verdict: CONFIRMED.

## Step 2 - awww flags and daemon
Command: `nix shell .#nixosConfigurations.haimiya.pkgs.awww -c awww img --help`
- `-t, --transition-type`: possible values `none | simple | fade | left | right | top | bottom | wipe | wave | grow | center | any | outer | random`. `fade` and `none` both valid. Default `simple`. `none` is an alias of `simple` with step 255.
- `--transition-duration <secs>` default 3. Help note: "this doesn't work with the 'simple' transition" (so it works with `fade`; irrelevant for `none`).
- `--transition-fps` exists (accepts 30).
- Binaries in the package: `awww`, `awww-daemon`.
- `awww query` with no daemon: `Error: "Socket file '/run/user/1000/wayland-1-awww-daemon.sock' not found. ..."`, exit=1.
Verdict: CONFIRMED. Note: duration only has effect with `fade` (or other non-simple types). Socket is namespaced by WAYLAND_DISPLAY (`wayland-1-awww-daemon.sock`).

## Step 3 - rofi window height / listview
Command: `nix shell ...pkgs.rofi -c man rofi-theme`
- `listview`: `fixed-height` = "Always show `lines` rows, even if fewer elements are available"; `scrollbar` boolean; `lines` = number of rows; `dynamic` = resize when filtering.
- Man "Conflicting constraints": when window size is forced and listview expands to available space, "listview will not limit to the number of lines, but tries to fill the available space". So with `window { height: 82%; }` (listview expands by default) the list is bounded by the window height, not by `lines`; scrollbar shows when content exceeds it. Setting `lines` is not required for bounding.
- Current `home/rylai/programs/rofi.rasi` has `lines: 8; fixed-height: false; width: 600px; padding 16; border 2`, no window height.
- Estimate for 768 px (NOT measured empirically; rofi not launched): window 82% = ~630 px; minus border 4 + padding 32 = ~594; inputbar ~38 + mainbox spacing 12 -> listview ~544 px; element row ~42-44 px + 6 spacing = ~48-50 -> about 11 rows. If a fixed row count is wanted use `lines: 11` with `fixed-height: true`.
Verdict: CONFIRMED with caveat: `lines` need not be set; if set, 11 for 768 px (estimate, verify visually). Do not combine `fixed-height: true` with the existing `lines: 8` expecting 82% fill.

## Step 4 - Waybar height
Source used: `hyprctl layers` (usable here).
```
Monitor VGA-1:
  Layer level 0 (background): xywh: 0 0 1366 768 namespace: wallpaper
  Layer level 2 (top):        xywh: 12 6 1342 32 namespace: waybar
```
Monitor VGA-1 1366x768@59.79. Waybar: height 32 px at y=6 (config `margin-top: 6`, `margin-left/right: 12`, layer top). Occupies y 6..38.
Verdict: CONFIRMED: 32 px tall, 38 px from the top edge including margin.

## Step 5 - GTK4 focus
- `Gtk.EventControllerFocus::enter`: emitted when focus enters the widget or one of its descendants (https://docs.gtk.org/gtk4/signal.EventControllerFocus.enter.html). Caveat: may not fire when focus moves from a descendant to the widget itself; use `is-focus`/`contains-focus`. One controller per Gtk.Button is unaffected.
- Arrow-key movement: docs cover `Gtk.Widget.child_focus(direction)` with `Gtk.DirectionType` and `keynav-failed` (https://docs.gtk.org/gtk4/method.Widget.child_focus.html, https://docs.gtk.org/gtk4/vfunc.Widget.keynav_failed.html). The pages found do NOT explicitly state that arrows move focus between Gtk.Buttons in a Gtk.Grid. It is standard default GTK behaviour but not confirmed by a quoted official page.
Verdict: PARTIAL. `enter` CONFIRMED. Grid arrow navigation not doc-confirmed: verify empirically when the Studio UI is built, or add an explicit Gtk.EventControllerKey fallback. Not a blocker.

## Step 6 - wallust isolation (Original)
`wallust run --help` (3.5.2) confirms: `-C, --config-file <FILE>`, `-s, --skip-sequences`, `-q, --quiet`. Also: `-d, --config-dir` (mutually exclusive with `-C`), `--templates-dir <DIR>`, `-N/--no-config`, `-T`, `-n/--no-cache`, `--no-hooks`, `--print-scheme`.

Setup: T=/tmp/tmp.x20TZwnSef; HOME, XDG_CONFIG_HOME, XDG_CACHE_HOME, XDG_STATE_HOME under T; binary from `nix build` of `.#nixosConfigurations.haimiya.pkgs.wallust` (/nix/store/075qzd6n2g7h588jx7n31y78cy5nijhd-wallust-3.5.2/bin/wallust). Config = real wallust.toml up to `[templates]` (backend=resized, color_space=lch, palette=harddark16, check_contrast=true, fallback_generator=interpolate) + `studio = { template = ..., target = "$T/palette.json" }`. Template = one-line JSON with background, foreground, cursor, color0..15 each `"{{key}}"` plus dummy `"end":""`.

Command:
`env HOME=$T/home XDG_CONFIG_HOME=$T/cfg XDG_CACHE_HOME=$T/cache XDG_STATE_HOME=$T/state wallust run ~/Pictures/wallpapers/115783286_p0.jpg -C $T/c/wallust.toml -s -q`

- A (`template = "palette.json.tmpl"`, only `-C`): DIFFERS. Warning `studio: Reading $T/cfg/wallust/templates/palette.json.tmpl failed: No such file or directory`; exit 0, NO palette.json. Relative template path resolves against `$XDG_CONFIG_HOME/wallust/templates/`, NOT the directory of the `-C` file.
- B (`-C` + `-d`): error (mutually exclusive), exit 2.
- C (`-C` + `--templates-dir $T/c`, relative name): works.
- D (absolute `template` path): works. Output:
  `{"background":"#080C0E","foreground":"#AFB3B7","cursor":"#9AB29C","color0":"#353739","color1":"#495056","color2":"#74575D","color3":"#737E83","color4":"#90787E","color5":"#648461","color6":"#949CA4","color7":"#858B8F","color8":"#5D6164","color9":"#4F585F","color10":"#896169","color11":"#6B7C85","color12":"#A8838A","color13":"#85B082","color14":"#C5D0DB","color15":"#858B8F","end":""}`
  Values are `#RRGGBB` (uppercase hex): CONFIRMED.
- `find $T` (final): c/{palette.json.tmpl,wallust.toml}, cache/wallust/1w4orin_1.7/{Resized,Resized_Lch_auto,Resized_Lch_auto_HardDark16}, palette.json, and empty dirs cfg/, home/, state/. Nothing created in cfg/, home/, state/ (`-C` avoided creating a default config). (A first attempt also created cache/nix because `nix shell` ran under the isolated XDG_CACHE_HOME; I deleted it and re-ran with a pre-built binary.)
- Real config untouched: `sha256sum ~/.config/kitty/current-theme.conf ~/.config/waybar/*.css ~/.config/rofi/*.rasi` identical before/after (diff empty). Kitty hash `d1896ed0ed3a4ced7869217ef7bb4bce2cf796037aa5994de3a5214e4df48b40`. Risk 6 did not materialise.

Verdict: DIFFERS. Task 6 changes: (1) template path in the generated toml must be ABSOLUTE, or pass `--templates-dir <dir>`; never `-d` with `-C`. (2) Output is uppercase `#RRGGBB`. (3) wallust writes its palette cache to `$XDG_CACHE_HOME/wallust`; add `-n` (or isolate XDG_CACHE_HOME) so the real cache is not touched. (4) wallust exits 0 even when the template is missing, so check the target file exists after the run.

## Step 7
Plan tasks to amend: Task 6 (absolute template path / --templates-dir, existence check, cache isolation), Tasks 5/6 (grid arrow-key nav not doc-confirmed), Task 3 (rofi: window height bounds list; `lines` optional, ~11 for 768 px if set; Waybar 32 px / 38 px total).
