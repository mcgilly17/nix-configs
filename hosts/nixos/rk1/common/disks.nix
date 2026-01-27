# RK1 Disk Configuration
# Shared disk layout for all RK1 cluster nodes
#
# Root filesystem: Simple ext4 matching the nixos-rk1 SD image layout
# NVMe (future): LUKS-encrypted data drive via disko
_:

{
  # Root filesystem - matches the flashed nixos-rk1 SD image (MBR + ext4)
  # This is NOT managed by disko since the image is pre-flashed
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ]; # Reduce wear on eMMC
  };

  # Disable disko for root - we use the pre-flashed SD image layout
  # Disko would try to reformat which we don't want

  # NVMe LUKS Configuration (commented out until NVMe is installed)
  # Uncomment and configure when adding NVMe storage
  #
  # disko.devices = {
  #   disk = {
  #     nvme = {
  #       type = "disk";
  #       device = "/dev/nvme0n1";
  #       content = {
  #         type = "gpt";
  #         partitions = {
  #           luks = {
  #             size = "100%";
  #             content = {
  #               type = "luks";
  #               name = "cryptdata";
  #               # Password will be prompted on boot, or use:
  #               # passwordFile = "/tmp/disk-password"; # For nixos-anywhere
  #               settings = {
  #                 allowDiscards = true; # Enable TRIM for SSD
  #               };
  #               content = {
  #                 type = "btrfs";
  #                 extraArgs = [ "-f" ];
  #                 subvolumes = {
  #                   "/data" = {
  #                     mountpoint = "/data";
  #                     mountOptions = [ "compress=zstd" "noatime" ];
  #                   };
  #                 };
  #               };
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # };
}
