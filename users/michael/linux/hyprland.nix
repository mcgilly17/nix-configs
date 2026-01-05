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

    # Source local config for hot-reloading without rebuilds
    # Edit ~/.config/hypr/local.conf and run: hyprctl reload
    extraConfig = ''
      source = ~/.config/hypr/local.conf
    '';

    settings = {
      # Monitor configuration (dual 1440p@144hz)
      # DP-3 = primary (right), DP-2 = secondary (left)
      monitor = [
        "DP-3,preferred,0x0,1" # Primary at origin
        "DP-2,preferred,-2560x0,1" # Secondary to the left
      ];

      # Grouped workspaces: odd on DP-3, even on DP-2
      # Group 1 = WS 1+2, Group 2 = WS 3+4, etc.
      workspace = [
        "1, monitor:DP-3, default:true"
        "2, monitor:DP-2, default:true"
        "3, monitor:DP-3"
        "4, monitor:DP-2"
        "5, monitor:DP-3"
        "6, monitor:DP-2"
        "7, monitor:DP-3"
        "8, monitor:DP-2"
        "9, monitor:DP-3"
        "10, monitor:DP-2"
        # Scratchpad
        "special:scratchpad, on-created-empty:alacritty --class scratchpad"
      ];

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
        gaps_in = 3;
        gaps_out = 6;
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
          size = 8;
          passes = 2;
          new_optimizations = true;
          xray = false;
          noise = 0.01;
          contrast = 1.0;
          brightness = 1.0;
          popups = true;
        };
        shadow = {
          enabled = true;
          range = 8;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      # Animations
      animations = {
        enabled = true;
        # Smooth bezier curves
        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
          "bounce, 1, 1.6, 0.1, 0.85"
        ];
        animation = [
          "windows, 1, 5, overshot, slide"
          "windowsOut, 1, 4, smoothOut, slide"
          "windowsMove, 1, 4, smoothIn, slide"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 5, smoothIn"
          "fadeDim, 1, 5, smoothIn"
          "workspaces, 1, 6, overshot, slidevert"
        ];
      };

      # Startup applications
      exec-once = [
        "waybar"
        "swaync"
        "swww-daemon"
        "~/.local/bin/wallpaper-rotate 1800" # Rotate every 30 minutes
        "hypridle"
      ];

      # Scratchpad window rules
      windowrulev2 = [
        "float, class:^(scratchpad)$"
        "size 80% 70%, class:^(scratchpad)$"
        "center, class:^(scratchpad)$"
        "animation slide, class:^(scratchpad)$"
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

        # Switch to group (both monitors change together)
        "$mod, 1, exec, hyprctl dispatch workspace 1 && hyprctl dispatch workspace 2"
        "$mod, 2, exec, hyprctl dispatch workspace 3 && hyprctl dispatch workspace 4"
        "$mod, 3, exec, hyprctl dispatch workspace 5 && hyprctl dispatch workspace 6"
        "$mod, 4, exec, hyprctl dispatch workspace 7 && hyprctl dispatch workspace 8"
        "$mod, 5, exec, hyprctl dispatch workspace 9 && hyprctl dispatch workspace 10"

        # Move window to group (lands on primary monitor DP-3)
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 3"
        "$mod SHIFT, 3, movetoworkspace, 5"
        "$mod SHIFT, 4, movetoworkspace, 7"
        "$mod SHIFT, 5, movetoworkspace, 9"

        # Move windows
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        # Resize windows
        "$mod CTRL, H, resizeactive, -50 0"
        "$mod CTRL, L, resizeactive, 50 0"
        "$mod CTRL, K, resizeactive, 0 -50"
        "$mod CTRL, J, resizeactive, 0 50"

        # Fullscreen
        "$mod, F, fullscreen, 0"

        # Window switching
        "$mod, Tab, cyclenext"
        "$mod SHIFT, Tab, cyclenext, prev"

        # Screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, Print, exec, grim - | wl-copy"

        # Scratchpad
        "$mod, grave, togglespecialworkspace, scratchpad"

        # Lock screen
        "$mod, Escape, exec, hyprlock"
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

  # Hyprlock lockscreen config
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        grace = 3;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
          noise = 0.01;
          contrast = 0.9;
          brightness = 0.6;
        }
      ];

      input-field = [
        {
          size = "250, 50";
          position = "0, -80";
          halign = "center";
          valign = "center";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(205, 214, 244)";
          inner_color = "rgb(49, 50, 68)";
          outer_color = "rgb(137, 180, 250)";
          outline_thickness = 2;
          placeholder_text = "<i>Password...</i>";
          shadow_passes = 2;
        }
      ];

      label = [
        # Time
        {
          text = "cmd[update:1000] echo \"$(date +\"%H:%M\")\"";
          color = "rgb(205, 214, 244)";
          font_size = 90;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        # Date
        {
          text = "cmd[update:1000] echo \"$(date +\"%A, %d %B\")\"";
          color = "rgb(186, 194, 222)";
          font_size = 20;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 20";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # Services
  services = {
    # Hypridle auto-lock config
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          # Dim screen after 2.5 minutes
          {
            timeout = 150;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          # Lock after 5 minutes
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          # Turn off screen after 5.5 minutes
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          # Suspend after 30 minutes
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };

    # Clipboard manager for Walker
    cliphist.enable = true;

    # SwayNC notification center
    swaync = {
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
  };

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
            "1" = "1";
            "2" = "1";
            "3" = "2";
            "4" = "2";
            "5" = "3";
            "6" = "3";
            "7" = "4";
            "8" = "4";
            "9" = "5";
            "10" = "5";
          };
          all-outputs = false;
          persistent-workspaces = {
            "DP-3" = [
              1
              3
              5
              7
              9
            ];
            "DP-2" = [
              2
              4
              6
              8
              10
            ];
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
        padding: 0;
        min-width: 24px;
        min-height: 24px;
        color: #1e1e2e;
        font-weight: bold;
        border-radius: 50%;
        margin: 2px 4px;
        transition: all 0.3s ease;
      }

      #workspaces button.empty {
        background-color: #45475a;
        color: #313244;
      }

      #workspaces button:hover {
        opacity: 0.8;
      }

      /* Catppuccin colored workspace circles - paired by group */
      #workspaces button#hyprland-workspace-1,
      #workspaces button#hyprland-workspace-2 { background-color: #89b4fa; } /* blue - group 1 */
      #workspaces button#hyprland-workspace-3,
      #workspaces button#hyprland-workspace-4 { background-color: #a6e3a1; } /* green - group 2 */
      #workspaces button#hyprland-workspace-5,
      #workspaces button#hyprland-workspace-6 { background-color: #f9e2af; } /* yellow - group 3 */
      #workspaces button#hyprland-workspace-7,
      #workspaces button#hyprland-workspace-8 { background-color: #fab387; } /* peach - group 4 */
      #workspaces button#hyprland-workspace-9,
      #workspaces button#hyprland-workspace-10 { background-color: #f38ba8; } /* red - group 5 */

      #workspaces button.active {
        box-shadow: 0 0 0 2px #cdd6f4;
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

  home = {
    # Wallpaper rotation script
    file.".local/bin/wallpaper-rotate" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        WALLPAPER_DIR="$HOME/Pictures/Desktops"
        INTERVAL=''${1:-300}  # Default: 5 minutes

        set_wallpapers() {
          local img1="$1"
          local img2="$2"
          # Set different wallpaper per monitor with fade transition
          swww img "$img1" -o DP-3 --transition-type fade --transition-duration 1
          swww img "$img2" -o DP-2 --transition-type fade --transition-duration 1
        }

        # Set initial wallpapers
        if [[ -d "$WALLPAPER_DIR" ]]; then
          mapfile -t images < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf)
          if [[ ''${#images[@]} -ge 2 ]]; then
            idx=0
            set_wallpapers "''${images[$idx]}" "''${images[$((idx + 1))]}"

            # Rotate through wallpapers
            while true; do
              sleep "$INTERVAL"
              idx=$(( (idx + 2) % ''${#images[@]} ))
              # Handle odd number of images
              next_idx=$(( (idx + 1) % ''${#images[@]} ))
              set_wallpapers "''${images[$idx]}" "''${images[$next_idx]}"
            done
          fi
        fi
      '';
    };

    # Create local.conf if it doesn't exist (preserves user changes)
    activation.createHyprlandLocalConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f ~/.config/hypr/local.conf ]; then
        mkdir -p ~/.config/hypr
        cat > ~/.config/hypr/local.conf << 'EOF'
      # Local Hyprland config - edit this file and run: hyprctl reload
      # This file is NOT managed by Nix, so changes persist across rebuilds.
      #
      # Example overrides:
      # general {
      #   gaps_in = 5
      #   gaps_out = 10
      # }
      #
      # bind = $mod, B, exec, firefox
      EOF
      fi
    '';

    # Additional packages for Hyprland desktop
    packages = with pkgs; [
      # Launcher
      walker

      # Wayland utilities
      wl-clipboard
      grim
      slurp
      swww
      brightnessctl

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
  };
}
