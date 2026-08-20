import { Bar } from "./Bar/bar.ts";
import App from "resource:///com/github/Aylur/ags/app.js";

const hyprland = await Service.import("hyprland");

const getMonitors = () => {
  const mons = hyprland.monitors || [];
  return mons.length > 0 ? mons.map((m) => Bar(m.id)) : [Bar(0)];
};

App.config({
  style: App.configDir + "/style.css",
  windows: getMonitors(),
});


