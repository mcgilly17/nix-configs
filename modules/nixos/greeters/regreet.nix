# ReGreet - GTK-based graphical greeter for Wayland
{ pkgs, lib, ... }:
let
  # Hyprland wrapper script with NVIDIA environment
  hyprlandGreeter = pkgs.writeShellScript "hyprland-greeter" ''
    export WLR_NO_HARDWARE_CURSORS=1
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export LIBVA_DRIVER_NAME=nvidia
    exec ${pkgs.hyprland}/bin/Hyprland --config /etc/greetd/hyprland.conf
  '';
in
{
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        fit = "Cover";
      };
      GTK = {
        application_prefer_dark_theme = true;
      };
    };
    # Use catppuccin theme
    theme = {
      name = "catppuccin-mocha-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = [ "blue" ];
      };
    };
    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = 14;
    };
  };

  # Override the default cage session with Hyprland
  services.greetd.settings.default_session = {
    command = lib.mkForce "${hyprlandGreeter}";
    user = "greeter";
  };

  # Minimal Hyprland config just for the greeter
  environment.etc."greetd/hyprland.conf".text = ''
    # Auto-start regreet and exit when done
    exec-once = ${lib.getExe pkgs.greetd.regreet}; hyprctl dispatch exit

    # Primary monitor on right (DP-3), secondary on left (DP-2)
    monitor = DP-3,preferred,0x0,1
    monitor = DP-2,preferred,-2560x0,1

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
      force_default_wallpaper = 0
    }

    input {
      kb_layout = us
    }

    decoration {
      blur {
        enabled = false
      }
      shadow {
        enabled = false
      }
    }

    animations {
      enabled = false
    }
  '';
}
