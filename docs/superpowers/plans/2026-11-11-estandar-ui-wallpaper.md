# Estándar UI, Wallpaper animado y Wallust Studio — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Quitar el selector de temas fijos, unificar el aspecto de ventanas, Rofi y paneles (esquinas 0 px, mismos tintes, opacidad 0.90), animar el cambio de wallpaper con un fade, llevar Wallust Studio al mismo estándar y hacerlo más usable (sigue abierto al aplicar, avisos, botón "Original" con los colores base del wallpaper) y hacer que la ayuda `Super + H` quepa en 1366×768.

**Architecture:** Wallust, alimentado por el wallpaper (o por un perfil guardado de Wallust Studio), pasa a ser el único origen de color. Los valores visuales compartidos se escriben como literales en cada archivo y se vigilan con tests bats de grep, incluidos tests negativos que detectan cualquier valor distinto; no se añade un motor de plantillas. `swaybg` se sustituye por `awww`, un daemon de wallpapers para Wayland con transiciones animadas (antes se llamaba `swww`).

Flujo de color tras el cambio: selector Rofi o `wallpaper.sh --set <img>` → `ensure_daemon` → `awww img` (fade) → `wallust cs <perfil>` si existe un perfil de Studio para esa imagen, si no `wallust run <img>` → Wallust escribe las plantillas de `home/rylai/theme/wallust/templates/` en `~/.config` → `theme-sync.sh` recarga Waybar, SwayNC, Kitty, GTK y los colores de carpetas Papirus.

**Tech Stack:** NixOS flake + Home Manager, Hyprland 0.57 (configurado desde Nix con bloques Lua en línea), Rofi, Waybar, SwayNC, wlogout, Kitty, Wallust 3, `awww` 0.12.1 (versión de `pkgs.awww` en el flake, verificada el 2026-11-11), Python 3 + PyGObject (GTK4/libadwaita), bats 1.14.0 (de `pkgs` del flake).

**Spec:** este documento. Origen: petición del usuario del 2026-11-11, decisiones de la sección *Requisitos* y revisión EGM en `docs/superpowers/reviews/`. El lienzo de Claude Design (privado) es solo referencia visual: todos los valores que el implementador necesita están escritos aquí.

---

## Problema

Hoy hay dos caminos de color (temas fijos de `themes.json` y Wallust desde el wallpaper) y al iniciar sesión se ejecutan los dos a la vez. Las superficies usan radios de 0, 10, 12, 14, 16, 18 y 20 px y opacidades de 0.80 a 0.93. El cambio de wallpaper es un corte seco, y la ayuda `Super + H` mide unos 750 px de alto en un monitor de 768 px con una barra encima, así que se corta.

## Requisitos (decididos con el usuario)

| # | Requisito | Criterio medible |
|---|---|---|
| R1 | Eliminar el selector de temas fijos | No existen `theme-switcher.sh` ni `themes.json`, ni referencias a ellos en el repo (salvo `docs/`); el color sale siempre del wallpaper vía Wallust. |
| R2 | Estándar común para ventanas, Rofi, Waybar, SwayNC, wlogout, GTK, Kitty y Wallust Studio | Todo `border-radius` es 0, sin excepciones (los puntos, píldoras y el botón de cerrar de SwayNC pasan a cuadrados); opacidad de superficie 0.90; tintes de la tabla *Tokens*. |
| R3 | Wallust Studio con el mismo estándar y más usable (opción **(b)** elegida por el usuario) | **Estilo:** radio 0, sin `box-shadow`, fondo de ventana 0.90, celda activa con contorno de 1 px en lugar de borde de 2 px + sombra, botón "Aplicar al sistema" sin emoji. **Teclado:** mover el foco con las flechas selecciona el color. **Aplicar** (`Ctrl+S`/`Enter`) aplica, guarda el perfil, **no cierra** la ventana y muestra el aviso "Colores aplicados" (o "Error al aplicar" si `wallust` falla). **Cabecera:** título "Wallust Studio" con el nombre del wallpaper activo como subtítulo. **Restaurar** (`Ctrl+R`) vuelve a los **últimos colores aplicados** (al abrir, o tras el último Aplicar). **Original** (`Ctrl+Shift+R`, nuevo) carga en el editor los colores que Wallust genera del wallpaper **sin perfil guardado**, como la primera vez que se puso; es una vista previa que no toca el sistema hasta pulsar Aplicar. `Esc` y Cancelar cierran. Se conservan la matriz 8×2 `00–15` y la tarjeta HSL. |
| R4 | Cambio de wallpaper verificado y animado | `--set`: fade de 0.6 s a 30 fps, exactamente un `wallust` y un `theme-sync.sh` por cambio, dos `--set` concurrentes se ejecutan uno tras otro. `--restore`: sin transición y sin `wallust`. Ambos arrancan el daemon si no responde. |
| R5 | La ayuda `Super + H` cabe en pantalla | Ventana fija de 56 % × 82 % del monitor con lista desplazable; sin `width: 950px` ni `lines: 17`. |

## No objetivos

- Ajustar tamaños para el portátil `chinatsu`: los tamaños de Rofi son relativos al monitor, pero solo se verifican en `haimiya`.
- Un bloqueo compartido entre `wallpaper.sh` y Wallust Studio ("Aplicar" de Studio ejecuta `wallust cs` sin bloqueo; con un solo usuario la coincidencia en el mismo segundo es despreciable).
- Un motor de tokens (Nix o generador) y cambios de tipografía.
- Volver opacas o transparentes otras ventanas: las apps no listadas en R2 (Brave, Thunar…) mantienen su opacidad actual; solo cambian sus esquinas a través de `gtk-colors.css`.

## Alternativas consideradas

- **Mantener `swaybg`**: no tiene transiciones; el relevo actual (`sleep 0.15` + `kill`) puede mostrar un fotograma negro.
- **`hyprpaper`**: integrado en Hyprland, pero sin fade entre fondos.
- **`mpvpaper`**: transiciones posibles, pero arrastra una tubería de vídeo completa; demasiado para la Radeon R7.
- **`tokens.nix` sustituido por Nix en cada archivo**: una sola fuente de valores, pero es un segundo motor de plantillas (AGENTS.md §2 prohíbe motores adicionales) y cada ajuste de estilo exigiría reconstruir. Se elige literales + tests negativos.

## Riesgos y mitigaciones

