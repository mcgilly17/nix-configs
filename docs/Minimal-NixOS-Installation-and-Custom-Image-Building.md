# Minimal NixOS Installation and Custom Image Building

A comprehensive guide to building custom NixOS images for different platforms, with specific focus on RK1 compute modules and cloud deployments.

## Table of Contents

1. [Custom Image Building Strategy](#custom-image-building-strategy)
2. [Multi-Platform Image Building](#multi-platform-image-building)
3. [RK1-Specific Considerations](#rk1-specific-considerations)
4. [Cloud Provider Deployment](#cloud-provider-deployment)
5. [Configuration Integration](#configuration-integration)
6. [Examples and Templates](#examples-and-templates)

## Custom Image Building Strategy

### When to Use Custom Images vs Remote Deployment

**Custom Images (Recommended for):**
- Immutable infrastructure deployments
- Compute clusters with identical configurations
- Air-gapped or restricted environments
- Rapid scaling scenarios
- Hardware with specific bootloader requirements (RK1, embedded systems)
- Cloud deployments requiring pre-configured secrets/SSH keys

**Remote Deployment (Better for):**
- Development environments
- Frequently changing configurations
- Single-node deployments
- Interactive configuration management

### Image Building Workflow

```bash
# 1. Define system configuration
# flake.nix + configuration.nix

# 2. Build the image
nix build .#image

# 3. Flash/deploy the image
# Hardware: dd/tpi flash
# Cloud: upload as AMI/custom image

# 4. Boot and minimal post-deployment config
```

### Security Considerations for Pre-configured Images

**Best Practices:**
- Use temporary passwords that must be changed on first login
- Pre-configure SSH keys for automated access
- Avoid hardcoded secrets in image builds
- Use separate deployment keys vs production keys
- Enable fail2ban and basic security hardening
- Consider image signing for production deployments

**Security Trade-offs:**
- Convenience vs security (pre-configured vs runtime configuration)
- Image size vs attack surface
- Network exposure during initial boot

## Multi-Platform Image Building

### Architecture Support Matrix

| Platform | Architecture | Build System | Deployment Method |
|----------|-------------|--------------|-------------------|
| RK1 Compute | aarch64-linux | Cross/Native | eMMC flash via Turing Pi |
| AWS EC2 | x86_64-linux | Cross/Native | AMI upload |
| GCP Compute | x86_64-linux | Cross/Native | Custom image upload |
| Generic ARM64 | aarch64-linux | Cross/Native | SD card/USB |
| Generic x86_64 | x86_64-linux | Native | ISO/USB |

### Cross-compilation Setup

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    # Define target architectures
    targets = {
      rk1 = "aarch64-linux";
      aws = "x86_64-linux";
      gcp = "x86_64-linux";
    };

    # Support building from multiple host systems
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  in
  {
    # Generate configurations for each target
    nixosConfigurations = builtins.mapAttrs (name: system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configurations/${name}.nix
          ./common.nix
        ];
      }
    ) targets;

    packages = nixpkgs.lib.genAttrs supportedSystems (buildSystem:
      builtins.mapAttrs (name: config:
        config.config.system.build.${
          if name == "rk1" then "sdImage"
          else if builtins.elem name ["aws" "gcp"] then "amazonImage"
          else "isoImage"
        }
      ) self.nixosConfigurations
    );
  };
}
```

### Building for Different Architectures

```bash
# Native ARM64 build (fastest for ARM targets)
nix build .#rk1

# Cross-compilation from x86_64
nix build .#rk1 --system x86_64-linux

# Emulated build (slowest but works everywhere)
nix build .#rk1 --extra-platforms aarch64-linux
```

## RK1-Specific Considerations

### Rockchip Bootloader Requirements

The RK3588 SoC requires a specific bootloader sequence that standard NixOS ARM images don't provide. The RK1 uses:

1. **BootROM** (hardware) → **SPL** (sector 64+) → **U-Boot** → **Linux**
2. Rockchip signature verification (RKNS) at sector 64
3. Custom partition layout for eMMC optimization

### Hardware Driver Integration

```nix
# configuration.nix for RK1
{ config, pkgs, lib, ... }:
{
  # Latest kernel for RK3588 support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # RK3588-specific kernel modules
  boot.kernelModules = [
    "rockchipdrm"        # Display/DRM support
    "rockchip_thermal"   # Thermal management
    "rockchip_saradc"    # ADC support
    "panfrost"          # Mali GPU driver
    "fusb302"           # USB-C controller
  ];

  # Storage controllers for RK3588
  boot.initrd.availableKernelModules = [
    "sdhci_of_dwcmshc"  # eMMC controller
    "nvme"              # NVMe support
    "ahci"              # SATA controller
  ];

  # eMMC optimization
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" "discard" ];  # Reduce eMMC wear
  };

  # Hardware monitoring
  hardware.sensor.iio.enable = true;

  # Container support for K3s clusters
  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;
}
```

### Bootloader Injection Process

```nix
# flake.nix - Automatic bootloader injection
{
  nixosConfigurations.rk1 = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      ./configuration.nix
      {
        sdImage = {
          image.baseName = "nixos-rk1";
          expandOnBoot = true;

          # Inject extracted Rockchip bootloader
          postBuildCommands = ''
            echo "Installing RK1 bootloader..."

            # Copy bootloader to sector 64 (where RK3588 ROM expects it)
            dd if=${./rk1-bootloader-minimal.bin} of=$img conv=notrunc seek=64 bs=512

            # Verify RKNS signature
            if hexdump -C -s 32768 -n 16 $img | grep -q "52 4b 4e 53"; then
              echo "✅ RKNS signature verified"
            else
              echo "❌ Bootloader injection failed"
              exit 1
            fi
          '';
        };
      }
    ];
  };
}
```

### Compute Module Deployment via Turing Pi

```bash
# Flash image to specific RK1 slot
tpi flash -n 1 -i result/sd-image/nixos-rk1-aarch64-linux.img

