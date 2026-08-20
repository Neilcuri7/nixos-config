let prevIdle = 0;
let prevTotal = 0;

export const SysStats = () => {
  const Ram = () => {
    const ram = Variable(
      { total: 0, used: 0 },
      {
        poll: [
          1000,
          [
            "bash",
            "-c",
            `cat /proc/meminfo | awk '/MemTotal/ {total=$2} /MemAvailable/ {available=$2} END {print total ":" available}'`,
          ],
          (x) => {
            let split = x.split(":");
            return {
              total: Number(split[0]),
              used: Number(split[0] - split[1]),
            };
          },
        ],
      }
    );

    return Widget.Box({
      tooltipText: ram
        .bind()
        .as(
          (x) =>
            `${(x.used / 1024 / 1024).toFixed(2)}GB / ${(
              x.total /
              1024 /
              1024
            ).toFixed(2)}GB (${((x.used / x.total) * 100).toFixed(2)}%)`
        ),
      class_name: "info-child ram-stat",
      children: [
        Widget.Label({ label: " " }),
        Widget.Label({
          label: ram
            .bind()
            .as((x) => `${(x.used / 1024 / 1024).toFixed(1)} GB`),
        }),
      ],
    });
  };

  const Cpu = () => {
    const cpu = Variable(0, {
      poll: [
        2000,
        [
          "bash",
          "-c",
          `cat /proc/stat | grep "^cpu "`,
        ],
        (line) => {
          const parts = line.trim().split(/\s+/).slice(1).map(Number);
          if (parts.length < 4) return 0;
          const idle = parts[3] + (parts[4] || 0); // idle + iowait
          const total = parts.reduce((acc, curr) => acc + curr, 0);

          if (prevTotal === 0) {
            prevIdle = idle;
            prevTotal = total;
            return 0;
          }

          const diffIdle = idle - prevIdle;
          const diffTotal = total - prevTotal;

          prevIdle = idle;
          prevTotal = total;

          if (diffTotal <= 0) return 0;
          const usage = Math.round(((diffTotal - diffIdle) / diffTotal) * 100);
          return Math.max(0, Math.min(100, usage));
        },
      ],
    });

    return Widget.Box({
      tooltipText: cpu.bind().as((x) => `${x}%`),
      class_name: "info-child cpu-stat",
      children: [
        Widget.Label({ label: "󰓅 " }),
        Widget.Label({
          label: cpu.bind().as((x) => `${x}%`),
        }),
      ],
    });
  };
  return Widget.Box({
    class_name: "info-bars sys-stats",
    spacing: 12,
    children: [Cpu(), Ram()],
  });
};
