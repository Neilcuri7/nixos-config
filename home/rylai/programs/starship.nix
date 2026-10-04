{ ... }:

{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      add_newline = true;

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      directory = {
        read_only = " 󰌾";
        truncation_length = 4;
        truncate_to_repo = true;
      };

      git_branch = {
        symbol = " ";
        format = "on [$symbol$branch]($style) ";
      };

      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        conflicted = "󰞇 ";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?";
        stashed = "󰔛 ";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      git_commit = {
        tag_symbol = " 󰓹 ";
      };

      # Programming languages & environments
      python = {
        symbol = " ";
        format = "via [$symbol$version( \\($virtualenv\\))]($style) ";
      };

      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state( \\($name\\))]($style) ";
      };

      rust = {
        symbol = "󱘗 ";
        format = "via [$symbol($version )]($style)";
      };

      nodejs = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      golang = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      c = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      cmake = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      java = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      kotlin = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      scala = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      dart = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      elixir = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      elm = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      erlang = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      haskell = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      julia = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      lua = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      nim = {
        symbol = "󰆥 ";
        format = "via [$symbol($version )]($style)";
      };

      ocaml = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      perl = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      php = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      purescript = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      ruby = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      swift = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      zig = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };

      # Runtimes, tools & package managers
      bun = {
        symbol = "󰞌 ";
        format = "via [$symbol($version )]($style)";
      };

      deno = {
        symbol = " ";
        format = "via [$symbol($version )]($style)";
      };


      package = {
        symbol = "󰏗 ";
        format = "is [$symbol$version]($style) ";
      };

      gradle = {
        symbol = " ";
      };

      dotnet = {
        symbol = "󰪮 ";
        format = "via [$symbol($version )( $tfm )]($style)";
      };

      # Cloud & Containers
      docker_context = {
        symbol = " ";
        format = "via [$symbol$context]($style) ";
      };

      kubernetes = {
        symbol = "󱃾 ";
        format = "[$symbol$context( \\($namespace\\))]($style) ";
      };

      aws = {
        symbol = "󰸏 ";
        format = "on [$symbol($profile )(\\($region\\) )(\\[$duration\\])]($style)";
      };

      gcloud = {
        symbol = "󱇶 ";
        format = "on [$symbol$account(@$domain)(\\($project\\))]($style)";
      };

      terraform = {
        symbol = "󱁢 ";
        format = "via [$symbol$workspace]($style) ";
      };

      # System & Status
      cmd_duration = {
        min_time = 2000;
        format = "took [$duration]($style) ";
      };

      memory_usage = {
        symbol = "󰍛 ";
      };

      sudo = {
        symbol = "󱐋 ";
      };

      os = {
        symbols = {
          Alpaquita = "󰪑 ";
          Alpine = " ";
          AlmaLinux = " ";
          Amazon = " ";
          Android = " ";
          Arch = " ";
          Artix = " ";
          CentOS = " ";
          Debian = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "󰛓 ";
          Gentoo = " ";
          HardenedBSD = "󰞌 ";
          Illumos = "󰈸 ";
          Kali = " ";
          Linux = " ";
          Mabox = " ";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = " ";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          OpenBSD = "󰈺 ";
          openSUSE = " ";
          OracleLinux = "󰌷 ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          RockyLinux = " ";
          Redox = "󰀘 ";
          Solus = "󰠳 ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = " ";
          Void = " ";
          Windows = "󰍲 ";
        };
      };
    };
  };
}
