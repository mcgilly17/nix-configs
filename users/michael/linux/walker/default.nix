# Walker v2 launcher configuration (Raycast-like)
{
  pkgs,
  lib,
  osConfig,
  ...
}:
lib.mkIf (osConfig.programs.hyprland.enable or false) {
  programs = {
    # Elephant backend for Walker - use patched package until upstream fixes go.sum
    # TODO: Remove this override once https://github.com/abenz1267/elephant go.sum is fixed
    elephant.package = pkgs.elephant-patched;

    walker = {
      enable = true;
      runAsService = true;
      config = {
        close_when_open = true;
        single_click_activation = true;
        theme = "default";

        shell = {
          anchor_top = false;
          anchor_bottom = false;
          anchor_left = true;
          anchor_right = true;
        };

        placeholders.default = {
          input = "Search...";
          list = "No Results";
        };

        providers = {
          default = [
            "desktopapplications"
            "calc"
          ];
          empty = [ "desktopapplications" ];
          max_results = 50;

          prefixes = [
            {
              prefix = "=";
              provider = "calc";
            }
            {
              prefix = "@";
              provider = "websearch";
            }
            {
              prefix = ":";
              provider = "clipboard";
            }
            {
              prefix = "/";
              provider = "files";
            }
            {
              prefix = ";";
              provider = "providerlist";
            }
            {
              prefix = "p";
              provider = "1password";
            }
          ];
        };

        keybinds = {
          close = [ "Escape" ];
          next = [ "Down" ];
          previous = [ "Up" ];
          quick_activate = [
            "F1"
            "F2"
            "F3"
            "F4"
          ];
        };
      };
    };
  };

  # Clipboard manager for Walker
  services.cliphist.enable = true;
}
