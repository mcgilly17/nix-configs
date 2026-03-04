# RK1 Disk Configuration
# Shared disk layout for all RK1 nodes
#
# Root: Pre-flashed SD image on eMMC (not managed by disko)
# NVMe: btrfs local storage + reserved Longhorn partition (cluster nodes only)
#
# Cluster nodes (zenith-1, zenith-2, zenith-3):
#   /dev/nvme0n1p1 - 200G  ext4  → /var/lib/longhorn (reserved for future use)
#   /dev/nvme0n1p2 - rest  btrfs → /data (zstd compressed)
#
# Dev server (sephiroth):
#   /dev/nvme0n1p1 - 100%  btrfs → /nix (zstd compressed, offload from eMMC)
#                                   /data (zstd compressed)
{ config, lib, ... }:

{
  # Root filesystem - matches the flashed nixos-rk1 SD image (MBR + ext4)
  # Not managed by disko since the image is pre-flashed
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  # NVMe storage via disko
  # Deploy only after NVMe drives are physically installed
  disko.devices.disk.nvme = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions =
        # Cluster nodes get a reserved Longhorn partition (200G)
        lib.optionalAttrs config.hostSpec.isClusterNode {
          longhorn = {
            size = "200G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/var/lib/longhorn";
              mountOptions = [ "noatime" ];
            };
          };
        }
        // {
          # Local storage (takes remaining space)
          local = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/data" = {
                  mountpoint = "/data";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              }
              // lib.optionalAttrs (!config.hostSpec.isClusterNode) {
                # Dev servers: offload /nix to NVMe (eMMC is too small)
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
    };
  };
}
