import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

from gi.repository import Gtk, Adw, Gdk, Pango

class PreviewPanel(Gtk.Box):
    def __init__(self, *args, **kwargs):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=14, *args, **kwargs)
        self.set_margin_start(12)
        self.set_margin_end(16)
        self.set_margin_top(16)
        self.set_margin_bottom(16)
        self.set_hexpand(True)
        self.set_vexpand(True)
        self.add_css_class("preview-canvas-card")

        # Top Centered Pill View Switcher
        switcher_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        switcher_box.set_halign(Gtk.Align.CENTER)
        
        self.pill_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        self.pill_bar.add_css_class("tab-pill-box")

        self.btn_terminal = Gtk.Button(label="TERMINAL")
        self.btn_terminal.add_css_class("tab-pill-btn")
        self.btn_terminal.add_css_class("active")
        self.btn_terminal.connect("clicked", lambda b: self.switch_tab("terminal"))
        self.pill_bar.append(self.btn_terminal)

        self.btn_waybar = Gtk.Button(label="DESKTOP / WAYBAR")
        self.btn_waybar.add_css_class("tab-pill-btn")
        self.btn_waybar.connect("clicked", lambda b: self.switch_tab("waybar"))
        self.pill_bar.append(self.btn_waybar)

        self.btn_thunar = Gtk.Button(label="THUNAR FILES")
        self.btn_thunar.add_css_class("tab-pill-btn")
        self.btn_thunar.connect("clicked", lambda b: self.switch_tab("thunar"))
        self.pill_bar.append(self.btn_thunar)

        switcher_box.append(self.pill_bar)
        self.append(switcher_box)

        # Multi-view Stack
        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE)
        self.stack.set_transition_duration(150)
        self.stack.set_hexpand(True)
        self.stack.set_vexpand(True)
        self.append(self.stack)

        self.setup_terminal_view()
        self.setup_waybar_view()
        self.setup_thunar_view()

    def switch_tab(self, tab_name: str):
        self.btn_terminal.remove_css_class("active")
        self.btn_waybar.remove_css_class("active")
        self.btn_thunar.remove_css_class("active")

        if tab_name == "terminal":
            self.btn_terminal.add_css_class("active")
            self.stack.set_visible_child_name("terminal")
        elif tab_name == "waybar":
            self.btn_waybar.add_css_class("active")
            self.stack.set_visible_child_name("waybar")
        elif tab_name == "thunar":
            self.btn_thunar.add_css_class("active")
            self.stack.set_visible_child_name("thunar")

    # ================= 1. TERMINAL PREVIEW (KITTY) =================
    def setup_terminal_view(self):
        term_frame = Gtk.Frame()
        term_frame.add_css_class("term-window-card")
        term_frame.set_hexpand(True)
        term_frame.set_vexpand(True)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)

        # Titlebar
        titlebar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        titlebar.add_css_class("term-titlebar")

        controls = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
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

        shell_badge = Gtk.Label(label="zsh", xalign=1)
        shell_badge.add_css_class("term-title-text")
        titlebar.append(shell_badge)

        vbox.append(titlebar)

        # Terminal Body
        body = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        body.add_css_class("term-body")
        body.set_vexpand(True)

        # Prompt 1: Successful command
        cmd1_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        p1 = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        lbl_usr = Gtk.Label(label="rylai@nixos")
        lbl_usr.add_css_class("term-user-host")
        lbl_dir = Gtk.Label(label="~")
        lbl_dir.add_css_class("term-dir")
        lbl_sym = Gtk.Label(label="❯")
        lbl_sym.add_css_class("term-symbol")
        lbl_cmd = Gtk.Label(label="git status -s")
        p1.append(lbl_usr)
        p1.append(lbl_dir)
        p1.append(lbl_sym)
        p1.append(lbl_cmd)
        cmd1_box.append(p1)

        out1 = Gtk.Label(label="  ✓ working tree clean (main)", xalign=0)
        out1.add_css_class("term-success")
        cmd1_box.append(out1)
        body.append(cmd1_box)

        # Prompt 2: Failed command
        cmd2_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        p2 = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        lbl_usr2 = Gtk.Label(label="rylai@nixos")
        lbl_usr2.add_css_class("term-user-host")
        lbl_dir2 = Gtk.Label(label="~")
        lbl_dir2.add_css_class("term-dir")
        lbl_sym2 = Gtk.Label(label="❯")
        lbl_sym2.add_css_class("term-symbol")
        lbl_cmd2 = Gtk.Label(label="curl -I https://api.local/v1")
        p2.append(lbl_usr2)
        p2.append(lbl_dir2)
        p2.append(lbl_sym2)
        p2.append(lbl_cmd2)
        cmd2_box.append(p2)

        out2 = Gtk.Label(label="  ✖ Error 404: Endpoint Not Found", xalign=0)
        out2.add_css_class("term-error")
        cmd2_box.append(out2)
        body.append(cmd2_box)

        # Syntax Highlighting Box
        syntax_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        syntax_box.add_css_class("code-syntax-box")
        
        s_title = Gtk.Label(label="SYNTAX HIGHLIGHTING TEST:", xalign=0)
        s_title.add_css_class("section-header-title")
        syntax_box.append(s_title)

        code_lbl = Gtk.Label(xalign=0)
        code_lbl.set_use_markup(True)
        code_lbl.set_markup(
            "<b>pub fn</b> sync_wallust_palette(colors: &amp;Palette) -&gt; Result&lt;(), Error&gt; {\n"
            "    <b>let</b> accent = colors.ansi[4].to_hex();\n"
            "    compositor::set_active_border(&amp;accent)?;\n"
            "}"
        )
        syntax_box.append(code_lbl)
        body.append(syntax_box)

        # ANSI 8x2 Test Swatch Grid
        ansi_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        ansi_box.set_valign(Gtk.Align.END)
        
        grid_lbl = Gtk.Label(label="8X2 ANSI TEST GRID:", xalign=0)
        grid_lbl.add_css_class("section-header-title")
        ansi_box.append(grid_lbl)

        grid = Gtk.Grid(column_spacing=6, row_spacing=6)
        grid.set_halign(Gtk.Align.FILL)
        
        for idx in range(16):
            cell = Gtk.Label(label="gYw")
            cell.set_hexpand(True)
            cell.add_css_class("ansi-block-cell")
            cell.add_css_class(f"cell-bg-{idx % 8 + 1}")
            grid.attach(cell, idx % 8, idx // 8, 1, 1)

        ansi_box.append(grid)

        # Active cursor line
        cursor_line = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        c_u = Gtk.Label(label="rylai@nixos")
        c_u.add_css_class("term-user-host")
        c_d = Gtk.Label(label="~")
        c_d.add_css_class("term-dir")
        c_s = Gtk.Label(label="❯")
        c_s.add_css_class("term-symbol")
        cursor_block = Gtk.Box()
        cursor_block.set_size_request(8, 15)
        cursor_block.add_css_class("term-cursor")
        cursor_line.append(c_u)
        cursor_line.append(c_d)
        cursor_line.append(c_s)
        cursor_line.append(cursor_block)
        ansi_box.append(cursor_line)

        body.append(ansi_box)

        vbox.append(body)
        term_frame.set_child(vbox)
        self.stack.add_named(term_frame, "terminal")

    # ================= 2. DESKTOP / WAYBAR PREVIEW =================
    def setup_waybar_view(self):
        container = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        container.set_hexpand(True)
        container.set_vexpand(True)

        # Top Floating Waybar: Three Islands (.modules-left, .modules-center, .modules-right)
        waybar_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        waybar_bar.add_css_class("waybar-window")

        # 1. Modules Left: Workspaces + Group/Stats
        modules_left = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        modules_left.add_css_class("modules-left")

        # Workspaces
        ws_container = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        ws_container.add_css_class("waybar-workspaces")
        
        # Format: {icon} {windows} como en config.jsonc ("一 󰞷", "● 󰞷 󰈔", "三 󰙯", "四 󰉋 󰞷", "五 󰞷")
        ws_items = [
            ("一 󰞷", False),
            ("● 󰞷 󰈔", True),
            ("三 󰙯", False),
            ("四 󰉋 󰞷", False),
            ("五 󰞷", False)
        ]
        for text, is_active in ws_items:
            btn = Gtk.Label(label=text)
            btn.add_css_class("ws-btn")
            if is_active:
                btn.add_css_class("active")
            ws_container.append(btn)
        modules_left.append(ws_container)

        # Stats Group (custom-stats-icon)
        stats_icon = Gtk.Label(label="󰰄")
        stats_icon.add_css_class("waybar-mod")
        stats_icon.add_css_class("mod-stats-icon")
        modules_left.append(stats_icon)

        waybar_bar.append(modules_left)

        # Center Spacer
        spacer1 = Gtk.Box()
        spacer1.set_hexpand(True)
        waybar_bar.append(spacer1)

        # 2. Modules Center: Clock
        modules_center = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        modules_center.add_css_class("modules-center")
        clock_lbl = Gtk.Label(label="11:08")
        clock_lbl.add_css_class("waybar-mod")
        clock_lbl.add_css_class("mod-clock")
        modules_center.append(clock_lbl)
        waybar_bar.append(modules_center)

        # Right Spacer
        spacer2 = Gtk.Box()
        spacer2.set_hexpand(True)
        waybar_bar.append(spacer2)

        # 3. Modules Right: volume-icon, audio, network, battery, tray
        modules_right = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        modules_right.add_css_class("modules-right")

        # Volume control icon
        vol_icon = Gtk.Label(label="󱕃")
        vol_icon.add_css_class("waybar-mod")
        vol_icon.add_css_class("mod-vol-icon")
        modules_right.append(vol_icon)

        # Network icon
        net_lbl = Gtk.Label(label="󰤨")
        net_lbl.add_css_class("waybar-mod")
        net_lbl.add_css_class("mod-network")
        modules_right.append(net_lbl)

        # Battery icon / capacity
        bat_lbl = Gtk.Label(label="󰂀")
        bat_lbl.add_css_class("waybar-mod")
        bat_lbl.add_css_class("mod-battery")
        modules_right.append(bat_lbl)

        # Tray icons
        tray_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        tray_box.add_css_class("waybar-mod")
        tray_box.add_css_class("mod-tray")
        for t_icon in ["󰘑", "󰙯"]:
            t_lbl = Gtk.Label(label=t_icon)
            tray_box.append(t_lbl)
        modules_right.append(tray_box)

        waybar_bar.append(modules_right)
        container.append(waybar_bar)

        # Floating Hyprland Window
        win_frame = Gtk.Frame()
        win_frame.add_css_class("hypr-active-window")
        win_frame.set_hexpand(True)
        win_frame.set_vexpand(True)

        win_vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)

        # Window Header
        w_head = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        w_head.add_css_class("term-titlebar")

        w_dots = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        for c in ["term-dot-red", "term-dot-yellow", "term-dot-green"]:
            dot = Gtk.Box()
            dot.add_css_class("term-dot")
            dot.add_css_class(c)
            w_dots.append(dot)
        w_head.append(w_dots)

        w_title = Gtk.Label(label="󰖲 hyprland // active_client: code-editor", xalign=0)
        w_title.add_css_class("term-title-text")
        w_title.set_hexpand(True)
        w_head.append(w_title)

        border_tag = Gtk.Label(label="col.active_border = 0xff7aa2f7", xalign=1)
        border_tag.add_css_class("section-badge")
        w_head.append(border_tag)

        win_vbox.append(w_head)

        # Window Interior
        win_body = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        win_body.set_margin_start(16)
        win_body.set_margin_end(16)
        win_body.set_margin_top(16)
        win_body.set_margin_bottom(16)
        win_body.set_vexpand(True)

        # Specimen Top Bar
        specimen_head = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        
        head_titles = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        s_sub = Gtk.Label(label="CALIBRADOR DE CONTRASTE NÓRDICO", xalign=0)
        s_sub.add_css_class("section-header-title")
        s_main = Gtk.Label(label="Libadwaita Color Specimen", xalign=0)
        s_main.add_css_class("slider-label")
        head_titles.append(s_sub)
        head_titles.append(s_main)
        specimen_head.append(head_titles)

        sp_fill = Gtk.Box()
        sp_fill.set_hexpand(True)
        specimen_head.append(sp_fill)

        wcag_pill = Gtk.Label(label="● WCAG AAA • 8.4:1 RATIO • CONTRASTE ÓPTIMO")
        wcag_pill.add_css_class("contrast-badge")
        specimen_head.append(wcag_pill)

        win_body.append(specimen_head)

        # 3 Cards Grid
        cards_grid = Gtk.Grid(column_spacing=12, row_spacing=12)
        cards_grid.set_hexpand(True)
        cards_grid.set_vexpand(True)

        # Card 1: Primary Typography
        c1 = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        c1.add_css_class("preview-content-card")
        c1.set_hexpand(True)
        c1_head = Gtk.Label(label="TIPOGRAFÍA PRIMARIA   INTER / 400", xalign=0)
        c1_head.add_css_class("section-header-title")
        c1_body = Gtk.Label(
            label="El veloz murciélago hindú comía feliz cardillo y kiwi. La cigüeña tocaba el saxofón detrás del palenque de paja.",
            xalign=0
        )
        c1_body.set_wrap(True)
        c1_body.add_css_class("slider-label")
        c1_foot = Gtk.Label(label="Aa Bb Gg 0-9               PASS", xalign=0)
        c1_foot.add_css_class("section-header-title")
        c1.append(c1_head)
        c1.append(c1_body)
        c1.append(c1_foot)
        cards_grid.attach(c1, 0, 0, 1, 1)

        # Card 2: Monospace Syntax
        c2 = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        c2.add_css_class("preview-content-card")
        c2.set_hexpand(True)
        c2_head = Gtk.Label(label="SINTAXIS MONOSPACE   JETBRAINS MONO", xalign=0)
        c2_head.add_css_class("section-header-title")
        c2_code = Gtk.Label(xalign=0)
        c2_code.set_use_markup(True)
        c2_code.set_markup(
            "<b>const</b> theme = {\n"
            "  accent: \"#7aa2f7\",\n"
            "  engine: \"wallust_v2\"\n"
            "};"
        )
        c2_foot = Gtk.Label(label="UTF-8 // Wayland          SYNCED", xalign=0)
        c2_foot.add_css_class("section-header-title")
        c2.append(c2_head)
        c2.append(c2_code)
        c2.append(c2_foot)
        cards_grid.attach(c2, 1, 0, 1, 1)

        # Card 3: Color Curves
        c3 = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        c3.add_css_class("preview-content-card")
        c3.set_hexpand(True)
        c3_head = Gtk.Label(label="CURVA LUMA ESPECTRAL    CIE LAB", xalign=0)
        c3_head.add_css_class("section-header-title")
        c3_desc = Gtk.Label(label="Distribución balanceada de reflectancia sobre fondo oscuro a 60 FPS.", xalign=0)
        c3_desc.set_wrap(True)
        c3_desc.add_css_class("slider-label")
        c3_foot = Gtk.Label(label="Delta E: &lt; 1.2        CALIBRADO", xalign=0)
        c3_foot.add_css_class("section-header-title")
        c3.append(c3_head)
        c3.append(c3_desc)
        c3.append(c3_foot)
        cards_grid.attach(c3, 2, 0, 1, 1)

        win_body.append(cards_grid)
        win_vbox.append(win_body)
        win_frame.set_child(win_vbox)

        container.append(win_frame)

        self.stack.add_named(container, "waybar")

    # ================= 3. THUNAR FILES PREVIEW =================
    def setup_thunar_view(self):
        thunar_frame = Gtk.Frame()
        thunar_frame.add_css_class("thunar-shell-card")
        thunar_frame.set_hexpand(True)
        thunar_frame.set_vexpand(True)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)

        # Titlebar
        t_head = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        t_head.add_css_class("term-titlebar")

        t_dots = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        for c in ["term-dot-red", "term-dot-yellow", "term-dot-green"]:
            dot = Gtk.Box()
            dot.add_css_class("term-dot")
            dot.add_css_class(c)
            t_dots.append(dot)
        t_head.append(t_dots)

        t_path = Gtk.Label(label="thunar — /home/rylai/Documents/projects", xalign=0)
        t_path.add_css_class("term-title-text")
        t_path.set_hexpand(True)
        t_head.append(t_path)

        t_ctrls = Gtk.Label(label="󰍉  󰕰", xalign=1)
        t_ctrls.add_css_class("term-title-text")
        t_head.append(t_ctrls)

        vbox.append(t_head)

        # Main Shell Area (Split: Sidebar + File Grid)
        split_body = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        split_body.set_vexpand(True)

        # Sidebar
        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        sidebar.add_css_class("thunar-sidebar")
        sidebar.set_size_request(160, -1)

        side_title = Gtk.Label(label="LUGARES", xalign=0)
        side_title.add_css_class("section-header-title")
        sidebar.append(side_title)

        places = [
            ("󰋜 Home", True),
            ("󰉍 Descargas", False),
            ("󱂬 Documentos", False),
            ("󰉏 Imágenes", False),
            ("󰎈 Música", False),
            ("󰉋 Projects", False)
        ]
        for name, is_active in places:
            item = Gtk.Label(label=name, xalign=0)
            item.add_css_class("thunar-place-item")
            if is_active:
                item.add_css_class("active")
            sidebar.append(item)

        split_body.append(sidebar)

        # Files Right Canvas
        file_canvas = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        file_canvas.set_margin_start(16)
        file_canvas.set_margin_end(16)
        file_canvas.set_margin_top(14)
        file_canvas.set_margin_bottom(14)
        file_canvas.set_hexpand(True)

        # Directory Grid (4 folders + 4 files)
        file_grid = Gtk.Grid(column_spacing=14, row_spacing=14)
        file_grid.set_hexpand(True)

        grid_items = [
            ("󰉋", "dotfiles", "Carpeta", True),
            ("󰉋", "nixos-config", "Carpeta", True),
            ("󰉋", "wallpapers", "Carpeta", True),
            ("󰉋", "scripts", "Carpeta", True),
            ("󰈔", "flake.nix", "Nix Flake", False),
            ("󰈔", "configuration.nix", "Nix Config", False),
            ("󰈔", "colors.css", "Hoja de Estilos", False),
            ("󰈔", "README.md", "Markdown", False),
        ]

        for i, (glyph, name, subtitle, is_folder) in enumerate(grid_items):
            card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
            card.add_css_class("thunar-folder-card")
            card.set_hexpand(True)
            card.set_size_request(110, 85)

            icon_lbl = Gtk.Label(label=glyph)
            icon_lbl.add_css_class("thunar-folder-icon" if is_folder else "thunar-file-icon")

            name_lbl = Gtk.Label(label=name)
            name_lbl.add_css_class("thunar-item-title")

            sub_lbl = Gtk.Label(label=subtitle)
            sub_lbl.add_css_class("thunar-item-subtitle")

            card.append(icon_lbl)
            card.append(name_lbl)
            card.append(sub_lbl)

            file_grid.attach(card, i % 4, i // 4, 1, 1)

        file_canvas.append(file_grid)
        split_body.append(file_canvas)
        vbox.append(split_body)

        thunar_frame.set_child(vbox)
        self.stack.add_named(thunar_frame, "thunar")