1. **`awww` no existe en el nixpkgs fijado**: la Tarea 0 es una puerta. Si `nix eval .#nixosConfigurations.haimiya.pkgs.awww.version` falla, se mantiene `swaybg`, se omite la parte de transición de la Tarea 3 y se avisa al usuario.
2. **El daemon muere a mitad de sesión**: `ensure_daemon` se ejecuta en cada `--set` y `--restore`, así que el siguiente cambio lo vuelve a arrancar.
3. **Estado heredado de temas fijos** (`~/.local/state/theme/active_theme.txt` = `nord`): paso manual al final de la Tarea 3 que regenera colores desde el wallpaper y borra ese estado.
4. **Vuelta atrás**: `git revert` de los commits del plan o arrancar la generación anterior de NixOS.
5. **Inyección por la ruta del wallpaper**: no aplica a `-theme-str`, que tras la Tarea 4 es una cadena constante; la ruta se pasa siempre entre comillas como argumento.
6. **"Original" modifica el sistema sin querer** (si `wallust run` con la configuración aislada escribiera plantillas en `~/.config` o enviara secuencias de color a las terminales): la Tarea 0 lo comprueba con sumas de verificación antes de implementar. Si no se puede aislar, "Original" pasa a ser una acción explícita: un diálogo de confirmación, borrar el perfil de ese wallpaper y ejecutar `wallpaper.sh --set <wallpaper>`.
7. **"Original" tarda varios segundos en la A8** (análisis de una imagen 4K): se ejecuta en un hilo; el botón se desactiva y muestra "Generando…" hasta terminar.

## Global Constraints

- Hardware objetivo `haimiya` (datos de `lscpu` y `hyprctl monitors` del 2026-11-11): AMD A8-7650K con gráfica integrada Radeon R7 (Kaveri); monitor VGA-1 1366×768 @59.79 Hz. Sin blur ni sombras; transiciones ≤ 0.6 s y ≤ 30 fps.
- **Tokens** (se documentan en AGENTS.md §2 como valores canónicos):

  | Token | Valor | Dónde |
  |---|---|---|
  | Radio | `0` | todo `border-radius` en RASI/CSS/Nix; Hyprland `rounding = 0` |
  | Borde | ventanas Hyprland `2px`; superficies superpuestas `1px` | `appearance.nix`; Rofi, SwayNC, wlogout, Wallust Studio |
  | Opacidad de superficie | `0.90` (en RASI se escribe `e6`) | fondo de Rofi, `kitty background_opacity`, `@surface` de Waybar, `cc-bg`/`noti-bg` de SwayNC, fondo de ventana de Wallust Studio |
  | Tinte de entrada | `color4` a `0.12` | `input-bg` de Rofi |
  | Tinte de selección | `color4` a `0.20` | `selected-accent` de Rofi |
  | Tinte de borde | `color4` a `0.35` | `border-col` de Rofi |
  | Acento | `color12` | texto y borde del elemento activo |

  Las tarjetas anidadas de SwayNC (`alpha(@noti-bg, 0.6/0.8)`) conservan su transparencia adicional a propósito: son superficies dentro de una superficie.
- AGENTS.md: sin paquetes duplicados entre Home Manager y `environment.systemPackages`; sin `nix-shell -p` ni `<nixpkgs>`.
- Regla de este plan (compatible con AGENTS.md §3.2): las herramientas de test se toman del flake con `nix shell .#nixosConfigurations.haimiya.pkgs.<pkg>`.
- Toda plantilla de color sigue en `home/rylai/theme/wallust/templates/`; toda recarga visual pasa por `theme-sync.sh`.
- Verificación al final de cada tarea (AGENTS.md §5 más los tests): `bash -n home/rylai/scripts/*.sh home/rylai/scripts/converter`, `bash tests/run.sh` y `nix flake check`.

## Review Focus

1. **Dos `wallpaper.sh --set` concurrentes** (Enter dos veces en el selector): deben ejecutarse uno tras otro, sin dos `wallust` a la vez. → `serializes concurrent set calls` (Tarea 3).
2. **El daemon de `awww` no responde** al iniciar sesión o a mitad de sesión: `--restore` y `--set` lo arrancan; si no responde en 2 s, avisan y salen con 1. → `restore starts daemon when query fails`, `set starts daemon when query fails`, `daemon timeout notifies and fails` (Tarea 3).
3. **Ruta con espacios y acentos** (`fondo ñandú.jpg`): `awww img` y `wallust run` reciben la ruta exacta. → `set passes exact path with spaces and accents to wallust` (Tarea 3).
4. **Estado heredado `active_theme.txt = nord`**: `--set` regenera colores igualmente y no escribe ese archivo. → `set ignores legacy active_theme file` y `set writes only current_path` (Tarea 3).
5. **Ayuda `Super + H` al filtrar**: la ventana no cambia de tamaño (alto fijo relativo ≤ 82 %). → `cheatsheet window is relative, fixed and compact` (Tarea 5).
6. **"Original" con la configuración de Wallust del usuario**: debe usar los mismos ajustes de análisis (backend, palette, colorspace…) pero ninguna de sus plantillas, y no modificar `~/.config/wallust/wallust.toml`. → `test_base_palette_keeps_user_settings_without_templates` y `test_user_config_untouched` (Tarea 6).

## Asignación de subagentes

| Tarea | Ejecuta | Verifica |
|---|---|---|
| 0 Investigación | `engineering-agents:researcher` | — |
| 1 Arnés de tests | `engineering-agents:developer` | `engineering-agents:tester` |
| 2 Quitar selector de temas | `engineering-agents:developer` | `engineering-agents:reviewer` |
| 3 Wallpaper animado | `engineering-agents:developer` | `engineering-agents:tester` |
| 4 Estándar visual | `engineering-agents:developer` | `engineering-agents:reviewer` |
| 5 Ayuda Super+H | `engineering-agents:developer` | `engineering-agents:tester` |
| 6 Wallust Studio | `engineering-agents:developer` | `engineering-agents:tester` + `engineering-agents:reviewer` |
| 7 Verificación final | `engineering-agents:tester` | `engineering-agents:reviewer` (diff completo) |

`engineering-agents:*` son subagentes de Claude Code instalados en `~/.claude/skills/engineering-agents/`; la "sesión principal" es la conversación que orquesta el plan. Orden estricto 0 → 7, porque las Tareas 2, 3, 4 y 5 editan los mismos scripts (`wallpaper.sh`, `hypr-cheatsheet.sh`).

## Mapa de archivos

