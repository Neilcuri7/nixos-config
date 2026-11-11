# Stage 7: Critic Report

Target: `docs/superpowers/plans/2026-11-11-estandar-ui-wallpaper.md`, FeatureRange lines 1-85
Reviewers: egm-design (completed, FAIL), egm-structural (completed, FAIL), egm-style (completed)
Standards: feature-spec-standard (design, structural)

## egm-design: 2 🔴, 7 🟡, 4 🟢

| ID | Sev | Lines | Finding | Recommendation |
|---|---|---|---|---|
| DE-B1 | 🔴 | 7, 19-23 | No alternatives considered. Not evaluated: keeping swaybg, using hyprpaper or mpvpaper, generating tokens from a Wallust template, or keeping themes.json as pinned palettes inside Wallust Studio profiles. | Add a section "Alternativas consideradas" with a concrete trade-off for each option. |
| DE-B2 | 🔴 | 25-44 | No risks and mitigations section. Missing: a daemon that crashes mid-session, the measured cost of the fade on Kaveri, whether the `awww` attribute exists in nixpkgs, and a rollback path. | Add "Riesgos y mitigaciones" covering daemon supervision, a fallback to swaybg, and a cited cost. |
| DE-M1 | 🟡 | 43, 73 | Removing `theme-switcher.sh init` drops the only colour regeneration at login. The login contract is not defined. No migration for an `active_theme.txt` whose value is `nord`. | Define what `--restore` does. Do a one-off migration: regenerate the colours and delete the file. Add a test for the legacy state in `restore`. |
| DE-M2 | 🟡 | 40 | Serialization has no named mechanism. Wallust Studio (`system_sync`) also writes the templates, and `wallpaper.sh`'s lock does not cover it. | Use one shared lock for every writer, and add a test for Studio and set running at the same time. |
| DE-M3 | 🟡 | 29-30, 61-82 | "radius 0 en todo" is ambiguous. Not addressed: `appearance.nix` is missing from the file map, wlogout, round shapes (close-button at 100%, term-dot, pills), and GTK apps through gtk-colors.css. | List every surface, the documented exceptions, and the grep scope. |
| DE-M4 | 🟡 | 32 | The tints do not match the existing variables: `input-bg` 0.14, `selected` 0.20, `selected-accent` 0.30 and `border-col` 0.35. Studio uses `color8`. | Add a table mapping each token to its variables, per target. |
| DE-M5 | 🟡 | 11, 21, 71, 80 | R3 cannot be reviewed because it depends on an external artifact. `slot_nav` only appears in the file map. The canvas edit cannot be verified. | Copy the concrete criteria into the document, and take the canvas out of scope. |
| DE-M6 | 🟡 | 5, 23, 27 | Sizes are tied to haimiya. `chinatsu` shares the same Home Manager config. R5 has no target numbers. | Use relative sizes, or add a non-goal. State the target dimensions. |
| DE-M7 | 🟡 | 7, 36, 65, 84 | The style test is not part of any mandatory gate. `tests/run.sh` is not wired into `nix flake check` or AGENTS.md §5. | Expose the tests as flake `checks`, or add them to §5. |
| DE-N1 | 🟢 | 5, 15-23 | Problem statement and non-goals are missing. | Add both sections. |
| DE-N2 | 🟢 | 31 | `e6` ≈ 0.902. The literals the grep should accept are not listed. | List the accepted literals for each format. |
| DE-N3 | 🟢 | 33 | The font token ignores 11.5 Bold, 10.5, Bold 12, and the Inter family used in Studio. | Extend the token. |
| DE-N4 | 🟢 | 27 | The hardware facts cite no source. | Cite `hyprctl monitors` or `hosts/haimiya`. |

## egm-structural: FAIL, 1 🔴, 5 🟡, 7 🟢

| ID | Sev | Lines | Finding |
|---|---|---|---|
| ST-B1 | 🔴 | all, 7 | No "Alternatives Considered" section (duplicates DE-B1). |
| ST-M1 | 🟡 | 25-44, 38-44 | No "Risks & Mitigations" section. Review Focus only points to tests and states no mitigation. Missing: shell injection through paths in `-theme-str`, the awww rename, the GPU limit not being enforced, and the breaking change for users of the fixed palettes. |
| ST-M2 | 🟡 | 5, 11, 15-23 | No problem statement. The goal is a list of actions. |
| ST-M3 | 🟡 | 5, 15-23, 31 | No goals versus non-goals. |
| ST-M4 | 🟡 | 7 | The architecture is a single paragraph with no data flow (selection → wallpaper.sh → awww → wallust → templates → theme-sync), and no explanation of the daemon at autostart or of the tokens in Studio. |
| ST-M5 | 🟡 | 11, 21 | R3 depends on the external canvas (duplicates DE-M5). |
| ST-N1 | 🟢 | 5-11 | The metadata block uses bold text instead of headings. |
| ST-N2 | 🟢 | 5-11, 25, 38 | Headings mix English and Spanish. |
| ST-N3 | 🟢 | 11 | Bare URL, and the link to "Requisitos" is not an anchor. |
| ST-N4 | 🟢 | 19 | "lienzo" is undefined as something that will be edited. |
| ST-N5 | 🟢 | 59 | Task 2 also touches `hypr-cheatsheet.sh`, which the shared-file statement does not mention. |
| ST-N6 | 🟢 | 63-82 | The "Responsabilidad" column mixes requirement IDs and descriptions. |
| ST-N7 | 🟢 | 73, 75, 81, 84 | Line-number anchors are fragile. The brace expansion inside the table is not a literal path. |

## egm-style: 0 🔴, 8 🟡, 12 🟢

| ID | Sev | Lines | Finding |
|---|---|---|---|
| SY-M1 | 🟡 | 5, 21 | "Mejorar" cannot be measured. List the concrete changes for R3. |
| SY-M2 | 🟡 | 11 vs 15-23 | Contradiction: the document says it is the spec, but R3 depends on a private URL. |
| SY-M3 | 🟡 | 22 | R4 says "Verificar" but does not state what is verified or the expected result. |
| SY-M4 | 🟡 | 23 | R5 has no measurable limit, and it is written as a problem rather than an action. |
| SY-M5 | 🟡 | 34 | Attributes the rule `nix shell .#…pkgs` to AGENTS.md, which does not contain it. Mark it as a plan rule. |
| SY-M6 | 🟡 | 42 | The text says "acentos", but there is no test for accents. "Debe aplicarse igual" is vague. |
| SY-M7 | 🟡 | 44 | A fixed `height` does not prove the window "no se sale de pantalla". |
| SY-M8 | 🟡 | 41 | "arrancar o esperar" is ambiguous. The test covers only one of the two. |
| SY-N1…N12 | 🟢 | 3, 9, 19-27, 28, 31, 33, 36, 40, 59, 52/74/79/81, 84 | Mixed languages. Versions not confirmed in Task 0. Too much bold. "Repo y lienzo". "Fuente única" overloads the AGENTS.md term. "etc.". Font sizes without `pt`. The verification is narrower than AGENTS.md §5. "Se esperan" is ambiguous. Redundant sentence. Undefined shorthand (`theme-str`, `gi`). The real reason `tests/` stays out of the store is the source root, not `cleanSourceWith`. |
