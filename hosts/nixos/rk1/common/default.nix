# RK1 Base Configuration - Shared across all RK1 nodes
# ARM64 Rockchip RK3588 compute modules for Turing Pi 2 cluster
# Based on research from gnull/nixos-rk3588 and community best practices
{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Hardware & Disk
    inputs.disko.nixosModules.disko

    # NixOS system modules
    ../../../../modules/nixos/common.nix
    ../../../../modules/nixos/sops.nix

    # User configs (minimal - see users/michael/hosts/rk1-node*.nix)
    ../../../../users/michael
  ];

  # Host specification for all RK1 nodes
  hostSpec = {
    isMinimal = true;
    isServer = true;
    isClusterNode = true;
  };

  # RK3588-specific kernel and hardware configuration
  boot = {
    # U-Boot/extlinux bootloader (standard for RK3588 ARM64)
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    # Use latest kernel for best RK3588 support
    kernelPackages = pkgs.linuxPackages_latest;

    # RK3588 optimization parameters
    kernelParams = [
      "cma=128M" # Contiguous memory allocation for ARM64
      "coherent_pool=1M" # DMA coherent pool
      "systemd.unified_cgroup_hierarchy=0" # cgroup v1 for compatibility
    ];

    # Initrd modules (from mcgilly17/nixos-rk1)
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "mmc_block"
      "nvme"
      "ahci"
      # Note: sdhci_of_dwcmshc is built-in (=y) in latest kernel
    ];

    # Runtime kernel modules for RK3588 hardware
    kernelModules = [
      "rockchipdrm"
      "rockchip_thermal"
      "rockchip_saradc"
      "panfrost"
      "fusb302"
      "nvme"
    ];

    # File system support
    supportedFilesystems = [
      "ext4"
      "btrfs"
      "vfat"
    ];

    # Performance optimizations for ARM64 cluster nodes
    kernel.sysctl = {
      # Memory management tuning
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;

      # Network performance tuning
      "net.core.rmem_max" = 134217728;
      "net.core.wmem_max" = 134217728;
      "net.core.netdev_max_backlog" = 5000;

      # File system performance
      "fs.file-max" = 65536;
    };
  };

  # Hardware configuration for RK3588
  hardware = {
    # ARM64 redistributable firmware
    enableRedistributableFirmware = true;
    # Enable device tree support
    deviceTree.enable = true;
  };

  # Stable networking configuration for cluster deployment
  networking = {
    # Disable legacy DHCP to use systemd-networkd
    useDHCP = false;

    # Enable systemd-networkd for predictable interface naming
    useNetworkd = true;

    # Basic firewall (cluster-specific ports can be added per-node)
    firewall.enable = true;

    # Use systemd-networkd instead of NetworkManager (lighter for headless cluster)
    networkmanager.enable = lib.mkForce false;
  };

  # systemd-networkd configuration for DHCP
  systemd.network = {
    enable = true;
    networks."10-ethernet" = {
      matchConfig.Name = "en*";
      networkConfig = {
        DHCP = "ipv4";
        IPv4Forwarding = true; # Enable for cluster networking
        IPv6Forwarding = true;
      };
      dhcpV4Config = {
        UseDNS = true;
        UseRoutes = true;
      };
    };
  };

  # Services configuration
  services = {
    # Enable resolved for DNS
    resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "true";
        Domains = [ "~." ];
        FallbackDNS = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };

    # Essential for remote management
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes"; # For nixos-anywhere deployment
        PasswordAuthentication = false;
      };
    };

    # File system trim for eMMC longevity
    fstrim.enable = true;
  };

  # Power management for cluster stability
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Disable USB autosuspend for cluster stability
      USB_AUTOSUSPEND = 0;

      # PCIe power management
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  # Disable conflicting power management services
  services.power-profiles-daemon.enable = false;

  # iSCSI initiator for Longhorn storage support
  services.openiscsi = {
    enable = true;
    name = "iqn.2025-01.com.turingpi:rk1";
  };

  # Temperature monitoring - Industrial I/O sensors
  hardware.sensor.iio.enable = true;

  # Container support for K3s
  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;

  # Disable unnecessary services to reduce resource usage
  services.udisks2.enable = false;
  documentation.enable = false;
  documentation.nixos.enable = false;

  # Essential system packages (from mcgilly17/nixos-rk1 + extras)
  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    iotop
    lm_sensors

    # Network debugging
    ethtool
    tcpdump
    iperf3

    # Hardware information
    pciutils
    usbutils

    # Storage tools
    hdparm
    smartmontools
    nvme-cli
    nfs-utils

    # File system tools
    e2fsprogs
    btrfs-progs

    # Testing
    stress-ng
  ];

  # Enable zram for memory efficiency in cluster nodes
  zramSwap = {
    enable = true;
    memoryPercent = 25; # Use 25% of RAM for compressed swap
  };

  system.stateVersion = "24.05";
}
