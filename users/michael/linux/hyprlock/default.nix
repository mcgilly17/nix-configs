# Hyprlock lockscreen configuration
# Using catppuccin macchiato colors
{
  lib,
  osConfig,
  ...
}:
lib.mkIf (osConfig.programs.hyprland.enable or false) {
  # Use catppuccin colors but not its default widget layout
  catppuccin.hyprlock = {
    enable = true;
    useDefaultConfig = false;
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      "$font" = "JetBrainsMono Nerd Font";

      general = {
        hide_cursor = true;
        grace = 3;
        no_fade_in = false;
      };

      background = [
        {
          monitor = "";
          path = "";
          color = "$base";
        }
      ];

      # User avatar (requires ~/.face image)
      image = [
        {
          monitor = "";
          path = "$HOME/.face";
          size = 80;
          border_color = "$accent";
          position = "0, 60";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 50";
          outline_thickness = 3;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "$accent";
          inner_color = "$surface0";
          font_color = "$text";
          fade_on_empty = false;
          placeholder_text = ''<span foreground="##$textAlpha"><i>󰌾 Logged in as </i><span foreground="##$accentAlpha">$USER</span></span>'';
          hide_input = false;
          check_color = "$accent";
          fail_color = "$red";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          capslock_color = "$yellow";
          position = "0, -35";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        # Layout indicator (top-left)
        {
          monitor = "";
          text = "Layout: $LAYOUT";
          color = "$text";
          font_size = 18;
          font_family = "$font";
          position = "20, -20";
          halign = "left";
          valign = "top";
        }
        # Time (top-right)
        {
          monitor = "";
          text = "$TIME";
          color = "$text";
          font_size = 72;
          font_family = "$font";
          position = "-20, 0";
          halign = "right";
          valign = "top";
        }
        # Date (top-right, below time)
        {
          monitor = "";
          text = ''cmd[update:43200000] date +"%A, %d %B %Y"'';
          color = "$text";
          font_size = 18;
          font_family = "$font";
          position = "-20, -110";
          halign = "right";
          valign = "top";
        }
      ];
    };
  };
}
