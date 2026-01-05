# Base Linux desktop applications
{ pkgs, ... }:
{
  imports = [
    ./cli.nix # CLI tools (1password, etc.)
  ];

  home.packages = with pkgs; [
    # Browsers
    google-chrome
    firefox

    # Password manager GUI (CLI is in cli.nix)
    _1password-gui

    # Communication
    discord
    slack

    # Media
    spotify
    vlc
  ];
}
