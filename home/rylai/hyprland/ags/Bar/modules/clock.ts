import { revealerState } from "./revealer.ts";

const MONTHS = [
  "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
  "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
];

const DAYS_HEADER = ["Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sá"];

export const Clock = () => {
  const dateStr = Variable("", {
    poll: [1000, 'date "+%A %d %b, %I:%M %p"'],
  });

  const now = new Date();
  const currentYear = Variable(now.getFullYear());
  const currentMonth = Variable(now.getMonth());
  const viewMode = Variable("calendar");

  const isCalendarOpen = Variable(false);

  const CalendarWindow = (monitor = 0) =>
    Widget.Window({
      name: `calendar-window-${monitor}`,
      class_name: "calendar-window",
      monitor,
      layer: "top",
      anchor: ["top", "right"],
      visible: isCalendarOpen.bind(),
      child: Widget.Box({
        class_name: "calendar-window-box",
        children: [
          Widget.Box({
            vertical: true,
            class_name: "calendar-popup-container",
            children: [
              // Cabecera con navegación
              Widget.Box({
                class_name: "calendar-header",
                spacing: 8,
                children: [
                  Widget.Button({
                    class_name: "calendar-nav-btn",
                    child: Widget.Label("◄"),
                    on_clicked: () => {
                      if (viewMode.value === "calendar") {
                        if (currentMonth.value === 0) {
                          currentMonth.value = 11;
                          currentYear.value = currentYear.value - 1;
                        } else {
                          currentMonth.value = currentMonth.value - 1;
                        }
                      } else {
                        currentYear.value = currentYear.value - 1;
                      }
                    },
                  }),
                  Widget.Button({
                    class_name: "calendar-month-btn",
                    hexpand: true,
                    child: Widget.Label({
                      label: Utils.derive(
                        [currentMonth, currentYear, viewMode],
                        (mo, yr, mode) => {
                          if (mode === "calendar") {
                            return `${MONTHS[mo]} ${yr}`;
                          } else {
                            return `${yr}`;
                          }
                        }
                      ).bind(),
                    }),
                    on_clicked: () => {
                      viewMode.value = viewMode.value === "calendar" ? "months" : "calendar";
                    },
                  }),
                  Widget.Button({
                    class_name: "calendar-nav-btn",
                    child: Widget.Label("►"),
                    on_clicked: () => {
                      if (viewMode.value === "calendar") {
                        if (currentMonth.value === 11) {
                          currentMonth.value = 0;
                          currentYear.value = currentYear.value + 1;
                        } else {
                          currentMonth.value = currentMonth.value + 1;
                        }
                      } else {
                        currentYear.value = currentYear.value + 1;
                      }
                    },
                  }),
                ],
              }),
              // Vista de cuerpo: Días o Selector de Meses
              Widget.Stack({
                class_name: "calendar-body-stack",
                shown: viewMode.bind().as((m) => m),
                children: {
                  calendar: Widget.Box({
                    vertical: true,
                    spacing: 4,
                    children: [
                      // Cabecera de días de la semana
                      Widget.Box({
                        homogeneous: true,
                        spacing: 4,
                        class_name: "calendar-days-header",
                        children: DAYS_HEADER.map((day) =>
                          Widget.Label({
                            label: day,
                            class_name: "calendar-day-head",
                          })
                        ),
                      }),
                      // Rejilla de 6 semanas
                      Widget.Box({
                        vertical: true,
                        spacing: 4,
                        children: Utils.derive(
                          [currentMonth, currentYear],
                          (mo, yr) => {
                            const firstDay = new Date(yr, mo, 1).getDay();
                            const daysInMonth = new Date(yr, mo + 1, 0).getDate();
                            const today = new Date();

                            const weeks = [];
                            let dayCounter = 1 - firstDay;

                            for (let w = 0; w < 6; w++) {
                              const weekRow = [];
                              for (let d = 0; d < 7; d++) {
                                const dateNum = dayCounter;
                                const isCurrentMonth = dateNum >= 1 && dateNum <= daysInMonth;
                                const isToday =
                                  isCurrentMonth &&
                                  today.getDate() === dateNum &&
                                  today.getMonth() === mo &&
                                  today.getFullYear() === yr;

                                let cls = "calendar-day-cell";
                                if (!isCurrentMonth) cls += " other-month";
                                if (isToday) cls += " today";

                                weekRow.push(
                                  Widget.Label({
                                    label: isCurrentMonth ? `${dateNum}` : "",
                                    class_name: cls,
                                    width_request: 28,
                                    height_request: 24,
                                    xalign: 0.5,
                                    yalign: 0.5,
                                  })
                                );
                                dayCounter++;
                              }
                              weeks.push(
                                Widget.Box({
                                  homogeneous: true,
                                  spacing: 4,
                                  children: weekRow,
                                })
                              );
                            }
                            return weeks;
                          }
                        ).bind(),
                      }),
                    ],
                  }),
                  months: Widget.Box({
                    vertical: true,
                    spacing: 6,
                    children: Array.from({ length: 4 }).map((_, rowIndex) =>
                      Widget.Box({
                        homogeneous: true,
                        spacing: 6,
                        children: Array.from({ length: 3 }).map((_, colIndex) => {
                          const monthIdx = rowIndex * 3 + colIndex;
                          return Widget.Button({
                            class_name: "calendar-month-choice",
                            child: Widget.Label(MONTHS[monthIdx]),
                            on_clicked: () => {
                              currentMonth.value = monthIdx;
                              viewMode.value = "calendar";
                            },
                          });
                        }),
                      })
                    ),
                  }),
                },
              }),
            ],
          }),
        ],
      }),
    });

  // Instanciar la ventana del calendario en la app AGS
  App.addWindow(CalendarWindow());

  const clockBtn = Widget.Button({
    on_clicked: () => {
      isCalendarOpen.value = !isCalendarOpen.value;
    },
    setup: (self) =>
      self.hook(revealerState, () => {
        self.visible = !revealerState.value.state;
      }),
    class_name: "clock",
    child: Widget.Label({
      label: dateStr.bind().as((d) => ` ${d}`),
    }),
  });

  return clockBtn;
};
