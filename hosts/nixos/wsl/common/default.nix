# WSL Common Configuration
# Shared across all WSL hosts (Ocelot, Mantis)
{ lib, pkgs, ... }:

{
  imports = [
    # WSL-specific modules
    ../../../../modules/nixos/wsl.nix
    ../../../../modules/nixos/wsl-gpu.nix
    ../../../../modules/nixos/wsl-docker.nix

    # NixOS system modules
    ../../../../modules/nixos/common.nix
    ../../../../modules/nixos/sops.nix

    # User configs
    ../../../../users/michael
  ];

  # Default host specification for WSL hosts
  hostSpec = {
    isWSL = true;
    hasGPU = lib.mkDefault true;
  };

  # Development tools at system level
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gh

    # Editors
    neovim

    # Build tools
    gnumake
    cmake
    gcc

    # Python (for AI/ML development)
    python3
    python3Packages.pip
    python3Packages.virtualenv

    # Node.js
    nodejs

    # Terminal support for SSH from Windows Terminal
    kitty.terminfo
    alacritty.terminfo

    # System utilities
    htop
    btop
    tree
    unzip
    wget
    curl
    jq
  ];

  # Enable nix-ld for running unpatched binaries (common in WSL)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      curl
      libgcc
    ];
  };

  system.stateVersion = "24.05";
}
