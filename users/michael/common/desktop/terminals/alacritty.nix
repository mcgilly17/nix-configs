# Alacritty terminal configuration
{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "None";
        opacity = 0.95;
      };

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        size = if pkgs.stdenv.isDarwin then 13.0 else 11.0;
      };

      scrolling = {
        history = 10000;
      };

      selection = {
        save_to_clipboard = true;
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 500;
      };

      keyboard = {
        bindings = [
          # macOS specific bindings
          {
            key = "N";
            mods = "Command";
            action = "SpawnNewInstance";
          }
        ];
      };
    };
  };
}