| Archivo | Acción | Requisito |
|---|---|---|
| `tests/run.sh` | Crear | todos (ejecuta bats desde el flake) |
| `tests/shell/helpers.bash`, `tests/shell/smoke.bats` | Crear | arnés |
| `tests/shell/no-theme-switcher.bats` | Crear | R1 |
| `tests/shell/wallpaper.bats` | Crear | R4 |
| `tests/shell/style-standard.bats` | Crear (Tarea 4), ampliar (Tarea 6) | R2, R3 |
| `tests/shell/cheatsheet.bats` | Crear | R5 |
| `home/rylai/scripts/theme-switcher.sh`, `home/rylai/theme/themes.json` | Borrar | R1 |
| `home/rylai/theme/default.nix` (bloque `home.file.".config/themes.json"`, 4 líneas) | Modificar | R1 |
| `home/rylai/hyprland/keybinds.nix` (bind `SUPER + SHIFT + T`) | Modificar | R1 |
| `home/rylai/hyprland/autostart.nix` (línea `theme-switcher.sh init`) | Modificar | R1 |
| `home/rylai/scripts/wallust-studio/ui/preview_panel.py` (etiqueta `themes.json` del mini Thunar) | Modificar | R1 |
| `AGENTS.md` (§1 árbol, §2 reglas 2 y 4, §5) | Modificar | R1, R2 |
| `home/rylai/scripts/wallpaper.sh` | Modificar | R4 (Tarea 3), R2 (Tarea 4) |
| `home/rylai/scripts/wallust-studio/wallust_bridge.py` (respaldo `current`) | Modificar | R4 |
| `modules/shared/environment/hyprland.nix` (`swaybg` en `systemPackages`) | Modificar | R4 |
| `home/rylai/programs/rofi.rasi`, `home/rylai/theme/wallust/templates/rofi-colors.rasi` | Modificar | R2 |
| `home/rylai/waybar/style.css`, `home/rylai/hyprland/services.nix` (CSS de wlogout y SwayNC), `home/rylai/theme/wallust/templates/swaync-colors.css`, `home/rylai/theme/wallust/templates/gtk-colors.css`, `home/rylai/programs/kitty.nix` | Modificar | R2 |
| `home/rylai/hyprland/appearance.nix`, `home/rylai/scripts/rofi-clipboard.sh` | Solo test de regresión (ya cumplen) | R2 |
| `home/rylai/scripts/hypr-cheatsheet.sh` | Modificar | R1 (Tarea 2), R5 (Tarea 5) |
| `home/rylai/scripts/wallust-studio/ui/css_manager.py`, `home/rylai/scripts/wallust-studio/ui/controls_panel.py`, `home/rylai/scripts/wallust-studio/ui/window.py` | Modificar | R3 |
| `home/rylai/scripts/wallust-studio/wallust_bridge.py` (`generate_base_palette`) | Modificar | R3 (también R4, Tarea 3) |
| `tests/python/test_wallust_bridge.py`, `tests/shell/studio.bats` | Crear | R3 |
| `tests/run.sh` (rama Python) | Modificar | R3 |

`tests/` queda fuera de `home/rylai/scripts`, que es lo único que `home/rylai/default.nix` copia al store con `lib.cleanSourceWith`, así que los tests nunca llegan al store.

---

### Task 0: Investigación de contratos externos

**Files:**
- Create: `docs/superpowers/plans/2026-11-11-estandar-ui-wallpaper-research.md`

**Interfaces:**
- Produces: confirmación o corrección de los flags y medidas que usan las Tareas 3, 5 y 6.

- [ ] **Step 1 (puerta):** `nix eval --raw .#nixosConfigurations.haimiya.pkgs.awww.version` → `0.12.1`. Si falla, aplicar el riesgo 1 y avisar al usuario antes de seguir.
- [ ] **Step 2:** Con `nix shell .#nixosConfigurations.haimiya.pkgs.awww -c awww img --help` confirmar `--transition-type fade|none`, `--transition-duration 0.6`, `--transition-fps 30`; confirmar que `awww query` sale ≠ 0 sin daemon y que el daemon se llama `awww-daemon`.
- [ ] **Step 3:** Con `man rofi-theme` confirmar que `window { height: 82%; }` + `listview { fixed-height: true; scrollbar: true; }` limita la lista al alto de la ventana y si hace falta fijar `lines`; si hace falta, calcular el valor para 768 px y escribirlo.
- [ ] **Step 4:** Medir el alto de Waybar con `hyprctl layers` y anotarlo.
- [ ] **Step 5:** Confirmar en la documentación de GTK4 que las flechas mueven el foco entre los `Gtk.Button` de un `Gtk.Grid` y que `Gtk.EventControllerFocus` emite `enter` al recibir el foco.
- [ ] **Step 6 (Wallust aislado, para "Original"):** con `nix shell .#nixosConfigurations.haimiya.pkgs.wallust -c wallust run --help` confirmar los flags de configuración (`-C <archivo>`), omitir secuencias de terminal (`-s`/`--skip-sequences`) y modo silencioso (`-q`); confirmar que la ruta `template` de `[templates]` se resuelve relativa al directorio del archivo pasado con `-C` y que `{{color0}}` se renderiza como `#rrggbb`. En la máquina real, anotar `sha256sum ~/.config/kitty/current-theme.conf ~/.config/waybar/*.css ~/.config/rofi/*.rasi`, ejecutar `wallust run <wallpaper> -C <tmp>/wallust.toml -s -q` con una configuración que solo tenga la plantilla JSON, y confirmar que las sumas no cambian. Si cambian, aplicar el riesgo 6 y reescribir la Tarea 6 en consecuencia.
- [ ] **Step 7:** Escribir los resultados en el archivo de investigación; si algún valor difiere, corregir las tareas afectadas de este plan antes de continuar.

### Task 1: Arnés de tests

**Files:**
- Create: `tests/run.sh`, `tests/shell/helpers.bash`, `tests/shell/smoke.bats`

**Interfaces:**
- Produces (en `helpers.bash`, cargado con `load helpers` en el `setup` de cada `.bats`):
  - `REPO`: ruta absoluta a la raíz del repo.
  - `setup_sandbox`: exporta `HOME=$BATS_TEST_TMPDIR/home`, `STUB_LOG=$BATS_TEST_TMPDIR/calls.log`, `XDG_RUNTIME_DIR=$BATS_TEST_TMPDIR`; crea `~/Pictures/wallpapers`, `~/.config/wallust/wallust.toml` (vacío), `~/.local/state/theme`, `~/.local/state/wallpaper` y `~/scripts/theme-sync.sh`, un stub ejecutable que añade `theme-sync $*` a `$STUB_LOG`; antepone `$BATS_TEST_TMPDIR/bin` a `PATH`.
  - `stub_script <cmd> <body>`: escribe `$BATS_TEST_TMPDIR/bin/<cmd>` con `#!/usr/bin/env bash` y `<body>`, y lo hace ejecutable.
  - `stub <cmd> [exit_code]`: `stub_script` con cuerpo `echo "<cmd> $*" >> "$STUB_LOG"; exit <exit_code|0>`.
  - `tests/run.sh`: `cd "$(dirname "$0")/.."` y `exec nix shell .#nixosConfigurations.haimiya.pkgs.bats -c bats tests/shell`.

- [ ] **Step 1: Test que falla** (`tests/shell/smoke.bats`)

```bash
setup() { load helpers; setup_sandbox; }
@test "stub records calls" {
  stub foo
  foo a b
  grep -qx "foo a b" "$STUB_LOG"
}
@test "stub_script runs custom body" {
  stub_script bar 'exit 7'
  run bar
  [ "$status" -eq 7 ]
}
@test "sandbox provides theme-sync stub" {
  "$HOME/scripts/theme-sync.sh" x
  grep -qx "theme-sync x" "$STUB_LOG"
}
```

