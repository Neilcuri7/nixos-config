const mpris = await Service.import("mpris");

export const Media = () => {
  const playerData = Variable({
    busName: "",
    label: "",
    status: "",
  });

  const updatePlayer = () => {
    const players = mpris.players || [];
    const activePlayer = players.find((p) => p.play_back_status === "Playing") || players[0];
    if (activePlayer) {
      const artists = activePlayer.track_artists || [];
      const title = activePlayer.track_title || "";
      const label = artists.length > 0 ? `${artists.join(", ")} - ${title}` : title;
      const status = `${activePlayer.identity || ""} - ${activePlayer.play_back_status || ""}`;
      playerData.value = {
        busName: activePlayer.bus_name || "",
        label: label,
        status: status,
      };
    } else {
      playerData.value = { busName: "", label: "", status: "" };
    }
  };




  const currentPlayer = Variable(0);

  const cyclePlayers = () => {
    const players = mpris.players;

    if (currentPlayer.value == players.length - 1) {
      currentPlayer.setValue(0);
      const activePlayer = players[currentPlayer.value];
      const {
        track_artists,
        track_title,
        identity,
        play_back_status,
        bus_name,
      } = activePlayer;
      const label = `${track_artists.join(", ")} - ${track_title}`;
      const status = `${identity} - ${play_back_status}`;
      playerData.value = {
        busName: bus_name,
        label: label,
        status: status,
      };
    } else {
      currentPlayer.setValue(currentPlayer.value + 1);
      if (currentPlayer.value != players.length) {
        const activePlayer = players[currentPlayer.value];
        if (activePlayer != undefined) {
          const {
            track_artists,
            track_title,
            identity,
            play_back_status,
            bus_name,
          } = activePlayer;
          const label = `${track_artists.join(", ")} - ${track_title}`;
          const status = `${identity} - ${play_back_status}`;
          playerData.value = {
            busName: bus_name,
            label: label,
            status: status,
          };
        }
      }
    }
  };

  return Widget.Button({
    setup: (self) => {
      self.hook(mpris, () => {
        updatePlayer();
      });
      self.hook(playerData, () => {
        (self.tooltip_text = playerData.value.status.toString()),
          (self.on_primary_click = () =>
            mpris.getPlayer(playerData.value.busName)?.playPause()),
          (self.on_scroll_up = () =>
            mpris.getPlayer(playerData.value.busName)?.next()),
          (self.on_scroll_down = () =>
            mpris.getPlayer(playerData.value.busName)?.previous()),
          (self.visible =
            playerData.value.status != "" &&
            playerData.value.status != "Stopped"),
          (self.on_middle_click = cyclePlayers);
      });
    },
    class_name: "media",
    child: Widget.Label({
      justification: "left",
      truncate: "end",
      xalign: 0,
      maxWidthChars: 24,
      wrap: true,
      useMarkup: true,
      class_name: "media-label",
      setup: (self) =>
        self.hook(playerData, () => {
          self.label = playerData.value.label.toString();
        }),
    }),
  });
};
