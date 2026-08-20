const hyprland = await Service.import("hyprland");

const JAPANESE_NUMBERS = {
  1: "一",
  2: "二",
  3: "三",
  4: "四",
  5: "五",
  6: "六",
  7: "七",
  8: "八",
  9: "九",
  10: "十",
};

// Mapeo de class / app_id / title de ventana a iconos Nerd Font
function getAppIcon(client) {
  const c = (client.class || client.initialClass || client.title || "").toLowerCase();
  
  if (c.includes("brave")) return "󰈹";
  if (c.includes("firefox")) return "󰈹";
  if (c.includes("chrome") || c.includes("chromium")) return "";
  if (c.includes("kitty") || c.includes("alacritty") || c.includes("foot") || c.includes("terminal") || c.includes("ghostty")) return "";
  if (c.includes("discord") || c.includes("vesktop") || c.includes("webcord")) return "󰙯";
  if (c.includes("spotify")) return "󰓇";
  if (c.includes("code") || c.includes("vsc")) return "󰨞";
  if (c.includes("thunar") || c.includes("nemo") || c.includes("dolphin") || c.includes("yazi")) return "󰉋";
  if (c.includes("steam")) return "󰓓";
  if (c.includes("obsidian")) return "󱞁";
  if (c.includes("telegram")) return "󰔁";
  
  return ""; // Icono por defecto para ventanas genericas
}

export const Workspaces = (monitor = 0) => {
  return Widget.Box({
    class_name: "workspaces",
    setup: (self) => {
      self.hook(hyprland, (box) => {
        const activeWsId = hyprland.active.workspace?.id || 1;
        const allClients = hyprland.clients || [];

        // Obtener IDs de workspaces que tienen al menos 1 cliente/ventana
        const occupiedWsIds = new Set(
          allClients.map((c) => c.workspace && c.workspace.id).filter(Boolean)
        );
        // Siempre incluir el workspace enfocado actualmente
        occupiedWsIds.add(activeWsId);

        // Ordenar numéricamente los workspaces activos
        const activeWorkspaces = Array.from(occupiedWsIds).sort((a, b) => a - b);

        box.children = activeWorkspaces.map((id) => {
          const label = JAPANESE_NUMBERS[id] || `${id}`;
          const wsClients = allClients.filter((c) => c.workspace && c.workspace.id === id);
          const icons = wsClients.map((c) => getAppIcon(c)).join(" ");
          const displayText = icons ? `${label} ${icons}` : label;
          const isFocused = activeWsId === id;

          return Widget.Button({
            on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
            child: Widget.Label(displayText),
            class_name: `workspace-button ${isFocused ? "focused" : ""}`,
          });
        });
      });
    },
  });
};