- [ ] **Step 2:** `bash tests/run.sh` → FAIL (`helpers` no existe).
- [ ] **Step 3:** Crear `helpers.bash` y `run.sh` con las interfaces de arriba.
- [ ] **Step 4:** `bash tests/run.sh` → `3 tests, 0 failures`.
- [ ] **Step 5:** Commit `test: add bats harness`.

### Task 2: Eliminar el selector de temas (R1)

**Files:**
- Create: `tests/shell/no-theme-switcher.bats`
- Delete: `home/rylai/scripts/theme-switcher.sh`, `home/rylai/theme/themes.json`
- Modify: `home/rylai/theme/default.nix`, `home/rylai/hyprland/keybinds.nix`, `home/rylai/hyprland/autostart.nix`, `home/rylai/scripts/hypr-cheatsheet.sh`, `home/rylai/scripts/wallust-studio/ui/preview_panel.py`, `AGENTS.md`

**Interfaces:**
- Consumes: `REPO` (Tarea 1).

- [ ] **Step 1: Test que falla**

```bash
setup() { load helpers; }
@test "no references to the fixed theme selector remain" {
  run grep -rnE 'theme-switcher|themes\.json|Menú de temas' "$REPO" \
      --exclude-dir=.git --exclude-dir=docs --exclude-dir=tests
  [ "$status" -eq 1 ]
}
@test "theme files are gone" {
  [ ! -e "$REPO/home/rylai/scripts/theme-switcher.sh" ]
  [ ! -e "$REPO/home/rylai/theme/themes.json" ]
}
@test "AGENTS.md requires running the test suite" {
  grep -qF 'bash tests/run.sh' "$REPO/AGENTS.md"
}
```

- [ ] **Step 2:** `bash tests/run.sh` → FAIL en los tres tests.
- [ ] **Step 3: Implementar.**
  - Borrar los dos archivos.
  - `theme/default.nix`: borrar el bloque completo `home.file.".config/themes.json" = { source = ./themes.json; force = true; };` (4 líneas).
  - `keybinds.nix`: borrar el bind `SUPER + SHIFT + T` que ejecuta `theme-switcher.sh menu`.
  - `autostart.nix`: borrar `hl.exec_cmd(".../theme-switcher.sh init")`.
  - `hypr-cheatsheet.sh`: borrar la línea `Super + Shift + T : Menú de temas …`.
  - `preview_panel.py`: en `setup_mini_thunar`, cambiar la etiqueta `"themes.json"` por `"wallust.toml"` (el widget se conserva).
  - `AGENTS.md`: en §1 quitar `theme-switcher` y `themes.json` de los comentarios del árbol; sustituir §2 regla 2 ("Fixed Themes / Static Palettes") por "No fixed themes: the palette always comes from the current wallpaper through Wallust, or from a saved Wallust Studio profile for that image (`~/.local/state/wallust-studio/profiles/<sha256 of the image file>.json`)"; añadir `bash tests/run.sh` como paso 4 de §5.
- [ ] **Step 4:** `bash tests/run.sh` → PASS; `bash -n home/rylai/scripts/*.sh home/rylai/scripts/converter`; `nix flake check`.
- [ ] **Step 5:** Commit `refactor(theme)!: remove fixed theme selector, wallust-from-wallpaper only`.

### Task 3: Wallpaper animado y serializado (R4)

**Files:**
- Create: `tests/shell/wallpaper.bats`
- Modify: `home/rylai/scripts/wallpaper.sh`, `home/rylai/scripts/wallust-studio/wallust_bridge.py`, `modules/shared/environment/hyprland.nix`

**Interfaces:**
- Consumes: `setup_sandbox`, `stub`, `stub_script` (Tarea 1); flags confirmados en la Tarea 0.
- Produces: `wallpaper.sh --set <ruta>`, `--restore` y `--select` con la misma CLI que hoy. Wallust Studio no llama a `wallpaper.sh`: lee `~/.local/state/wallpaper/current_path.txt` con `wallust_bridge.get_current_wallpaper()`.

- [ ] **Step 1 (tester, registro previo):** En la máquina real, antes de tocar nada, ejecutar `wallpaper.sh --set <img1>; wallpaper.sh --set <img2>` seguidos y anotar en el archivo de investigación `pgrep -c wallust` durante el cambio y si aparece un fotograma negro. Sirve de comparación con el Step 7.
- [ ] **Step 2: Tests que fallan** (`tests/shell/wallpaper.bats`)

