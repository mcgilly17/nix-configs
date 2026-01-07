{ inputs, pkgs, ... }:
{
  imports = [
    # Core Hyprland window manager
    ./hyprland.nix

    # Desktop components
    ./waybar
    ./hyprlock
    ./hypridle
    ./swaync

    # Walker v2 launcher (Elephant backend)
    inputs.walker.homeManagerModules.default
    ./walker
  ];

  # Cursor theme (catppuccin mocha dark)
  home.pointerCursor = {
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
