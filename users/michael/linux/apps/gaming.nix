# Gaming applications for Linux
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Game launchers
    steam
    lutris
    heroic # Epic Games / GOG launcher

    # Game utilities
    mangohud # FPS overlay
    gamemode # Feral GameMode for optimization
    protonup-qt # Proton-GE installer
  ];
}