```bash
setup() {
  load helpers; setup_sandbox
  stub awww; stub awww-daemon; stub wallust; stub notify-send
  W="$HOME/Pictures/wallpapers"; : > "$W/a b.jpg"; : > "$W/fondo ñandú.jpg"
  S="$REPO/home/rylai/scripts/wallpaper.sh"
}
daemon_down_until_started() {
  stub_script awww "echo \"awww \$*\" >> '$STUB_LOG'; [ \"\$1\" = query ] && [ ! -e '$BATS_TEST_TMPDIR/up' ] && exit 1; exit 0"
  stub_script awww-daemon "echo awww-daemon >> '$STUB_LOG'; : > '$BATS_TEST_TMPDIR/up'"
}
@test "set uses awww fade transition" {
  run "$S" --set "$W/a b.jpg"
  [ "$status" -eq 0 ]
  grep -qF "awww img $W/a b.jpg --transition-type fade --transition-duration 0.6 --transition-fps 30" "$STUB_LOG"
}
@test "set passes exact path with spaces and accents to wallust" {
  run "$S" --set "$W/fondo ñandú.jpg"
  [ "$status" -eq 0 ]
  grep -qF "awww img $W/fondo ñandú.jpg" "$STUB_LOG"
  grep -qF "wallust run $W/fondo ñandú.jpg" "$STUB_LOG"
}
@test "set ignores legacy active_theme file" {
  printf nord > "$HOME/.local/state/theme/active_theme.txt"
  run "$S" --set "$W/a b.jpg"
  [ "$status" -eq 0 ]
  grep -q '^wallust run' "$STUB_LOG"
}
@test "set writes only current_path" {
  run "$S" --set "$W/a b.jpg"
  [ "$(cat "$HOME/.local/state/wallpaper/current_path.txt")" = "$W/a b.jpg" ]
  [ ! -e "$HOME/.local/state/wallpaper/current" ]
  [ ! -e "$HOME/.local/state/theme/active_theme.txt" ]
}
@test "set applies saved studio profile instead of wallust run" {
  h=$(sha256sum "$W/a b.jpg" | cut -d' ' -f1)
  mkdir -p "$HOME/.local/state/wallust-studio/profiles"
  echo '{}' > "$HOME/.local/state/wallust-studio/profiles/$h.json"
  run "$S" --set "$W/a b.jpg"
  grep -q '^wallust cs' "$STUB_LOG"
  ! grep -q '^wallust run' "$STUB_LOG"
}
@test "set on missing file fails without touching awww" {
  run "$S" --set /nope.jpg
  [ "$status" -eq 1 ]
  ! grep -q '^awww' "$STUB_LOG"
}
@test "theme-sync runs exactly once per set" {
  run "$S" --set "$W/a b.jpg"
  [ "$(grep -c '^theme-sync' "$STUB_LOG")" -eq 1 ]
}
@test "serializes concurrent set calls" {
  stub_script wallust "echo START >> '$STUB_LOG'; sleep 1; echo END >> '$STUB_LOG'"
  "$S" --set "$W/a b.jpg" & "$S" --set "$W/fondo ñandú.jpg" & wait
  [ "$(grep -E '^(START|END)$' "$STUB_LOG" | tr '\n' ,)" = "START,END,START,END," ]
}
@test "restore uses no transition and no wallust" {
  printf '%s' "$W/a b.jpg" > "$HOME/.local/state/wallpaper/current_path.txt"
  run "$S" --restore
  [ "$status" -eq 0 ]
  grep -qF -- "awww img $W/a b.jpg --transition-type none" "$STUB_LOG"
  ! grep -q '^wallust' "$STUB_LOG"
}
@test "restore ignores stale current copy" {
  : > "$HOME/.local/state/wallpaper/current"
  run "$S" --restore
  grep -qF "awww img $W/" "$STUB_LOG"
  ! grep -qF "awww img $HOME/.local/state/wallpaper/current" "$STUB_LOG"
}
@test "set starts daemon when query fails" {
  daemon_down_until_started
  run "$S" --set "$W/a b.jpg"
  [ "$status" -eq 0 ]
  [ "$(grep -c '^awww-daemon' "$STUB_LOG")" -eq 1 ]
  grep -q '^awww img' "$STUB_LOG"
}
@test "restore starts daemon when query fails" {
  daemon_down_until_started
  printf '%s' "$W/a b.jpg" > "$HOME/.local/state/wallpaper/current_path.txt"
  run "$S" --restore
  [ "$status" -eq 0 ]
  [ "$(grep -c '^awww-daemon' "$STUB_LOG")" -eq 1 ]
}
@test "daemon timeout notifies and fails" {
  stub awww 1
  run "$S" --set "$W/a b.jpg"
  [ "$status" -eq 1 ]
  grep -q '^notify-send' "$STUB_LOG"
  ! grep -q '^wallust' "$STUB_LOG"
}
@test "wallust_bridge has no stale current fallback" {
  ! grep -q '"current"' "$REPO/home/rylai/scripts/wallust-studio/wallust_bridge.py"
}
```

- [ ] **Step 3:** `bash tests/run.sh` → FAIL (`swaybg` en lugar de `awww`).
- [ ] **Step 4: Implementar** en `wallpaper.sh`:
  - Borrar `THEME_STATE_DIR`, `ACTIVE_THEME_FILE`, su `mkdir`, la variable `CURRENT_WALLPAPER`, la comprobación de `active_theme` (incluida la rama `matugen-wallpaper`) y la escritura de `active_theme.txt`. `--set` siempre aplica color.
  - `ensure_daemon()`: si `awww query` falla, `setsid -f awww-daemon >/dev/null 2>&1`; reintentar `awww query` cada 0.1 s hasta 2 s; si sigue fallando, `notify-send "Wallpapers" "awww-daemon no responde"` y `return 1`.
  - `set_wallpaper()`, en este orden: si el archivo no existe, aviso y `return 1` (sin llamar a `awww`); `exec 9>"${XDG_RUNTIME_DIR:-/tmp}/wallpaper.lock"; flock -w 15 9 || { notify-send "Wallpapers" "Otro cambio de fondo sigue en curso"; return 1; }`; `ensure_daemon || return 1`; escribir `current_path.txt` con tmp + `mv` (como hoy); `awww img "$full_path" --transition-type fade --transition-duration 0.6 --transition-fps 30`; perfil de Studio (`wallust cs`) o `wallust run` (lógica actual); `sync_env` una vez. Borrar `swaybg`, `pgrep`, `kill` y `cp -L`.
  - `restore_wallpaper()`: `ensure_daemon || return 1`; respaldo `current_path.txt` → primer archivo de `~/Pictures/wallpapers` (se elimina a propósito el respaldo intermedio `current`); `awww img "$wall" --transition-type none`.
  - `wallust_bridge.py`: borrar el respaldo a `state_dir / "current"` (líneas 13-15) y devolver `None` si no hay `current_path.txt`.
  - `modules/shared/environment/hyprland.nix`: `swaybg` → `awww`. No se añade ningún arranque del daemon en `autostart.nix`.
- [ ] **Step 5:** `bash tests/run.sh` → 14 PASS en `wallpaper.bats`; `bash -n …`; `nix flake check`.
- [ ] **Step 6 (manual, tras el `nixos-rebuild switch` que el usuario autorice):** migrar el estado heredado: `wallpaper.sh --set "$(cat ~/.local/state/wallpaper/current_path.txt)" && rm -rf ~/.local/state/theme ~/.local/state/wallpaper/current`.
- [ ] **Step 7 (tester, máquina real):** `wallpaper.sh --select`, elegir dos fondos seguidos: se ve el fade, `pgrep -c wallust` ≤ 1 durante el cambio, sin fotograma negro. Comparar con el Step 1. `pkill awww-daemon; wallpaper.sh --set <img>` vuelve a arrancar el daemon.
- [ ] **Step 8:** Commit `feat(wallpaper): awww fade transition, serialized sets, on-demand daemon`.

### Task 4: Estándar visual de ventanas, Rofi y paneles (R2)

**Files:**
- Create: `tests/shell/style-standard.bats`
- Modify: `home/rylai/programs/rofi.rasi`, `home/rylai/theme/wallust/templates/rofi-colors.rasi`, `home/rylai/scripts/wallpaper.sh` (`rofi_theme_str`), `home/rylai/waybar/style.css`, `home/rylai/hyprland/services.nix`, `home/rylai/theme/wallust/templates/swaync-colors.css`, `home/rylai/theme/wallust/templates/gtk-colors.css`, `home/rylai/programs/kitty.nix`, `AGENTS.md` (§2 regla 4)

**Interfaces:**
- Consumes: `REPO`.
- Produces: variables RASI `@background @input-bg @selected-accent @accent @border-col @text @placeholder` (se elimina `@selected`, que nadie usa). Los scripts Rofi pueden sobrescribir cualquier propiedad **salvo color, borde y radio**.

- [ ] **Step 1: Tests que fallan**

