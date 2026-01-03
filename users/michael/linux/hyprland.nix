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
      # Monitor configuration (scale 1 for gaming)
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
        layout = "master";
      };

      # Master layout settings
      master = {
        new_status = "slave";
        mfact = 0.5;
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

      # Startup applications
      exec-once = [
        "waybar"
        "swaync"
        "hyprpaper"
      ];

      # Keybindings
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      "$menu" = "walker";

      bind = [
        # Core
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, nautilus"
        "$mod, V, togglefloating,"
        "$mod, Space, exec, $menu"

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

        # Window switching
        "$mod, Tab, cyclenext"
        "$mod SHIFT, Tab, cyclenext, prev"

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

  # Hyprpaper wallpaper config
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    # Preload wallpapers (add your wallpaper paths here)
    # preload = ~/Pictures/wallpaper.jpg

    # Set wallpaper for all monitors
    # wallpaper = ,~/Pictures/wallpaper.jpg

    # Disable splash
    splash = false
    ipc = on
  '';

  # Waybar status bar
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 4;
        margin-top = 6;
        margin-left = 10;
        margin-right = 10;

        modules-left = [
          "custom/notification"
          "clock"
          "tray"
        ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [
          "cpu"
          "memory"
          "network"
          "pulseaudio"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
          };
          persistent-workspaces = {
            "*" = 5;
          };
          on-click = "activate";
        };

        "clock" = {
          format = " {:%H:%M}";
          format-alt = " {:%a %d %b %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            weeks-pos = "right";
            format = {
              months = "<span color='#cba6f7'><b>{}</b></span>";
              days = "<span color='#cdd6f4'>{}</span>";
              weeks = "<span color='#74c7ec'><b>W{}</b></span>";
              weekdays = "<span color='#f9e2af'><b>{}</b></span>";
              today = "<span color='#89b4fa'><b><u>{}</u></b></span>";
            };
          };
        };

        "cpu" = {
          format = " {usage}%";
          interval = 2;
          tooltip = true;
        };

        "memory" = {
          format = " {}%";
          interval = 2;
          tooltip = true;
          tooltip-format = "{used:0.1f}GB / {total:0.1f}GB";
        };

        "network" = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = " {ipaddr}";
          format-disconnected = "󰤭 ";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname}: {ipaddr}";
          on-click = "nm-connection-editor";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 ";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "pavucontrol";
          tooltip-format = "{desc}";
        };

        "custom/notification" = {
          exec = "swaync-client -swb";
          return-type = "json";
          format = "{icon}";
          format-icons = {
            notification = "󱅫";
            none = "󰂚";
            dnd-notification = "󰂛";
            dnd-none = "󰂛";
          };
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        "tray" = {
          icon-size = 16;
          spacing = 8;
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
        color: #cdd6f4;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background-color: rgba(30, 30, 46, 0.85);
        padding: 2px 10px;
        border-radius: 12px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
      }

      #workspaces button {
        padding: 0 8px;
        color: #6c7086;
        background: transparent;
        border-radius: 8px;
        margin: 2px;
        transition: all 0.3s ease;
      }

      #workspaces button.active {
        color: #89b4fa;
        background-color: rgba(137, 180, 250, 0.15);
      }

      #workspaces button.empty {
        color: #45475a;
      }

      #workspaces button:hover {
        color: #cdd6f4;
        background-color: rgba(108, 112, 134, 0.2);
      }

      #clock,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #custom-notification,
      #tray {
        padding: 0 10px;
        margin: 2px 2px;
        border-radius: 8px;
        transition: all 0.3s ease;
      }

      #clock {
        color: #89b4fa;
      }

      #cpu {
        color: #f38ba8;
      }

      #memory {
        color: #fab387;
      }

      #network {
        color: #94e2d5;
      }

      #pulseaudio {
        color: #cba6f7;
      }

      #custom-notification {
        color: #f9e2af;
      }

      #clock:hover,
      #cpu:hover,
      #memory:hover,
      #network:hover,
      #pulseaudio:hover,
      #custom-notification:hover {
        background-color: rgba(108, 112, 134, 0.2);
      }

      #tray {
        color: #cdd6f4;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      tooltip {
        background-color: #1e1e2e;
        border: 1px solid #89b4fa;
        border-radius: 8px;
      }

      tooltip label {
        color: #cdd6f4;
      }
    '';
  };

  # SwayNC notification center
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      control-center-width = 380;
      control-center-height = 600;
      control-center-margin-top = 10;
      control-center-margin-right = 10;
      notification-window-width = 400;
      notification-icon-size = 48;
      notification-body-image-height = 160;
      notification-body-image-width = 200;
      timeout = 4;
      timeout-low = 2;
      timeout-critical = 6;
      fit-to-screen = true;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      widgets = [
        "title"
        "dnd"
        "notifications"
        "mpris"
      ];
      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
        };
        dnd = {
          text = "Do Not Disturb";
        };
        mpris = {
          image-size = 96;
          image-radius = 8;
        };
      };
    };
    # Let catppuccin module handle styling
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
    hyprpaper

    # File manager
    nautilus

    # Audio control
    pavucontrol

    # Network settings
    networkmanagerapplet

    # Fonts
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];
}
