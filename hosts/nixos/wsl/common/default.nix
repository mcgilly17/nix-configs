# WSL Common Configuration
# Shared across all WSL hosts (Ocelot, Mantis)
{ lib, pkgs, ... }:

let
  # 1Password CLI wrapper for WSL
  # Redirects to Windows 1Password for biometric auth support
  # https://github.com/Swage590/1Password-CLI-WSL-Integration
  op-wsl = pkgs.writeShellScriptBin "op" ''
    # Find base folder for 1Password CLI in current user's Windows WinGet Packages
    WIN_OP_BASE="/mnt/c/Users/$(cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r')/AppData/Local/Microsoft/WinGet/Packages"

    # Find the latest folder matching the pattern (AgileBits.1Password.CLI*)
    OP_DIR=$(ls -td "$WIN_OP_BASE"/AgileBits.1Password.CLI* 2>/dev/null | head -n1)

    if [ -z "$OP_DIR" ]; then
        echo "[ERROR] Could not find 1Password CLI folder in $WIN_OP_BASE" >&2
        exit 1
    fi

    mapfile -d "" op_env_vars < <(env -0 | grep -z ^OP_ | cut -z -d= -f1)
    export WSLENV="''${WSLENV:-}:$(IFS=:; echo "''${op_env_vars[*]}")"
    exec "$OP_DIR/op.exe" "$@"
  '';
in
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
    # 1Password CLI wrapper (uses Windows 1Password)
    op-wsl

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