# Power management
tpi power on --node 1
tpi power off --node 1

# Serial console access
tpi uart --node 1

# Network boot alternative (for development)
tpi netboot --node 1 --image nixos-rk1.img
```

### Cluster Deployment Strategies

**Option 1: Identical Images**
```bash
# Build once, flash to all nodes
for node in {1..4}; do
  tpi flash -n $node -i nixos-rk1.img
  tpi power on --node $node
done

# Post-deployment: Set unique hostnames
ssh root@192.168.1.10 "hostnamectl set-hostname rk1-node1"
ssh root@192.168.1.11 "hostnamectl set-hostname rk1-node2"
# ... etc
```

**Option 2: Node-Specific Images**
```nix
# Generate per-node configurations
nixosConfigurations = builtins.listToAttrs (map (n: {
  name = "rk1-node${toString n}";
  value = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [
      ./rk1-base.nix
      { networking.hostName = "rk1-node${toString n}"; }
    ];
  };
}) (nixpkgs.lib.range 1 4));
```

## Cloud Provider Deployment

### AWS EC2 AMI Creation

```nix
# aws-configuration.nix
{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
  ];

  # AWS-specific optimizations
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "nvme" "xen_blkfront" ];

  # Enhanced networking
  networking.usePredictableInterfaceNames = false;

  # CloudWatch agent
  services.amazon-ssm-agent.enable = true;

  # Instance metadata service v2
  services.cloud-init.enable = true;

  # Your base configuration
  imports = [ ./common.nix ];
}
```

```bash
# Build AMI
nix build .#aws

# Upload to AWS (using custom script or terraform)
aws ec2 import-image --description "NixOS Custom AMI" \
  --disk-containers "Format=raw,UserBucket={S3Bucket=my-images,S3Key=nixos-aws.raw}"
```

### GCP Custom Images

```nix
# gcp-configuration.nix
{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
  ];

  # GCP guest agent
  services.google-guest-agent.enable = true;

  # Preemptible instance handling
  services.google-shutdown-scripts.enable = true;

  # Your base configuration
  imports = [ ./common.nix ];
}
```

```bash
# Build GCP image
nix build .#gcp

# Upload to GCP
gcloud compute images create nixos-custom \
  --source-uri gs://my-bucket/nixos-gcp.tar.gz \
  --guest-os-features GVNIC,UEFI_COMPATIBLE
