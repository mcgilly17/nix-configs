# Base Linux desktop applications
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Browsers
    google-chrome
    firefox

    # 1Password GUI/CLI enabled via NixOS modules in modules/nixos/common.nix

    # Communication
    discord
    slack

    # Media
    spotify
    vlc
  ];
}
