# WSL2 Base Configuration Module
# Configures NixOS for Windows Subsystem for Linux 2
{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl = {
    enable = true;
    defaultUser = "michael";
    # Use native systemd (WSL2 feature)
    nativeSystemd = true;
    # Enable Windows interop (access to Windows executables)
    interop = {
      register = true;
      includePath = true;
    };
    # Mount Windows drives
    wslConf = {
      automount = {
        enabled = true;
        root = "/mnt";
        options = "metadata,umask=22,fmask=11";
      };
      network = {
        generateHosts = true;
        generateResolvConf = true;
      };
    };
  };

  # Disable services incompatible with WSL2
  services.xserver.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce false;

  # WSL handles networking
  networking.useDHCP = lib.mkDefault false;

  # Fix MTU for Tailscale compatibility
  # WSL2 defaults to 1280 which breaks large packets over Tailscale
  # See: https://github.com/tailscale/tailscale/issues/4833
  systemd.services.wsl-mtu-fix = {
    description = "Set eth0 MTU to 1500 for Tailscale compatibility";
    after = [ "network.target" ];
    before = [ "tailscaled.service" ];
    wantedBy = [ "tailscaled.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip link set dev eth0 mtu 1500";
    };
  };

  # Optimize boot for WSL (no bootloader needed)
  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = false;
    };
    # WSL-specific kernel modules
    initrd.availableKernelModules = [ ];
    kernelModules = [ ];
  };
}