```

### Generic Server Deployment

```nix
# server-configuration.nix - Generic x86_64 server
{ config, pkgs, ... }:
{
  # UEFI boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Generic hardware support
  boot.initrd.availableKernelModules = [
    "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk"
    "nvme" "usb_storage" "sd_mod"
  ];

  # Network configuration
  networking.useDHCP = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Your base configuration
  imports = [ ./common.nix ];
}
```

## Configuration Integration

### Integrating Personal Dots Configuration

```nix
# flake.nix - Integrate with your dots
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dots.url = "path:../dots";  # Your dots flake
  };

  outputs = { self, nixpkgs, dots }:
  {
    nixosConfigurations.customImage = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./base-image.nix
        dots.nixosModules.default
        {
          # Override image-specific settings
          users.users.michael.initialPassword = "changeme";
          services.openssh.settings.PasswordAuthentication = true;
        }
      ];
    };
  };
}
```

### Secrets Management in Images

**Option 1: Age/sops-nix (Recommended)**
```nix
# secrets.nix
{ config, ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/keys.txt";

    secrets = {
      "ssh_host_ed25519_key" = {
        path = "/etc/ssh/ssh_host_ed25519_key";
        mode = "0400";
      };
      "wifi_password" = {
        path = "/run/secrets/wifi_password";
        mode = "0400";
      };
    };
  };
}
```

**Option 2: Deployment Keys**
```nix
# Temporary deployment keys (replace after first boot)
users.users.root.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3... deployment@builder"
];

# Post-deployment script to add real keys
system.activationScripts.setupRealKeys = ''
  # Download real authorized_keys from secure location
  # Remove deployment key
'';
```

### SSH Key Pre-configuration

```nix
# common.nix - SSH setup for images
{ config, pkgs, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";  # Key-only access
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Your SSH public keys
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... michael@macbook"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... michael@workstation"
  ];

  # Regenerate host keys on first boot (optional)
  system.activationScripts.regenerateSSHHostKeys = ''
    if [ ! -f /etc/ssh/.keys_generated ]; then
      rm -f /etc/ssh/ssh_host_*
      ${pkgs.openssh}/bin/ssh-keygen -A
      touch /etc/ssh/.keys_generated
    fi
  '';
}
```

## Examples and Templates

### RK1 Cluster Template

```bash
# Directory structure
rk1-cluster/
├── flake.nix
├── common.nix           # Shared configuration
├── rk1-base.nix        # RK1-specific hardware
├── rk1-bootloader.bin  # Extracted bootloader
├── nodes/
│   ├── node1.nix       # Node-specific configs
│   ├── node2.nix
│   └── ...
└── secrets/
    └── secrets.yaml
```

### Multi-Cloud Template

```bash
# Directory structure
multi-cloud-images/
├── flake.nix
├── common/
│   ├── base.nix        # Common configuration
│   ├── security.nix    # Security hardening
│   └── monitoring.nix  # Basic monitoring
├── platforms/
│   ├── aws.nix         # AWS-specific
│   ├── gcp.nix         # GCP-specific
│   ├── rk1.nix         # RK1-specific
│   └── generic.nix     # Generic server
└── deploy/
    ├── aws-deploy.sh   # AWS deployment script
    ├── gcp-deploy.sh   # GCP deployment script
    └── rk1-deploy.sh   # RK1 deployment script
```

### Build and Deployment Scripts

```bash
#!/bin/bash
# build-all-images.sh

set -e

echo "Building all platform images..."

# RK1 cluster nodes
for node in {1..4}; do
  echo "Building RK1 node $node..."
  nix build .#rk1-node$node
done

# Cloud images
echo "Building AWS AMI..."
nix build .#aws

echo "Building GCP image..."
nix build .#gcp

echo "All images built successfully!"
echo "Deploy with:"
echo "  RK1: ./deploy/rk1-deploy.sh"
echo "  AWS: ./deploy/aws-deploy.sh"
echo "  GCP: ./deploy/gcp-deploy.sh"
```

### Post-Deployment Configuration

```bash
#!/bin/bash
# post-deploy-rk1.sh

NODES=("192.168.1.10" "192.168.1.11" "192.168.1.12" "192.168.1.13")

for i in "${!NODES[@]}"; do
  node=$((i + 1))
  ip="${NODES[$i]}"

  echo "Configuring RK1 node $node at $ip..."

  # Set hostname
  ssh root@$ip "hostnamectl set-hostname rk1-node$node"

  # Update SSH keys (remove deployment key, add production keys)
  ssh root@$ip "curl -s https://github.com/yourusername.keys > ~/.ssh/authorized_keys"

  # Apply node-specific configuration
  ssh root@$ip "nixos-rebuild switch --flake github:yourusername/dots#rk1-node$node"

  echo "Node $node configured successfully"
done
```

This comprehensive guide provides the foundation for building custom NixOS images across different platforms, with particular expertise in RK1 compute modules and their unique bootloader requirements. The approach emphasizes security, reproducibility, and automated deployment workflows.