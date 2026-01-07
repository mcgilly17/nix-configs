# Hyprlock lockscreen configuration
{
  lib,
  osConfig,
  ...
}:
lib.mkIf (osConfig.programs.hyprland.enable or false) {
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
}
