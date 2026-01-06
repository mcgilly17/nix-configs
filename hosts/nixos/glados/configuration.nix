# GLaDOS - Linux Laptop Configuration
# ThinkPad X1 Carbon - x86_64-linux
{
  inputs,
  ...
}:

{
  imports = [
    # Hardware & Disk
    # ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
    ./disks.nix

    # NixOS system modules
    ../../../modules/nixos/common.nix
    ../../../modules/nixos/apps/desktop.nix
    ../../../modules/nixos/sops.nix

    # User configs
    ../../../users/michael
  ];

  # Host specification
  hostSpec = {
    hostName = "glados";
    isLaptop = true;
  };

  # Set hostname
  networking.hostName = "glados";

  system.stateVersion = "24.05";
}
