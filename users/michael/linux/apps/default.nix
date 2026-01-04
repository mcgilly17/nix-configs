# Base Linux desktop applications
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Browsers
    google-chrome
    firefox

    # Password manager
    _1password-gui

    # Communication
    discord
    slack

    # Media
    spotify
    vlc
  ];
}
