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
        p1 = Gtk.Label(label="rylai@nixos ~ ❯ git status -s", xalign=0)
        p1.set_use_markup(True)
        p1.set_markup("<span class='term-user-host'>rylai@nixos</span> <span class='term-dir'>~</span> <span class='term-symbol'>❯</span> git status -s")
        cmd1_box.append(p1)

        out1 = Gtk.Label(label="  ✓ working tree clean (main)", xalign=0)
        out1.add_css_class("term-success")
        cmd1_box.append(out1)
        body.append(cmd1_box)

        # Prompt 2: Failed command
        cmd2_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        p2 = Gtk.Label(label="rylai@nixos ~ ❯ curl -I https://api.local/v1", xalign=0)
        p2.set_use_markup(True)
        p2.set_markup("<span class='term-user-host'>rylai@nixos</span> <span class='term-dir'>~</span> <span class='term-symbol'>❯</span> curl -I https://api.local/v1")
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

        code_lines = [
            "<span class='syntax-kw'>pub fn</span> <span class='syntax-fn'>sync_wallust_palette</span>(colors: &amp;<span class='syntax-type'>Palette</span>) -&gt; <span class='syntax-type'>Result</span>&lt;(), <span class='syntax-type'>Error</span>&gt; {",
            "    <span class='syntax-kw'>let</span> accent = colors.ansi[<span class='syntax-var'>4</span>].<span class='syntax-fn'>to_hex</span>();",
            "    compositor::<span class='syntax-fn'>set_active_border</span>(&amp;accent)?;",
            "}"
        ]
        code_lbl = Gtk.Label(xalign=0)
        code_lbl.set_use_markup(True)
        code_lbl.set_markup("\n".join(code_lines))
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
        cursor_line = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        c_p = Gtk.Label(label="rylai@nixos ~ ❯", xalign=0)
        c_p.set_use_markup(True)
        c_p.set_markup("<span class='term-user-host'>rylai@nixos</span> <span class='term-dir'>~</span> <span class='term-symbol'>❯</span>")
        cursor_block = Gtk.Box()
        cursor_block.set_size_request(8, 15)
        cursor_block.add_css_class("term-cursor")
        cursor_line.append(c_p)
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

        # Top Floating Waybar
        waybar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        waybar.add_css_class("waybar-bar-card")

        # Workspaces Left
        ws_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        for i, num in enumerate(["1", "2", "3", "4"]):
            btn = Gtk.Label(label=num)
            btn.add_css_class("ws-capsule")
            btn.add_css_class("active" if i == 0 else "inactive")
            ws_box.append(btn)
        waybar.append(ws_box)

        # Center Clock
        spacer1 = Gtk.Box()
        spacer1.set_hexpand(True)
        waybar.append(spacer1)

        clock_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        clock_lbl = Gtk.Label(label="󰥔 Dom 10 Oct 12:45")
        clock_lbl.add_css_class("waybar-clock")
        clock_box.append(clock_lbl)
        waybar.append(clock_box)

        spacer2 = Gtk.Box()
        spacer2.set_hexpand(True)
        waybar.append(spacer2)

        # Right Telemetry Pills
        telem_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        
        cpu = Gtk.Label(label="󰍛 24%")
        cpu.add_css_class("telemetry-pill")
        cpu.add_css_class("pill-cpu")
        telem_box.append(cpu)

        ram = Gtk.Label(label="󰘚 48%")
        ram.add_css_class("telemetry-pill")
        ram.add_css_class("pill-ram")
        telem_box.append(ram)

        vol = Gtk.Label(label="󰕾 80%")
        vol.add_css_class("telemetry-pill")
        vol.add_css_class("pill-audio")
        telem_box.append(vol)

        bat = Gtk.Label(label="󰁹 95%")
        bat.add_css_class("telemetry-pill")
        bat.add_css_class("pill-battery")
        telem_box.append(bat)

        waybar.append(telem_box)
        container.append(waybar)

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
            "<span class='syntax-kw'>const</span> <span class='syntax-fn'>theme</span> = {\n"
            "  <span class='syntax-var'>accent</span>: <span class='syntax-str'>\"#7aa2f7\"</span>,\n"
            "  <span class='syntax-var'>engine</span>: <span class='syntax-str'>\"wallust_v2\"</span>\n"
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

        # Bottom Decorators Pill
        status_pill = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        status_pill.add_css_class("bottom-status-pill")
        sp_l = Gtk.Label(label="Hyprland Decorators Ready: Gaps: 6px • Rounding: 12px • Active Border: 2px Solid Accent", xalign=0)
        sp_r = Gtk.Label(label="● LIVE REFRESH 60FPS", xalign=1)
        sp_r.add_css_class("term-success")
        sp_l.set_hexpand(True)
        status_pill.append(sp_l)
        status_pill.append(sp_r)
        container.append(status_pill)

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

        # Thunar Footer
        footer_pill = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        footer_pill.add_css_class("bottom-status-pill")
        footer_pill.set_valign(Gtk.Align.END)
        foot_text = Gtk.Label(label="8 elementos • Espacio libre: 142.8 GB • Papirus Accent: Cyan-Blue (#7aa2f7)", xalign=0)
        foot_text.set_hexpand(True)
        footer_pill.append(foot_text)
        file_canvas.append(footer_pill)

        split_body.append(file_canvas)
        vbox.append(split_body)

        thunar_frame.set_child(vbox)
        self.stack.add_named(thunar_frame, "thunar")