```bash
setup() { load helpers; cd "$REPO"; }
SH=(home/rylai/scripts/wallpaper.sh home/rylai/scripts/hypr-cheatsheet.sh home/rylai/scripts/rofi-clipboard.sh)
STYLE=(home/rylai/programs/rofi.rasi home/rylai/waybar/style.css home/rylai/hyprland/services.nix
       home/rylai/theme/wallust/templates/gtk-colors.css "${SH[@]}")
@test "no non-zero border-radius" {
  run grep -nP 'border-radius:\s*(?!0(px)?\s*;)' "${STYLE[@]}"
  [ "$status" -eq 1 ]
}
@test "regression guard: hyprland rounding stays 0" {
  grep -q 'rounding = 0;' home/rylai/hyprland/appearance.nix
}
@test "rofi template uses tokens" {
  f=home/rylai/theme/wallust/templates/rofi-colors.rasi
  grep -qE '^\s*background:\s*\{\{background\}\}e6;' "$f"
  grep -qE '^\s*input-bg:.*0\.12\);' "$f"
  grep -qE '^\s*selected-accent:.*0\.20\);' "$f"
  grep -qE '^\s*border-col:.*0\.35\);' "$f"
  ! grep -qE '^\s*selected:' "$f"
}
@test "kitty opacity is 0.90" {
  grep -qF 'background_opacity = "0.90"' home/rylai/programs/kitty.nix
}
@test "swaync surfaces are 0.90 and not re-alpha'd" {
  f=home/rylai/theme/wallust/templates/swaync-colors.css
  grep -qE '^@define-color cc-bg .*0\.90\);' "$f"
  grep -qE '^@define-color noti-bg .*0\.90\);' "$f"
  ! grep -qF 'alpha(@cc-bg' home/rylai/hyprland/services.nix
}
@test "waybar surface is 0.90 only" {
  grep -qF 'alpha(@surface, 0.90)' home/rylai/waybar/style.css
  ! grep -qP 'alpha\(@surface, (?!0\.90\))' home/rylai/waybar/style.css
}
@test "rofi scripts never override color, border or radius" {
  run grep -nE '(background-color|text-color|border(-color|-radius)?)\s*:' "${SH[@]}"
  [ "$status" -eq 1 ]
}
```

- [ ] **Step 2:** `bash tests/run.sh` → FAIL (radios de 10–20 px, alfa `ee`, Kitty `0.80`, `alpha(@cc-bg, 0.9)`, Waybar `0.85`, wlogout 16 px).
- [ ] **Step 3: Implementar.**
  - `rofi-colors.rasi`: `background: {{background}}e6;`, `input-bg` a `0.12`, `selected-accent` a `0.20`, `border-col` igual (`0.35`), borrar la línea `selected`.
  - `rofi.rasi` (variante "Monolito"): `window { width: 520px; padding: 0; border: 1px; border-color: @border-col; border-radius: 0; }`, `mainbox { spacing: 0; }`, `inputbar { padding: 14px 16px; border: 0 0 1px 0; border-color: @border-col; border-radius: 0; }`, `listview { lines: 8; padding: 8px; spacing: 2px; }`, `element { padding: 10px; border-radius: 0; }`, `element selected { background-color: @selected-accent; border: 1px; border-color: @accent; }`, `element selected element-text { text-color: @accent; }`.
  - `wallpaper.sh` (selector "Retícula"): el `rofi_theme_str` queda solo con disposición: `window { width: 64%; height: 70%; } listview { columns: 4; lines: 2; spacing: 8px; } element { orientation: vertical; padding: 8px; } element-icon { size: 140px; horizontal-align: 0.5; } element-text { horizontal-align: 0.5; }`. El estado seleccionado lo da `rofi.rasi`; el centrado de la cuadrícula se queda en el script porque solo aplica a este selector.
  - `waybar/style.css`: todos los `border-radius` a 0; `alpha(@surface, 0.85)` → `alpha(@surface, 0.90)`.
  - `services.nix`: todos los `border-radius` a 0 (wlogout incluido, y el `100%` del botón de cerrar de SwayNC); `.control-center { background: @cc-bg; }`.
  - `swaync-colors.css`: `cc-bg` 0.88 → 0.90, `noti-bg` 0.92 → 0.90. `gtk-colors.css`: `4px` → `0`. `kitty.nix`: `"0.80"` → `"0.90"`.
  - `AGENTS.md` §2: nueva regla 4 "Style tokens", que copia la tabla *Tokens* de este plan y cita `tests/shell/style-standard.bats` como guarda.
- [ ] **Step 4:** `bash tests/run.sh` → PASS; `bash -n …`; `nix flake check`.
- [ ] **Step 5 (tester, máquina real):** capturas con `grim` de Rofi drun, el selector de wallpaper, el portapapeles, SwayNC, wlogout y Waybar: esquinas rectas y misma opacidad 0.90.
- [ ] **Step 6:** Commit `style: unify radius 0 and 0.90 surface opacity across rofi, waybar, swaync, wlogout, kitty`.

### Task 5: Ayuda `Super + H` a la medida de la pantalla (R5)

**Files:**
- Create: `tests/shell/cheatsheet.bats`
- Modify: `home/rylai/scripts/hypr-cheatsheet.sh`

**Interfaces:**
- Consumes: `setup_sandbox`, `stub_script`; resultado de `lines` y alto de Waybar de la Tarea 0.

Causa estimada: el `-theme-str` actual fija `width: 950px` y `lines: 17`. Con filas de ~39 px (padding 8 + 8, spacing 6 de `rofi.rasi`), 17 filas más la entrada y el padding suman ~750 px, más que los 768 px del monitor menos la Waybar (alto medido en la Tarea 0).

- [ ] **Step 1: Test que falla**

```bash
setup() {
  load helpers; setup_sandbox
  stub_script rofi "cat >/dev/null; printf '%s\n' \"\$@\" >> '$STUB_LOG'"
}
@test "cheatsheet window is relative, fixed and compact" {
  run "$REPO/home/rylai/scripts/hypr-cheatsheet.sh"
  [ "$status" -eq 0 ]
  grep -qF 'window { width: 56%; height: 82%; }' "$STUB_LOG"
  grep -qF 'listview { fixed-height: true; scrollbar: true; }' "$STUB_LOG"
  grep -qF 'element { padding: 3px 10px; }' "$STUB_LOG"
  ! grep -qE 'width: 950px|lines: 17' "$STUB_LOG"
}
```

