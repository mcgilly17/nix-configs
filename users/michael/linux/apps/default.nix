# Base Linux desktop applications
{ pkgs, ... }:
{
  # Syncthing file synchronization (runs as systemd user service)
  services.syncthing.enable = true;

  home.packages = with pkgs; [
    # Browsers
    google-chrome
    firefox

    # 1Password GUI/CLI enabled via NixOS modules in modules/nixos/common.nix

    # Communication
    discord
    slack

    # Productivity
    ticktick

    # Media
    spotify
    vlc
  ];
}
