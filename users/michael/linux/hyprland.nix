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

      # Cursor behavior
      cursor = {
        no_warps = true; # Prevent cursor jumping when switching workspaces
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
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "waybar"
        "swaync"
        "swww-daemon"
        "~/.local/bin/wallpaper-rotate 1800" # Rotate every 30 minutes
        "hypridle"
        "1password --silent"
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

  # Services
  services = {
    # MPRIS media player daemon (for waybar mpris module)
    playerctld.enable = true;
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
          mapfile -t images < <(find "$WALLPAPER_DIR" -type f -not -name '.*' \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf)
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
