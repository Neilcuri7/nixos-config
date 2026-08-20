const network = await Service.import("network");

export const NetworkIndicator = () => {
  return Widget.Box({
    class_name: "network",
    children: [
      Widget.Icon({
        icon: network.bind("connectivity").as((conn) => {
          if (conn === "full") {
            return network.primary === "wifi" 
              ? network.wifi.bind("icon_name") 
              : "network-wired-symbolic";
          }
          if (conn === "portal" || conn === "limited") {
            return "network-wireless-encrypted-symbolic";
          }
          return "network-offline-symbolic";
        }),
      }),
    ],
  });
};
