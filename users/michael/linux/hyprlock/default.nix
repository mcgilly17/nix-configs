# Hyprlock lockscreen configuration
{
  lib,
  osConfig,
  ...
}:
lib.mkIf (osConfig.programs.hyprland.enable or false) {
  # Use catppuccin theme for hyprlock
  catppuccin.hyprlock.enable = true;

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
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 6;
          noise = 0.0117;
          contrast = 0.9;
          brightness = 0.7;
          vibrancy = 0.2;
          vibrancy_darkness = 0.0;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "300, 50";
          position = "0, -120";
          halign = "center";
          valign = "center";
          outline_thickness = 3;
          dots_size = 0.25;
          dots_spacing = 0.2;
          dots_center = true;
          dots_rounding = -1;
          fade_on_empty = false;
          fade_timeout = 1000;
          placeholder_text = "Enter Password";
          hide_input = false;
          rounding = 15;
          fail_text = "<i>$FAIL</i>";
          fail_transition = 300;
          capslock_color = "rgb(249, 226, 175)";
        }
      ];

      label = [
        # Time
        {
          monitor = "";
          text = "$TIME";
          font_size = 120;
          font_family = "JetBrainsMono Nerd Font Bold";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        # Date
        {
          monitor = "";
          text = "cmd[update:3600000] echo \"$(date +\"%A, %d %B\")\"";
          font_size = 22;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        # Greeting
        {
          monitor = "";
          text = "Hi, $USER";
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -40";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
