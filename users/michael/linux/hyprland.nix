# Hyprland configuration for Linux desktops
{
  pkgs,
  lib,
  osConfig,
  ...
}:

# Only enable if Hyprland is enabled at the system level
lib.mkIf (osConfig.programs.hyprland.enable or false) {
  # Hyprland window manager config
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor configuration (auto-detect)
      monitor = [ ",preferred,auto,1" ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt5ct"
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
        sensitivity = 0;
      };

      # General appearance
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee) rgba(cba6f7ee) 45deg"; # Catppuccin blue/mauve
        "col.inactive_border" = "rgba(313244aa)"; # Catppuccin surface0
        layout = "dwindle";
      };

      # Decoration (rounded corners, blur, shadows)
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      # Animations
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Startup applications
      exec-once = [
        "waybar"
        "mako"
        "swww-daemon"
      ];

      # Keybindings
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "walker";

      bind = [
        # Core
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, nautilus"
        "$mod, V, togglefloating,"
        "$mod, Space, exec, $menu"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"

        # Focus movement
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Fullscreen
        "$mod, F, fullscreen, 0"

        # Screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, Print, exec, grim - | wl-copy"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  # Walker launcher config (Raycast-like)
  xdg.configFile."walker/config.toml".text = ''
    [search]
    placeholder = "Search..."

    [ui]
    fullscreen = false

    [ui.anchors]
    top = true

    [list]
    height = 300

    [[modules]]
    name = "applications"
    prefix = ""

    [[modules]]
    name = "runner"
    prefix = "!"

    [[modules]]
    name = "websearch"
    prefix = "?"

    [[modules]]
    name = "clipboard"
    prefix = "@"

    [[modules]]
    name = "calc"
    prefix = "="
  '';

  # Waybar status bar
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
        };

        "clock" = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        "cpu" = {
          format = " {usage}%";
          interval = 2;
        };

        "memory" = {
          format = " {}%";
          interval = 2;
        };

        "network" = {
          format-wifi = " {signalStrength}%";
          format-ethernet = " {ipaddr}";
          format-disconnected = "⚠ Disconnected";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = " Muted";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };

        "tray" = {
          spacing = 10;
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }

      window#waybar {
        background-color: rgba(30, 30, 46, 0.9);
        color: #cdd6f4;
        border-bottom: 2px solid rgba(137, 180, 250, 0.5);
      }

      #workspaces button {
        padding: 0 8px;
        color: #cdd6f4;
        background: transparent;
        border-radius: 5px;
        margin: 3px;
      }

      #workspaces button.active {
        background-color: #89b4fa;
        color: #1e1e2e;
      }

      #workspaces button:hover {
        background-color: #45475a;
      }

      #clock, #cpu, #memory, #network, #pulseaudio, #tray {
        padding: 0 10px;
        margin: 3px 2px;
        background-color: #313244;
        border-radius: 5px;
      }

      #clock {
        background-color: #89b4fa;
        color: #1e1e2e;
      }
    '';
  };

  # Mako notification daemon
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    backgroundColor = "#1e1e2edd";
    textColor = "#cdd6f4";
    borderColor = "#89b4fa";
    borderRadius = 10;
    borderSize = 2;
    font = "JetBrainsMono Nerd Font 11";
  };

  # Clipboard manager for Walker
  services.cliphist.enable = true;

  # Additional packages for Hyprland desktop
  home.packages = with pkgs; [
    # Launcher
    walker

    # Wayland utilities
    wl-clipboard
    grim
    slurp
    swww

    # File manager
    nautilus

    # Audio control
    pavucontrol

    # Fonts
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];
}
