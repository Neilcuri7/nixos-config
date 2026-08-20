const { execAsync } = Utils;

const themes = [
  { name: "Adwaita-dark", icon: "🌙", label: "Oscuro" },
  { name: "Adwaita", icon: "☀️", label: "Claro" },
  { name: "HighContrast", icon: "👁️", label: "Alto Contraste" },
];

let currentThemeIndex = 0;

export const ThemeSwitcher = () => {
  const iconLabel = Widget.Label({
    label: themes[currentThemeIndex].icon,
  });

  return Widget.Button({
    class_name: "theme-switcher",
    tooltip_text: themes[currentThemeIndex].label,
    on_clicked: (self) => {
      currentThemeIndex = (currentThemeIndex + 1) % themes.length;
      const theme = themes[currentThemeIndex];
      
      // Usamos hyprctl dispatch exec para ejecutar el cambio de tema de NixOS/Hyprland
      const colorScheme = theme.name === "Adwaita" ? "prefer-light" : "prefer-dark";
      
      execAsync([
        "hyprctl", "dispatch", "exec", 
        `gsettings set org.gnome.desktop.interface gtk-theme '${theme.name}' && gsettings set org.gnome.desktop.interface color-scheme '${colorScheme}'`
      ])
        .then(() => {
          iconLabel.label = theme.icon;
          self.tooltip_text = `Tema actual: ${theme.label}`;
        })
        .catch((err) => console.error("Error cambiando tema GTK:", err));
    },
    child: iconLabel,
  });
};
