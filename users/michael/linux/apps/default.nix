# Base Linux desktop applications
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Browsers
    google-chrome
    firefox

    # Password manager GUI (CLI via shell-plugins in common/tui)
    _1password-gui

    # Communication
    discord
    slack

    # Media
    spotify
    vlc
  ];
}
