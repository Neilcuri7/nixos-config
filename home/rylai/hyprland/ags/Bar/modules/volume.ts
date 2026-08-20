const audio = await Service.import("audio");

export const Volume = () => {
  // Widget de Salida de Audio (Altavoz / Audífonos)
  const speakerWidget = Widget.EventBox({
    on_scroll_up: () => {
      audio.speaker.volume = Math.min(1, audio.speaker.volume + 0.05);
    },
    on_scroll_down: () => {
      audio.speaker.volume = Math.max(0, audio.speaker.volume - 0.05);
    },
    child: Widget.Button({
      class_name: "volume-button speaker-button",
      on_clicked: () => (audio.speaker.is_muted = !audio.speaker.is_muted),
      tooltip_text: audio.speaker.bind("volume").as((v) => `Volumen: ${(v * 100).toFixed(0)}%`),
      child: Widget.Box({
        spacing: 4,
        children: [
          Widget.Label({
            label: Utils.watch("󰕾", audio.speaker, () => {
              if (audio.speaker.is_muted || audio.speaker.volume === 0) return "󰝟";
              if (audio.speaker.volume < 0.33) return "󰕿";
              if (audio.speaker.volume < 0.66) return "󰖀";
              return "󰕾";
            }),
            class_name: "volume-icon",
          }),
          Widget.Label({
            label: audio.speaker.bind("volume").as((v) => 
              audio.speaker.is_muted ? "Mute" : `${(v * 100).toFixed(0)}%`
            ),
            class_name: "volume-percent",
          }),
        ],
      }),
    }),
  });

  // Widget de Entrada de Audio (Micrófono)
  const micWidget = Widget.EventBox({
    on_scroll_up: () => {
      if (audio.microphone) audio.microphone.volume = Math.min(1, audio.microphone.volume + 0.05);
    },
    on_scroll_down: () => {
      if (audio.microphone) audio.microphone.volume = Math.max(0, audio.microphone.volume - 0.05);
    },
    child: Widget.Button({
      class_name: "volume-button mic-button",
      on_clicked: () => {
        if (audio.microphone) audio.microphone.is_muted = !audio.microphone.is_muted;
      },
      tooltip_text: Utils.watch("Micrófono", audio.microphone, () => 
        audio.microphone ? `Micrófono: ${(audio.microphone.volume * 100).toFixed(0)}%` : "Sin micrófono"
      ),
      child: Widget.Box({
        spacing: 4,
        children: [
          Widget.Label({
            label: Utils.watch("󰍬", audio.microphone, () => {
              if (!audio.microphone || audio.microphone.is_muted || audio.microphone.volume === 0) return "󰍭";
              return "󰍬";
            }),
            class_name: "mic-icon",
          }),
          Widget.Label({
            label: Utils.watch("--%", audio.microphone, () => {
              if (!audio.microphone) return "N/A";
              return audio.microphone.is_muted ? "Mute" : `${(audio.microphone.volume * 100).toFixed(0)}%`;
            }),
            class_name: "mic-percent",
          }),
        ],
      }),
    }),
  });

  return Widget.Box({
    class_name: "volume-box",
    spacing: 6,
    children: [speakerWidget, micWidget],
  });
};