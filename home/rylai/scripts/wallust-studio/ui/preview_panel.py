import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Adw, Gdk, Pango

class PreviewPanel(Gtk.Box):
    def __init__(self, *args, **kwargs):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, *args, **kwargs)
        self.set_margin_start(18)
        self.set_margin_end(18)
        self.set_margin_top(12)
        self.set_margin_bottom(12)
        self.set_hexpand(True)
        self.set_vexpand(True)

        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE)
        self.stack.set_hexpand(True)
        self.stack.set_vexpand(True)

        self.stack_switcher = Gtk.StackSwitcher(stack=self.stack)
        self.stack_switcher.set_halign(Gtk.Align.CENTER)
        self.stack_switcher.set_margin_bottom(14)

        self.append(self.stack_switcher)
        self.append(self.stack)

        self.setup_terminal_view()
        self.setup_desktop_view()
        self.setup_thunar_view()

    def setup_terminal_view(self):
        """Renderiza una ventana de terminal simulada con la cuadrícula de bloques ANSI (como la captura del usuario)"""
        frame = Gtk.Frame()
        frame.add_css_class("preview-term-window")
        frame.set_hexpand(True)
        frame.set_vexpand(True)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        vbox.set_margin_start(16)
        vbox.set_margin_end(16)
        vbox.set_margin_top(12)
        vbox.set_margin_bottom(16)

        # Header con botones de ventana
        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        for color_class in ["term-btn-close", "term-btn-min", "term-btn-max"]:
            dot = Gtk.Box()
            dot.set_size_request(12, 12)
            dot.add_css_class("term-title-btn")
            dot.add_css_class(color_class)
            header.append(dot)

        title = Gtk.Label(label="kitty — rylai@nixos:~")
        title.set_hexpand(True)
        title.add_css_class("term-window-title")
        header.append(title)
        vbox.append(header)

        # Separador sutil
        sep = Gtk.Separator(orientation=Gtk.Orientation.HORIZONTAL)
        sep.add_css_class("term-separator")
        vbox.append(sep)

        # Prompt simulado
        prompt_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        prompt_lbl = Gtk.Label(label="rylai@nixos ~ ❯ colors.sh", xalign=0)
        prompt_lbl.add_css_class("term-prompt-text")
        prompt_box.append(prompt_lbl)
        vbox.append(prompt_box)

        # Cuadrícula ANSI idéntica a la imagen del usuario
        grid = Gtk.Grid(column_spacing=6, row_spacing=4, margin_top=8, margin_bottom=8)
        grid.set_halign(Gtk.Align.CENTER)

        # Encabezados de columnas (def, 40m .. 47m)
        headers = ["def", "40m", "41m", "42m", "43m", "44m", "45m", "46m", "47m"]
        for c_idx, h_text in enumerate(headers):
            lbl = Gtk.Label(label=h_text)
            lbl.add_css_class("ansi-grid-header")
            grid.attach(lbl, c_idx + 1, 0, 1, 1)

        # Filas (g, 30m .. 37m, 1;30m .. 1;37m)
        row_labels = ["30m", "31m", "32m", "33m", "34m", "35m", "36m", "37m",
                      "1;30m", "1;31m", "1;32m", "1;33m", "1;34m", "1;35m", "1;36m", "1;37m"]

        for r_idx, r_text in enumerate(row_labels):
            lbl = Gtk.Label(label=r_text, xalign=1)
            lbl.add_css_class("ansi-grid-row-lbl")
            grid.attach(lbl, 0, r_idx + 1, 1, 1)

            for c_idx in range(len(headers)):
                block = Gtk.Label(label="gYw", xalign=0.5)
                block.set_size_request(34, 20)
                block.add_css_class("ansi-cell")
                block.add_css_class(f"cell-fg-{r_idx % 8}")
                block.add_css_class(f"cell-bg-{c_idx}")
                grid.attach(block, c_idx + 1, r_idx + 1, 1, 1)

        scrolled_grid = Gtk.ScrolledWindow()
        scrolled_grid.set_child(grid)
        scrolled_grid.set_vexpand(True)
        vbox.append(scrolled_grid)

        # Cursor prompt final
        cursor_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        c_prompt = Gtk.Label(label="rylai@nixos ~ ❯ ", xalign=0)
        c_prompt.add_css_class("term-prompt-text")
        c_block = Gtk.Box()
        c_block.set_size_request(8, 16)
        c_block.add_css_class("term-cursor")
        cursor_box.append(c_prompt)
        cursor_box.append(c_block)
        vbox.append(cursor_box)

        frame.set_child(vbox)
        self.stack.add_titled(frame, "terminal", "Terminal Kitty")

    def setup_desktop_view(self):
        """Renderiza una simulación del entorno Waybar + Ventana Hyprland"""
        wrapper = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        wrapper.set_hexpand(True)
        wrapper.set_vexpand(True)

        # Simulación Waybar
        waybar_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        waybar_box.add_css_class("mock-waybar")
        waybar_box.set_margin_top(4)

        # Workspaces
        ws_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        ws_box.add_css_class("mock-module")
        ws_box.add_css_class("mock-workspaces")
        for i, name in enumerate(["1", "2", "3", "4"]):
            lbl = Gtk.Label(label=name)
            lbl.add_css_class("mock-ws-btn")
            if i == 0:
                lbl.add_css_class("active")
            ws_box.append(lbl)
        waybar_box.append(ws_box)

        # Espaciador central
        spacer = Gtk.Box()
        spacer.set_hexpand(True)
        waybar_box.append(spacer)

        # Reloj central
        clock_lbl = Gtk.Label(label="Dom 10 Oct 12:45")
        clock_lbl.add_css_class("mock-module")
        clock_lbl.add_css_class("mock-clock")
        waybar_box.append(clock_lbl)

        # Espaciador derecho
        spacer2 = Gtk.Box()
        spacer2.set_hexpand(True)
        waybar_box.append(spacer2)

        # Módulos Hardware (CPU, RAM, Audio)
        hw_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        hw_box.add_css_class("mock-module")
        hw_box.add_css_class("mock-sysinfo")
        hw_lbl = Gtk.Label(label="󰍛 24%  󰕾 80%  󰁹 95%")
        hw_box.append(hw_lbl)
        waybar_box.append(hw_box)

        wrapper.append(waybar_box)

        # Simulación de ventana de Hyprland con borde activo
        hypr_win = Gtk.Frame()
        hypr_win.add_css_class("mock-hyprland-active-window")
        hypr_win.set_hexpand(True)
        hypr_win.set_vexpand(True)

        win_content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        win_content.set_margin_start(16)
        win_content.set_margin_end(16)
        win_content.set_margin_top(14)
        win_content.set_margin_bottom(14)

        win_title = Gtk.Label(label="Hyprland Active Window (Border & Shadow Preview)", xalign=0)
        win_title.add_css_class("mock-hypr-title")
        win_content.append(win_title)

        sample_card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        sample_card.add_css_class("mock-sample-card")
        c_title = Gtk.Label(label="Tema generado en tiempo real", xalign=0)
        c_title.add_css_class("mock-card-heading")
        c_desc = Gtk.Label(label="Los colores de Waybar, bordes y terminal se sincronizan automáticamente con Wallust.", xalign=0)
        c_desc.set_wrap(True)
        sample_card.append(c_title)
        sample_card.append(c_desc)
        win_content.append(sample_card)

        hypr_win.set_child(win_content)
        wrapper.append(hypr_win)

        self.stack.add_titled(wrapper, "desktop", "Desktop / Waybar")

    def setup_thunar_view(self):
        """Renderiza una simulación de Thunar/GTK con Sidebar y Carpetas coloreadas con el acento"""
        thunar_frame = Gtk.Frame()
        thunar_frame.add_css_class("mock-thunar-window")
        thunar_frame.set_hexpand(True)
        thunar_frame.set_vexpand(True)

        root_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        root_box.set_hexpand(True)
        root_box.set_vexpand(True)

        # Sidebar
        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        sidebar.add_css_class("mock-thunar-sidebar")
        sidebar.set_size_request(160, -1)
        sidebar.set_margin_top(8)
        sidebar.set_margin_start(8)
        sidebar.set_margin_end(8)

        places = ["󰋜  Home", "󰉍  Descargas", "󱂬  Documentos", "󰉏  Imágenes", "󰎈  Música"]
        for i, place in enumerate(places):
            item = Gtk.Label(label=place, xalign=0)
            item.add_css_class("mock-sidebar-item")
            if i == 0:
                item.add_css_class("selected")
            sidebar.append(item)
        root_box.append(sidebar)

        sep = Gtk.Separator(orientation=Gtk.Orientation.VERTICAL)
        root_box.append(sep)

        # File view
        file_view = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        file_view.set_hexpand(True)
        file_view.set_margin_start(16)
        file_view.set_margin_end(16)
        file_view.set_margin_top(12)

        # Barra de ruta
        path_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        path_bar.add_css_class("mock-pathbar")
        path_lbl = Gtk.Label(label="  /home/rylai  ", xalign=0)
        path_bar.append(path_lbl)
        file_view.append(path_bar)

        # Carpetas (grid simulado)
        folder_grid = Gtk.Grid(column_spacing=16, row_spacing=16, margin_top=8)
        folders = [
            ("📁 nixos-config", "Carpeta"),
            ("📁 Documents", "Carpeta"),
            ("📁 Pictures", "Carpeta"),
            ("📁 .config", "Carpeta oculta"),
            ("📄 wallpaper.sh", "Script Bash"),
            ("📄 flake.nix", "Nix Flake"),
        ]

        for idx, (fname, ftype) in enumerate(folders):
            card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
            card.add_css_class("mock-file-card")
            card.set_size_request(110, 70)
            icon_lbl = Gtk.Label(label=fname, xalign=0.5)
            icon_lbl.add_css_class("mock-folder-icon")
            type_lbl = Gtk.Label(label=ftype, xalign=0.5)
            type_lbl.add_css_class("mock-file-subtext")
            card.append(icon_lbl)
            card.append(type_lbl)
            folder_grid.attach(card, idx % 3, idx // 3, 1, 1)

        file_view.append(folder_grid)
        root_box.append(file_view)

        thunar_frame.set_child(root_box)
        self.stack.add_titled(thunar_frame, "thunar", "Thunar / GTK")

