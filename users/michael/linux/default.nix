{ inputs, ... }:
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
}
