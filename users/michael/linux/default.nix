{ inputs, ... }:
{
  imports = [
    ./hyprland.nix
    # Walker v2 launcher (Elephant backend)
    inputs.walker.homeManagerModules.default
  ];
}
