import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Adw, Pango

class PreviewPanel(Gtk.Box):
    def __init__(self, *args, **kwargs):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=10, *args, **kwargs)
        self.set_margin_start(8)
        self.set_margin_end(12)
        self.set_margin_top(12)
        self.set_margin_bottom(12)
        self.set_hexpand(True)
        self.set_vexpand(True)
        self.add_css_class("preview-canvas-card")

        # 1. Mini-Waybar
        self.setup_mini_waybar()

        # 2. Mini-Terminal (Kitty + Hyprland Border)
        self.setup_mini_terminal()

        # 3. Mini-Thunar / GTK4
        self.setup_mini_thunar()

    # ================= 1. MINI-WAYBAR =================
    def setup_mini_waybar(self):
        waybar_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        waybar_bar.add_css_class("waybar-window")

        # Izquierda: Workspaces + CPU
        left_island = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        left_island.add_css_class("waybar-island")

        ws1 = Gtk.Label(label="一")
        ws1.add_css_class("ws-btn")
        ws2 = Gtk.Label(label="●")
        ws2.add_css_class("ws-btn")
        ws2.add_css_class("active")
        ws3 = Gtk.Label(label="三")
        ws3.add_css_class("ws-btn")

        left_island.append(ws1)
        left_island.append(ws2)
        left_island.append(ws3)

        cpu_lbl = Gtk.Label(label=" 24%")
        cpu_lbl.add_css_class("waybar-mod")
        cpu_lbl.add_css_class("mod-stats")
        left_island.append(cpu_lbl)
        waybar_bar.append(left_island)

        # Separador expansible
        sp1 = Gtk.Box()
        sp1.set_hexpand(True)
        waybar_bar.append(sp1)

        # Centro: Reloj
        center_island = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        center_island.add_css_class("waybar-island")
        clock_lbl = Gtk.Label(label="11:48")
        clock_lbl.add_css_class("waybar-mod")
        clock_lbl.add_css_class("mod-clock")
        center_island.append(clock_lbl)
        waybar_bar.append(center_island)

        # Separador expansible
        sp2 = Gtk.Box()
        sp2.set_hexpand(True)
        waybar_bar.append(sp2)

        # Derecha: Audio, Red, Batería
        right_island = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        right_island.add_css_class("waybar-island")

        vol_lbl = Gtk.Label(label="󰕾 80%")
        vol_lbl.add_css_class("waybar-mod")
        vol_lbl.add_css_class("mod-controls")
        right_island.append(vol_lbl)

        net_lbl = Gtk.Label(label="󰤨")
        net_lbl.add_css_class("waybar-mod")
        net_lbl.add_css_class("mod-network")
        right_island.append(net_lbl)

        bat_lbl = Gtk.Label(label="󰂀 95%")
        bat_lbl.add_css_class("waybar-mod")
        bat_lbl.add_css_class("mod-battery")
        right_island.append(bat_lbl)

        waybar_bar.append(right_island)
        self.append(waybar_bar)

    # ================= 2. MINI-TERMINAL (KITTY) =================
    def setup_mini_terminal(self):
        term_frame = Gtk.Frame()
        term_frame.add_css_class("term-window-card")
        term_frame.set_hexpand(True)
        term_frame.set_vexpand(True)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)

        # Titlebar
        titlebar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        titlebar.add_css_class("term-titlebar")

        controls = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        for c in ["term-dot-red", "term-dot-yellow", "term-dot-green"]:
            dot = Gtk.Box()
            dot.add_css_class("term-dot")
            dot.add_css_class(c)
            controls.append(dot)
        titlebar.append(controls)

        title_lbl = Gtk.Label(label="kitty — rylai@nixos:~", xalign=0)
        title_lbl.add_css_class("term-title-text")
        title_lbl.set_hexpand(True)
        titlebar.append(title_lbl)

        self.border_badge = Gtk.Label(label="hypr: active", xalign=1)
        self.border_badge.add_css_class("section-badge")
        titlebar.append(self.border_badge)

        vbox.append(titlebar)

        # Body
        body = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        body.add_css_class("term-body")
        body.set_vexpand(True)

        # Prompt & Status
        prompt_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        lbl_usr = Gtk.Label(label="rylai@nixos")
        lbl_usr.add_css_class("term-user-host")
        lbl_dir = Gtk.Label(label="~")
        lbl_dir.add_css_class("term-dir")
        lbl_sym = Gtk.Label(label="❯")
        lbl_sym.add_css_class("term-symbol")
        lbl_cmd = Gtk.Label(label="wallust status")
        out_ok = Gtk.Label(label="✓ synced", xalign=0)
        out_ok.add_css_class("term-success")
        out_err = Gtk.Label(label="✖ 0 err", xalign=0)
        out_err.add_css_class("term-error")

        prompt_box.append(lbl_usr)
        prompt_box.append(lbl_dir)
        prompt_box.append(lbl_sym)
        prompt_box.append(lbl_cmd)
        prompt_box.append(out_ok)
        prompt_box.append(out_err)
        body.append(prompt_box)

        # Code Syntax Block
        syntax_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        syntax_box.add_css_class("code-syntax-box")
        self.code_lbl = Gtk.Label(xalign=0)
        self.code_lbl.set_use_markup(True)
        syntax_box.append(self.code_lbl)
        body.append(syntax_box)

        # 16-Color ANSI Test Grid (8x2 compacto)
        grid_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        grid = Gtk.Grid(column_spacing=4, row_spacing=4)
        grid.set_halign(Gtk.Align.FILL)

        for idx in range(16):
            cell = Gtk.Label(label=f"{idx:02d}")
            cell.set_hexpand(True)
            cell.add_css_class("ansi-block-cell")
            cell.add_css_class(f"ansi-color-{idx}")
            grid.attach(cell, idx % 8, idx // 8, 1, 1)

        grid_box.append(grid)
        body.append(grid_box)

        vbox.append(body)
        term_frame.set_child(vbox)
        self.append(term_frame)

    # ================= 3. MINI-THUNAR (GTK4) =================
    def setup_mini_thunar(self):
        thunar_frame = Gtk.Frame()
        thunar_frame.add_css_class("thunar-shell-card")
        thunar_frame.set_hexpand(True)

        split_body = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)

        # Sidebar
        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        sidebar.add_css_class("thunar-sidebar")
        sidebar.set_size_request(120, -1)

        item_home = Gtk.Label(label="󰋜 Personal", xalign=0)
        item_home.add_css_class("thunar-place-item")
        item_home.add_css_class("active")
        item_proj = Gtk.Label(label="󰉋 Proyectos", xalign=0)
        item_proj.add_css_class("thunar-place-item")

        sidebar.append(item_home)
        sidebar.append(item_proj)
        split_body.append(sidebar)

        # Files Grid
        files_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        files_box.set_margin_start(10)
        files_box.set_margin_end(10)
        files_box.set_margin_top(6)
        files_box.set_margin_bottom(6)
        files_box.set_hexpand(True)

        items = [
            ("󰉋", "nixos-config", True),
            ("󰉋", "wallpapers", True),
            ("󰈔", "themes.json", False),
        ]

        for glyph, name, is_folder in items:
            card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
            card.add_css_class("thunar-folder-card")
            card.set_hexpand(True)

            icon_lbl = Gtk.Label(label=glyph)
            icon_lbl.add_css_class("thunar-folder-icon" if is_folder else "thunar-file-icon")

            name_lbl = Gtk.Label(label=name)
            name_lbl.add_css_class("thunar-item-title")

            card.append(icon_lbl)
            card.append(name_lbl)
            files_box.append(card)

        split_body.append(files_box)
        thunar_frame.set_child(split_body)
        self.append(thunar_frame)

    def update_palette(self, palette):
        p = palette.to_dict()
        c1 = p.get("color1", "#f7768e")
        c2 = p.get("color2", "#9ece6a")
        c3 = p.get("color3", "#e0af68")
        c4 = p.get("color4", "#7aa2f7")
        c5 = p.get("color5", "#bb9af7")
        fg = p.get("foreground", "#cdd6f4")

        self.border_badge.set_text(f"hypr: {c4}")

        # Sintaxis con markup Pango dinámico usando colores de la paleta
        markup = (
            f"<span foreground='{c5}'><b>pub fn</b></span> "
            f"<span foreground='{c4}'>apply_theme</span>("
            f"<span foreground='{c3}'>accent</span>: &amp;str) -&gt; "
            f"<span foreground='{c3}'>Result</span> {{ "
            f"<span foreground='{c2}'>\"ok\"</span> }}"
        )
        self.code_lbl.set_markup(markup)
