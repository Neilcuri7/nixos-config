{ ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      logo = {
        type = "auto";
        padding = {
          top = 1;
          left = 2;
        };
      };
      display = {
        separator = " :  ";
      };
      modules = [
        "break"
        {
          type = "custom";
          format = "┌─ Hardware ────────────────────────────────────────────────────────┐";
        }
        {
          type = "cpu";
          key = " CPU         ";
        }
        {
          type = "gpu";
          key = " GPU         ";
        }
        {
          type = "display";
          key = " Display     ";
        }
        {
          type = "disk";
          key = " Disk        ";
        }
        {
          type = "memory";
          key = " Memory      ";
        }
        {
          type = "custom";
          format = "└───────────────────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌─ Software ────────────────────────────────────────────────────────┐";
        }
        {
          type = "os";
          key = " OS          ";
        }
        {
          type = "kernel";
          key = " Kernel      ";
        }
        {
          type = "packages";
          key = " Packages    ";
        }
        {
          type = "shell";
          key = " Shell       ";
        }
        {
          type = "custom";
          format = "└───────────────────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌─ DE / WM ─────────────────────────────────────────────────────────┐";
        }
        {
          type = "de";
          key = " DE          ";
        }
        {
          type = "wm";
          key = " WM          ";
        }
        {
          type = "terminal";
          key = " Terminal    ";
        }
        {
          type = "custom";
          format = "└───────────────────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌─ Uptime / Age ────────────────────────────────────────────────────┐";
        }
        {
          type = "uptime";
          key = " Uptime      ";
        }
        {
          type = "custom";
          format = "└───────────────────────────────────────────────────────────────────┘";
        }
        "break"
      ];
    };
  };
}