- [ ] **Step 2:** `bash tests/run.sh` → FAIL.
- [ ] **Step 3:** Sustituir el `-theme-str` por `window { width: 56%; height: 82%; } listview { fixed-height: true; scrollbar: true; } element { padding: 3px 10px; } element-text { font: "JetBrainsMono Nerd Font 10"; } prompt { font: "JetBrainsMono Nerd Font 10.5"; } entry { font: "JetBrainsMono Nerd Font 10.5"; }`, más `lines: N` en `listview` si la Tarea 0 lo exige. Ancho: 56 % de 1366 = 765 px; la fila más larga ("Anclar ventana flotante (Pin en todos los escritorios)" con su atajo, ~84 caracteres × ~8 px a 10 pt ≈ 680 px) cabe.
- [ ] **Step 4:** `bash tests/run.sh` → PASS; `bash -n …`; `nix flake check`.
- [ ] **Step 5 (tester, máquina real):** `Super + H` y captura con `grim`: la ventana no toca los bordes, se ven el prompt y la barra de desplazamiento, y escribir "capt" no cambia el tamaño.
- [ ] **Step 6:** Commit `fix(cheatsheet): size help window relative to the monitor`.

### Task 6: Wallust Studio con el estándar y más usable (R3, opción b)

**Files:**
- Create: `tests/python/test_wallust_bridge.py`, `tests/shell/studio.bats`
- Modify: `home/rylai/scripts/wallust-studio/wallust_bridge.py`, `home/rylai/scripts/wallust-studio/ui/css_manager.py`, `home/rylai/scripts/wallust-studio/ui/controls_panel.py`, `home/rylai/scripts/wallust-studio/ui/window.py`, `tests/shell/style-standard.bats`, `tests/run.sh`

**Interfaces:**
- Consumes (ya existen): `ColorPalette(**dict)` y `create_adjusted_copy()` (`color_engine.py`); `ControlsPanel._get_active_wallpaper()`, `_on_select_color_to_edit(btn, idx)`, `self.color_buttons`, `self.initial_palette`/`self.base_palette`/`self.current_palette`, `restore_defaults()`; `profile_manager.save_profile(path, data)`; `system_sync.apply_and_reload(data, accent_hex)`; acciones `win.apply`/`win.cancel`/`win.restore` de `window.py`.
- Produces:
  - `wallust_bridge.generate_base_palette(image_path: str, user_config: Path | None = None) -> dict[str, str]`: claves `background`, `foreground`, `cursor`, `color0`…`color15`, valores `#rrggbb`. `user_config` por defecto `~/.config/wallust/wallust.toml`. Lanza `subprocess.CalledProcessError` si `wallust` falla.
  - `ControlsPanel.load_wallpaper_original()`: lanza la generación en un hilo y carga el resultado en el editor.
  - `ControlsPanel.apply_to_system()`: ya no cierra la ventana.
  - `WallustStudioWindow.show_toast(text: str)`.
  - Acción `win.original` con atajo `<Ctrl><Shift>r`.

Semántica de los tres botones (las tres dejan los deslizadores globales en 0):

| Botón | Carga en el editor | Toca el sistema |
|---|---|---|
| Restaurar (`Ctrl+R`) | `initial_palette`: lo aplicado al abrir Studio o en el último Aplicar | No |
| Original (`Ctrl+Shift+R`) | `generate_base_palette(wallpaper activo)` | No (solo vista previa) |
| Aplicar (`Ctrl+S`, `Enter`) | — | Sí: guarda el perfil, ejecuta `wallust cs` + `theme-sync.sh`; luego `initial_palette` = `base_palette` = copia de lo aplicado |

- [ ] **Step 1: Tests que fallan**

  `tests/python/test_wallust_bridge.py` (`unittest.TestCase`; añade `home/rylai/scripts/wallust-studio` a `sys.path`). Cada test crea un directorio temporal con un `wallust` falso en `PATH`: un script bash que guarda sus argumentos y una copia del archivo pasado con `-C` en el directorio temporal, extrae `target = "…"` de esa configuración y escribe allí un JSON de 19 colores fijo (o sale con 1 en el test de error).

```python
FIXTURE = {"background": "#101010", "foreground": "#eeeeee", "cursor": "#eeeeee",
           **{f"color{i}": f"#0000{i:02x}" for i in range(16)}}
USER_TOML = 'backend = "fastresize"\npalette = "dark16"\n\n[templates]\nkitty = { template = "kitty-colors.conf", target = "~/.config/kitty/current-theme.conf" }\n'

def test_returns_palette_from_isolated_run(self):
    self.assertEqual(generate_base_palette(self.img, self.user_cfg), FIXTURE)

def test_runs_wallust_with_isolated_config_and_no_sequences(self):
    generate_base_palette(self.img, self.user_cfg)
    argv = self.read_argv()
    self.assertEqual(argv[:2], ["run", self.img])
    self.assertIn("-s", argv)
    cfg = argv[argv.index("-C") + 1]
    self.assertNotEqual(Path(cfg).resolve(), self.user_cfg.resolve())

def test_base_palette_keeps_user_settings_without_templates(self):
    generate_base_palette(self.img, self.user_cfg)
    used = self.read_used_config()
    self.assertIn('backend = "fastresize"', used)
    self.assertIn('palette = "dark16"', used)
    self.assertNotIn("kitty-colors.conf", used)

def test_user_config_untouched(self):
    generate_base_palette(self.img, self.user_cfg)
    self.assertEqual(self.user_cfg.read_text(), USER_TOML)

def test_wallust_failure_raises(self):
    self.make_fake_wallust(exit_code=1)
    with self.assertRaises(subprocess.CalledProcessError):
        generate_base_palette(self.img, self.user_cfg)
```

  `tests/shell/studio.bats` (guardas estáticas; el comportamiento se comprueba a mano en el Step 6):

```bash
setup() { load helpers; cd "$REPO/home/rylai/scripts/wallust-studio/ui"; }
@test "apply keeps the window open and toasts" {
  ! sed -n '/def apply_to_system/,/^    def /p' controls_panel.py | grep -q 'self.cancel()'
  grep -qF 'Colores aplicados' controls_panel.py
  grep -qF 'Adw.ToastOverlay' window.py
}
@test "original button and shortcut exist" {
  grep -qF '"Original"' controls_panel.py
  grep -qF 'load_wallpaper_original' controls_panel.py
  grep -qF '"<Ctrl><Shift>r"' window.py
}
@test "header shows the active wallpaper" {
  grep -qF 'Adw.WindowTitle' window.py
  grep -qF '_get_active_wallpaper' window.py
}
@test "apply button has no emoji and swatches select on focus" {
  ! grep -qF '🔄' controls_panel.py
  grep -qF 'Gtk.EventControllerFocus' controls_panel.py
}
```

  Añadir a `tests/shell/style-standard.bats`:

```bash
@test "studio css: no radius, no shadow, window at 0.90" {
  f=home/rylai/scripts/wallust-studio/ui/css_manager.py
  run grep -nP 'border-radius:\s*(?!0(px)?\s*;)' "$f"
  [ "$status" -eq 1 ]
  ! grep -q 'box-shadow' "$f"
  grep -A8 'window.background, .app-window' "$f" | grep -qF '_hex_to_rgba_css(c0, 0.90)'
}
```

