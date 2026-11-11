# Architecture Guide and Rules for AI Agents

This document establishes the standards, system architecture, and mandatory rules that any AI agent (Antigravity, Claude Code, Cursor, OpenCode, etc.) **must follow** when making modifications to this repository.

---

## 1. Repository Structure and Responsibilities

This project uses **NixOS Flakes** combined with **Home Manager** in a modular structure:

```
.
├── flake.nix                  # Entry point. Defines inputs, hosts via mkHost, and outputs.
├── flake.lock                 # Locked versions of Nix dependencies.
├── .sops.yaml                 # Declarative configuration for secrets encryption.
├── AGENTS.md                  # This document (Rules for AI Agents).
├── hosts/                     # Machine-specific configurations
│   ├── haimiya/               # Primary desktop (AMD GPU, /mnt/storage mount)
│   └── chinatsu/              # Laptop / secondary machine
├── modules/shared/            # Shared NixOS system modules
│   ├── core.nix               # Common base across all hosts (locale, firewall, docker, nix.gc, base stylix)
│   ├── applications/          # Modular toggles for software suites (myPlatform.applications.*)
│   ├── environment/           # Hyprland, display manager, and graphical session
│   ├── hardware/              # Pipewire, bluetooth, and power management
│   └── services/              # sops-nix, input-remapper
├── home/rylai/                # User configuration (Home Manager)
│   ├── default.nix            # Main user definition, session variables, and MIME associations
│   ├── hyprland/              # Hyprland configuration (keybinds, autostart, appearance, services)
│   ├── programs/              # User applications (kitty, yazi, micro, rofi, shell, starship, etc.)
│   ├── scripts/               # Utility scripts (wallpaper, theme-sync, converter, etc.)
│   ├── theme/                 # SINGLE SOURCE OF TRUTH for themes (Wallust, templates)
│   └── waybar/                # Waybar configuration and CSS styles
├── tests/                     # bats (shell/) and unittest (python/) suites run by tests/run.sh
└── secrets/                   # Secrets encrypted with sops-nix
```

---

## 2. Golden Rules of the Theme System

> [!IMPORTANT]
> **Single Source of Truth for Styles and Colors:**
> The official and sole theme generation engine is **Wallust**. Do not add additional engines (such as Matugen) or duplicate color templates across scripts.

1. **Single Color Templates**:
   - All application color templates reside in [`home/rylai/theme/wallust/templates/`](file:///home/rylai/Documents/nixos-proyect/mi-config/nixos-config/home/rylai/theme/wallust/templates/).
   - If color support is added for a new application (e.g., a new terminal or document reader), it must be added as a template in that directory and mapped in [`wallust.toml`](file:///home/rylai/Documents/nixos-proyect/mi-config/nixos-config/home/rylai/theme/wallust/wallust.toml).
2. **No fixed themes**:
   - The palette always comes from the current wallpaper through Wallust, or from a saved Wallust Studio profile for that image (`~/.local/state/wallust-studio/profiles/<sha256 of the image file>.json`).
3. **Reloading Visual Components**:
   - Any script or tool that applies a theme or wallpaper must delegate component reloading and folder icon updates to [`home/rylai/scripts/theme-sync.sh`](file:///home/rylai/Documents/nixos-proyect/mi-config/nixos-config/home/rylai/scripts/theme-sync.sh).
4. **Style tokens**:
   - Every surface uses these tokens; the guard is [`tests/shell/style-standard.bats`](file:///home/rylai/Documents/nixos-proyect/mi-config/nixos-config/tests/shell/style-standard.bats).

   | Token | Valor | Dónde |
   |---|---|---|
   | Radio | `0` | todo `border-radius` en RASI/CSS/Nix; Hyprland `rounding = 0` |
   | Borde | ventanas Hyprland `2px`; superficies superpuestas `1px` | `appearance.nix`; Rofi, SwayNC, wlogout, Wallust Studio |
   | Opacidad de superficie | `0.90` (en RASI `e6`) | fondo de Rofi, `kitty background_opacity`, `@surface` de Waybar, `cc-bg`/`noti-bg` de SwayNC, fondo de ventana de Wallust Studio |
   | Tinte de entrada | `color4` a `0.12` | `input-bg` de Rofi |
   | Tinte de selección | `color4` a `0.20` | `selected-accent` de Rofi |
   | Tinte de borde | `color4` a `0.35` | `border-col` de Rofi |
   | Acento | `color12` | texto y borde del elemento activo |

   - Nested SwayNC cards (`alpha(@noti-bg, 0.6/0.8)`) keep their extra transparency on purpose.

---

## 3. Package and Module Management Rules (NixOS vs Home Manager)

1. **No Package Duplication**:
   - If a package is configured via Home Manager in `home/rylai/programs/<prog>.nix` (e.g., `kitty`, `yazi`, `micro`, `rofi`, `waybar`, `git`), it is **strictly forbidden** to also add it to `environment.systemPackages` in `modules/shared/`.
2. **Flake Purity**:
   - Never use impure channels like `import <nixpkgs> {}`, `nix-shell -p`, or `NIX_PATH`. Always use the `inputs` declared in `flake.nix` or pure derivations.
3. **Environment Isolation**:
   - Scripts requiring complex libraries or FHS environments (such as `wallust-studio` with PyGObject/GTK4 or `converter` with `buildFHSEnv` for Docling) must be packaged with isolated declarative wrappers (`makeSearchPath`, `makeBinPath`, `python3.withPackages`, `buildFHSEnv`) instead of installing development libraries globally or calling `nix-build`/`nix-shell` at runtime.
4. **Temporary and Cache File Cleanup**:
   - Scripts copied into Home Manager via `home.file` must be filtered with `lib.cleanSourceWith` to prevent `__pycache__`, `.pyc`, or temporary files from entering the Nix Store.

---

## 4. Security and Secrets Standards

1. **Secrets Management**:
   - Never include passwords, API tokens, or private keys in `.nix` or `.sh` files.
   - Always use `sops-nix`. The public Age key used for encryption is located in `.sops.yaml`.
2. **Network and Firewall**:
   - Always keep `networking.firewall.enable = true;`. Port exceptions must be strictly limited to what is necessary or bound to trusted interfaces such as `tailscale0`.
3. **Conscious Design Decisions (User-Accepted Risks)**:
   - *Autologin*: SDDM is configured with autologin for user `rylai` for user convenience.
   - *Docker and Device Groups*: The user belongs to the `docker`, `input`, `uinput`, and `ydotool` groups for container workflows and input automation.
   - *Brave Dev*: The `brave-dev` launcher opens local debugging port 9222.
   *Do not modify these behaviors unless explicitly requested by the user.*

---

## 5. Mandatory Verification Protocol for Agents

Before completing any task or delivering changes to the user, the agent must run the following checks:

1. **Shell Syntax Check**:
   ```bash
   bash -n home/rylai/scripts/*.sh home/rylai/scripts/converter
   ```
2. **Declarative NixOS Evaluation**:
   ```bash
   nix flake check
   # or verify the full machine evaluation:
   nixos-rebuild dry-build --flake .#haimiya
   ```
3. **Formatting and Reference Verification**:
   - Ensure no references remain to deleted files or paths (such as `matugen`, `desktop-tools.nix`, or `converter-shell.nix`).
4. **Shell Test Suite**:
   ```bash
   bash tests/run.sh
   ```
