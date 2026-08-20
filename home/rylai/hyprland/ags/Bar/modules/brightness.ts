import brightness from '../../Services/brightness.ts';

export const BrightnessSlider = () => {
  return Widget.EventBox({
    on_scroll_up: () => {
      brightness.screen_value = Math.min(1, brightness.screen_value + 0.05);
    },
    on_scroll_down: () => {
      brightness.screen_value = Math.max(0, brightness.screen_value - 0.05);
    },
    child: Widget.Button({
      class_name: "brightness-button",
      tooltip_text: brightness.bind("screen-value").as((v) => `Brillo: ${(v * 100).toFixed(0)}%`),
      child: Widget.Box({
        spacing: 4,
        children: [
          Widget.Label({
            label: brightness.bind("screen-value").as((v) => {
              if (v < 0.33) return "󰃞";
              if (v < 0.66) return "󰃟";
              return "󰃠";
            }),
            class_name: "brightness-icon",
          }),
          Widget.Label({
            label: brightness.bind("screen-value").as((v) => `${(v * 100).toFixed(0)}%`),
            class_name: "brightness-percent",
          }),
        ],
      }),
    }),
  });
};