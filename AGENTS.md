# Reglas y Guía de Arquitectura para Agentes de IA

Este documento establece los estándares, la arquitectura del sistema y las reglas obligatorias que cualquier agente de IA (Antigravity, Claude Code, Cursor, OpenCode, etc.) **debe cumplir** al realizar modificaciones en este repositorio.

---

## 1. Estructura y Responsabilidad del Repositorio

El proyecto utiliza **NixOS Flakes** combinado con **Home Manager** de forma modular:

```
.
├── flake.nix                  # Punto de entrada. Define inputs, hosts mediante mkHost y outputs.
├── flake.lock                 # Versiones bloqueadas de dependencias de Nix.
├── .sops.yaml                 # Configuración declarativa de cifrado de secretos.
├── AGENTS.md                  # Este documento (Normas para Agentes de IA).
├── hosts/                     # Configuraciones específicas por máquina
│   ├── haimiya/               # Desktop principal (AMD GPU, almacenamiento /mnt/storage)
│   └── chinatsu/              # Laptop / máquina secundaria
├── modules/shared/            # Módulos del sistema NixOS compartidos
│   ├── core.nix               # Base común de todos los hosts (locale, firewall, docker, nix.gc, stylix base)
│   ├── applications/          # Toggles modulares para suites de software (myPlatform.applications.*)
│   ├── environment/           # Hyprland, display manager y sesión gráfica
│   ├── hardware/              # Pipewire, bluetooth y gestión de energía
│   └── services/              # sops-nix, input-remapper
├── home/rylai/                # Configuración de usuario (Home Manager)
│   ├── default.nix            # Definición principal del usuario, variables de sesión y MIME
│   ├── hyprland/              # Configuración de Hyprland (keybinds, autostart, apariencia, servicios)
│   ├── programs/              # Aplicaciones de usuario (kitty, yazi, micro, rofi, shell, starship, etc.)
│   ├── scripts/               # Scripts utilitarios (theme-switcher, wallpaper, theme-sync, etc.)
│   ├── theme/                 # ÚNICA FUENTE DE VERDAD de temas (Wallust, themes.json, plantillas)
│   └── waybar/                # Configuración y estilos CSS de Waybar
└── secrets/                   # Secretos cifrados con sops-nix
```

---

## 2. Reglas de Oro del Sistema de Temas

> [!IMPORTANT]
> **Single Source of Truth para Estilos y Colores:**
> El motor oficial y único de generación de temas es **Wallust**. No añadir motores adicionales (como Matugen) ni duplicar plantillas de colores en scripts.

1. **Plantillas de Color Únicas**:
   - Todas las plantillas de colores de aplicaciones residen en [`home/rylai/theme/wallust/templates/`](file:///home/rylai/Documents/nixos-proyect/mi-config/nixos-config/home/rylai/theme/wallust/templates/).
   - Si se añade soporte de color para una nueva aplicación (ej. una nueva terminal o lector), debe agregarse como plantilla en ese directorio y mapearse en [`wallust.toml`](file:///home/rylai/Documents/nixos-proyect/mi-config/nixos-config/home/rylai/theme/wallust/wallust.toml).
2. **Temas Fijos / Paletas Estáticas**:
   - Se declaran exclusivamente en [`home/rylai/theme/themes.json`](file:///home/rylai/Documents/nixos-proyect/mi-config/nixos-config/home/rylai/theme/themes.json) usando la especificación Base16/Base24.
   - `theme-switcher.sh` transforma automáticamente las paletas de `themes.json` al formato de `wallust cs` para renderizar **exactamente las mismas plantillas**.
3. **Recarga de Componentes Visuales**:
   - Cualquier script o herramienta que aplique un tema o wallpaper debe delegar la recarga y la actualización de iconos de carpetas a [`home/rylai/scripts/theme-sync.sh`](file:///home/rylai/Documents/nixos-proyect/mi-config/nixos-config/home/rylai/scripts/theme-sync.sh).

---

## 3. Reglas de Gestión de Paquetes y Módulos (NixOS vs Home Manager)

1. **No Duplicar Paquetes**:
   - Si un paquete se configura mediante Home Manager en `home/rylai/programs/<prog>.nix` (ej. `kitty`, `yazi`, `micro`, `rofi`, `waybar`, `git`), **está prohibido** agregarlo a `environment.systemPackages` en `modules/shared/`.
2. **Pureza de Flakes**:
   - Nunca utilizar canales impuros `import <nixpkgs> {}` ni `NIX_PATH`. Usar siempre los `inputs` declarados en `flake.nix` o derivaciones puras.
3. **Aislamiento de Entornos**:
   - Scripts con librerías complejas (como `wallust-studio` con PyGObject/GTK4) deben empaquetarse con wrappers aislados (`makeSearchPath`, `python3.withPackages`) en lugar de instalar librerías de desarrollo en el sistema global.
4. **Limpieza de Archivos Temporales y Caché**:
   - Los scripts copiados a Home Manager mediante `home.file` deben filtrarse con `lib.cleanSourceWith` para evitar que `__pycache__`, `.pyc` o temporales ingresen al Nix Store.

---

## 4. Estándares de Seguridad y Secretos

1. **Gestión de Secretos**:
   - Nunca incluir contraseñas, tokens de API o claves privadas en archivos `.nix` o `.sh`.
   - Utilizar siempre `sops-nix`. La clave pública Age para cifrar se encuentra en `.sops.yaml`.
2. **Red y Firewall**:
   - Mantener siempre `networking.firewall.enable = true;`. Las excepciones de puertos deben limitarse estrictamente a lo necesario o asignarse a interfaces de confianza como `tailscale0`.
3. **Decisiones de Diseño Conscientes (Riesgos Aceptados por el Usuario)**:
   - *Autologin*: SDDM está configurado con autologin para el usuario `rylai` por comodidad del usuario.
   - *Grupo Docker y Dispositivos*: El usuario pertenece a los grupos `docker`, `input`, `uinput` y `ydotool` para flujos de automatización de entrada y contenedores.
   - *Brave Dev*: El launcher `brave-dev` abre el puerto de depuración local 9222.
   *No modificar estos comportamientos a menos que el usuario lo solicite expresamente.*

---

## 5. Protocolo de Verificación Obligatorio para Agentes

Antes de finalizar cualquier tarea o entregar cambios al usuario, el agente debe ejecutar las siguientes comprobaciones:

1. **Chequeo de Sintaxis de Shell**:
   ```bash
   bash -n home/rylai/scripts/*.sh
   ```
2. **Evaluación Declarativa de NixOS**:
   ```bash
   nix flake check
   # o comprobar la evaluación completa de la máquina:
   nixos-rebuild dry-build --flake .#haimiya
   ```
3. **Verificación de Formato y Linter**:
   - Asegurarse de que no queden referencias a archivos o rutas borradas (como `matugen` o `desktop-tools.nix`).