- [ ] **Step 2:** `tests/run.sh` pasa a ejecutar también Python, sin escribir `__pycache__` en el repo: `PYTHONDONTWRITEBYTECODE=1 nix shell .#nixosConfigurations.haimiya.pkgs.bats .#nixosConfigurations.haimiya.pkgs.python3 -c sh -c 'bats tests/shell && python3 -m unittest discover -s tests/python -t tests/python'`. Ejecutar `bash tests/run.sh` → FAIL (`generate_base_palette` no existe; guardas de `studio.bats` y CSS fallan).
- [ ] **Step 3: Implementar `generate_base_palette`** en `wallust_bridge.py`: dentro de un `tempfile.TemporaryDirectory()` escribir `palette.json.tmpl` (un objeto JSON con las 19 claves, cada valor `"{{<clave>}}"`) y `wallust.toml` = las líneas de la configuración del usuario **hasta** la tabla `[templates]` (se descarta desde `[templates]` hasta la siguiente cabecera `[…]` o el final), más `[templates]\nstudio = { template = "palette.json.tmpl", target = "<tmp>/palette.json" }`; ejecutar `subprocess.run(["wallust", "run", image_path, "-C", cfg, "-s", "-q"], check=True)`; devolver `json.load` del destino. Sin dependencias nuevas (solo `json`, `tempfile`, `subprocess`, `pathlib`).
- [ ] **Step 4: Implementar la interfaz.**
  - `css_manager.py`: todos los `border-radius` a `0px` (incluidos los `9999px`); fondo de `window.background, .app-window` de `0.85` a `0.90`; borrar los dos `box-shadow`; la celda activa (`.selected-swatch`) pasa de `border: 2px solid …` + sombra a `outline: 1px solid <color12>`.
  - `controls_panel.py`:
    - Fila de botones (homogénea, 3 columnas): **Restaurar** (tooltip "Volver a los últimos colores aplicados"), **Original** (tooltip "Colores que Wallust genera del wallpaper, sin perfil guardado"), **Cancelar**; debajo, a todo el ancho, **Aplicar al sistema** (sin emoji).
    - En el bucle de los 16 botones, un `Gtk.EventControllerFocus` por botón cuyo `enter` llama a `self._on_select_color_to_edit(self.color_buttons[i], i)` (capturando `i` por valor).
    - `apply_to_system()`: guardar el perfil y `system_sync.apply_and_reload(...)` como hoy, dentro de `try`; si va bien, `initial_palette` y `base_palette` = `current_palette.create_adjusted_copy()`, deslizadores globales a 0 y `self.get_root().show_toast("Colores aplicados")`; si lanza una excepción, `show_toast("Error al aplicar: wallust falló")`. Borrar la llamada a `self.cancel()`.
    - `load_wallpaper_original()`: si `_get_active_wallpaper()` es `None`, `show_toast("No hay wallpaper activo")` y salir. Si no, desactivar el botón Original con la etiqueta "Generando…" y ejecutar `generate_base_palette` en un `threading.Thread(daemon=True)`; al terminar, con `GLib.idle_add`, poner `base_palette` = `current_palette` = `ColorPalette(**resultado)` (sin tocar `initial_palette`), deslizadores a 0, refrescar la matriz, la tarjeta HSL y la vista previa, y `show_toast("Colores originales cargados: pulsa Aplicar para guardarlos")`; si falla, `show_toast("No se pudieron generar los colores originales")`. En los dos casos, reactivar el botón con su etiqueta.
  - `window.py`: envolver el contenido en `Adw.ToolbarView`, con un `Adw.HeaderBar` arriba cuyo `title-widget` es `Adw.WindowTitle(title="Wallust Studio", subtitle=<basename del wallpaper o "sin wallpaper">)` (de `self.controls_panel._get_active_wallpaper()`), y el `split_view` dentro de un `Adw.ToastOverlay`. `show_toast(text)` hace `self.toast_overlay.add_toast(Adw.Toast.new(text))`. Nueva acción `win.original` → `controls_panel.load_wallpaper_original()` con atajo `<Ctrl><Shift>r`. Tamaño por defecto 880×500 sin cambios.
- [ ] **Step 5:** `bash tests/run.sh` → todo PASS; sintaxis Python sin `__pycache__`: `nix shell .#nixosConfigurations.haimiya.pkgs.python3 -c python3 -c 'import ast,sys; [ast.parse(open(f).read(), f) for f in sys.argv[1:]]' $(find home/rylai/scripts/wallust-studio -name '*.py')`; `nix flake check`.
- [ ] **Step 6 (tester, máquina real, tras el `nixos-rebuild switch` que el usuario autorice):**
  1. Abrir `wallust-studio`: la cabecera muestra el nombre del wallpaper; sin esquinas redondeadas ni sombras (captura con `grim`).
  2. Tab hasta la matriz y flechas: cada movimiento selecciona el color y actualiza la tarjeta HSL.
  3. Subir Saturación y `Ctrl+S`: Kitty y Waybar cambian, aparece "Colores aplicados" y la ventana sigue abierta.
  4. Bajar Brillo y `Ctrl+R`: el editor vuelve a lo aplicado en el paso 3 (no a lo de antes de abrir).
  5. Pulsar Original: el botón muestra "Generando…", la ventana responde mientras tanto, y luego el editor muestra la paleta original. `sha256sum ~/.config/kitty/current-theme.conf` no cambia hasta pulsar Aplicar.
  6. Aplicar tras Original, cerrar con `Esc`, ejecutar `wallpaper.sh --set <mismo wallpaper>`: se mantienen los colores originales (el perfil guardado ahora es el original).
- [ ] **Step 7:** Commit `feat(wallust-studio): flat style, stay open on apply, original-palette button, focus selects swatch`.

### Task 7: Verificación final

- [ ] **Step 1:** `bash tests/run.sh` → 0 fallos.
- [ ] **Step 2:** `bash -n home/rylai/scripts/*.sh home/rylai/scripts/converter` → sin salida.
- [ ] **Step 3:** `nix flake check` y `nixos-rebuild dry-build --flake .#haimiya` → sin errores.
- [ ] **Step 4:** `grep -rnE 'matugen|desktop-tools\.nix|converter-shell\.nix|swaybg|theme-switcher|themes\.json' --exclude-dir=.git --exclude-dir=docs --exclude-dir=tests --exclude=AGENTS.md .` → sin resultados (AGENTS.md §5 nombra esos archivos a propósito).
- [ ] **Step 5:** `engineering-agents:reviewer` audita `git diff main...HEAD` contra este plan y AGENTS.md.
- [ ] **Step 6:** Commit final si hubo correcciones; luego `superpowers:finishing-a-development-branch`.

---

## Seguimiento fuera del plan

- Sesión principal: en el lienzo de Claude Design, borrar los artboards `ThemeSwitcher` y `ThemeStrip` y la nota "Selector de temas", y subir las filas siguientes. No forma parte del diff del repo.
