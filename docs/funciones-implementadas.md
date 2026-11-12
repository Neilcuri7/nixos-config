# Documentación de Funciones Implementadas

Este documento describe la arquitectura, componentes y comportamiento de las funciones implementadas en el sistema de temas dinámicos, fondos de pantalla y estandarización visual.

---

## 1. Sistema de Fondos de Pantalla (`home/rylai/scripts/wallpaper.sh`)

El script `wallpaper.sh` gestiona la selección, aplicación y restauración de fondos de pantalla con soporte para animaciones y sincronización de color.

### Características Clave:
* **Motor `awww` con transición fluida**:
  - Aplica fondos de pantalla con una transición tipo `fade` de 2 segundos a 60 FPS (`--transition-type fade --transition-duration 2 --transition-fps 60`).
  - Lanza y administra bajo demanda el demonio `awww-daemon` si no se encuentra en ejecución, sin filtrar descriptores de archivo ni bloquear procesos secundarios.
* **Serialización de concurrencia**:
  - Emplea `flock` sobre `/run/user/$UID/wallpaper.lock` para evitar condiciones de carrera o ejecuciones duplicadas simultáneas.
* **Restauración limpia en el arranque**:
  - Parámetro `--restore`: restaura el último fondo configurado (`~/.local/state/wallpaper/current_path`) instantáneamente sin transiciones innecesarias ni llamadas redundantes al generador de paletas.
* **Caché y perfiles de Wallust Studio**:
  - Al cambiar de fondo, consulta si existe un perfil ajustado manualmente en `~/.local/state/wallust-studio/profiles/<sha256>.json`. Si existe, aplica dicha paleta directamente en lugar de recalcularla.

---

## 2. Motor de Temas y Wallust Studio

### Principio de Fuente Única de Verdad:
* Todos los colores del sistema se derivan del fondo de pantalla actual mediante **Wallust** o provienen de un perfil persistente generado en **Wallust Studio**.
* Se eliminaron selectores estáticos antiguos (`theme-switcher.sh`, `themes.json`) para garantizar cohesión en todas las aplicaciones.

### Wallust Studio (`home/rylai/scripts/wallust-studio/`):
Herramienta gráfica interactiva desarrollada en Python con GTK4 y Libadwaita para ajustar las paletas generadas:
* **Aplicación asíncrona**: la regeneración y aplicación de paletas se ejecuta en un hilo secundario sin congelar la interfaz de usuario.
* **Botón y atajo "Original"**: permite recuperar la paleta original pura calculada por Wallust (`Ctrl+Shift+R`) sin necesidad de reiniciar la aplicación.
* **Persistencia por Hash**: los ajustes se guardan asociados al hash SHA-256 de la imagen en `~/.local/state/wallust-studio/profiles/<hash>.json`.
* **Notificaciones integradas**: utiliza `Adw.ToastOverlay` para confirmar cambios aplicados o restauraciones.

---

## 3. Tokens de Estilo y Estandarización Visual

Se establece un lenguaje visual consistente en todo el entorno gráfico:

| Token | Valor | Ámbito de Aplicación |
|---|---|---|
| **Radio suave exterior** | `16px` | Rofi (`window`, `inputbar`), Waybar (grupos de módulos), Wallust Studio (`window`, `headerbar`), SwayNC (`.control-center`, `.notification`) |
| **Radio suave interior** | `8px` | Rofi (`element`), Waybar (botones de workspace), Wallust Studio (tarjetas, botones y swatches), SwayNC (widgets interiores, botones de acción) |
| **Radio plano** | `0` | Ventanas en mosaico Hyprland (`rounding = 0`), botones de `wlogout` |
| **Grosor de borde** | `2px` / `1px` | Ventanas de Hyprland `2px`; superficies superpuestas `1px` (Rofi, SwayNC, Wallust Studio, wlogout) |
| **Tinte de borde** | `rgba(color4, 0.35)` | Borde de Rofi, Wallust Studio, SwayNC |
| **Opacidad de superficies** | `0.90` / `0.80` | `0.90` en Rofi, Kitty, Waybar (`@surface`) y Wallust Studio; `0.80` en SwayNC (`@cc-bg`, `@noti-bg`) |
| **Tinte de entrada** | `rgba(color4, 0.12)` | Fondo de entrada en Rofi (`input-bg`) |
| **Tinte de selección** | `rgba(color4, 0.20)` | Elemento seleccionado en Rofi (`selected-accent`) |
| **Acento activo** | `color12` | Texto y borde de elementos activos |

---

## 4. Sincronización Automática (`home/rylai/scripts/theme-sync.sh`)

Punto central de orquestación que se dispara cada vez que se actualiza la paleta o fondo de pantalla:
* Recarga de estilos en **Waybar** y **SwayNC** (`swaync-client --reload-css`).
* Notificación de señal a **Kitty** (`kill -SIGUSR1`).
* Actualización de colores para **Rofi**, **Micro**, **Yazi**, **GTK 3/4**, y regeneración de iconos de carpetas temáticas.
