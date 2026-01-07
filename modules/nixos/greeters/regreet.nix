# ReGreet - GTK-based graphical greeter for Wayland
{ pkgs, ... }:
{
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        # Set a wallpaper path or remove for solid color
        # path = "/home/michael/Pictures/Desktops/wallpaper.jpg";
        fit = "Cover";
      };
      GTK = {
        application_prefer_dark_theme = true;
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/Hyprland --config /etc/greetd/hyprland.conf";
        user = "greeter";
      };
    };
  };

  # Minimal Hyprland config just for the greeter
  environment.etc."greetd/hyprland.conf".text = ''
    exec-once = regreet; hyprctl dispatch exit

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
      force_default_wallpaper = 0
    }

    # Basic input config
    input {
      kb_layout = us
    }

    # Minimal decoration for greeter
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
