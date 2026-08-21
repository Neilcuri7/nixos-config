// ==============================================================================
// MÓDULO SWITCHER DE TEMAS PARA AGS
// ==============================================================================
// Utiliza el script ~/.config/scripts/theme-switcher.sh que lee ~/.config/themes.json
// ==============================================================================

const { execAsync } = Utils;

export const ThemeSwitcher = () => {
  const iconLabel = Widget.Label({
    label: "󰔎", // Icono minimalista Nerd Font
  });

  return Widget.Button({
    class_name: "theme-switcher",
    tooltip_text: "Cambiar Tema (Clic izquierdo: siguiente | Clic derecho: menú)",
    on_clicked: () => {
      // Clic izquierdo: Cambiar al siguiente tema
      execAsync(["bash", "-c", "$HOME/scripts/theme-switcher.sh next"])
        .catch((err) => console.error("Error al cambiar tema:", err));
    },
    on_secondary_click: () => {
      // Clic derecho: Abrir menú Rofi de temas
      execAsync(["bash", "-c", "$HOME/scripts/theme-switcher.sh menu"])
        .catch((err) => console.error("Error al abrir menú de temas:", err));
    },
    child: iconLabel,
  });
};
