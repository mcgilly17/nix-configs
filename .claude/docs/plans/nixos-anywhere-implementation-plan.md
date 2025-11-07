# NixOS-Anywhere Implementation Plan (Pre-Generated Keys Approach)

## Overview
Implement nixos-anywhere for remote installation using pre-generated SSH host keys and user age keys, simplifying deployment and eliminating dynamic key generation complexity.

### Target Systems
- **Ganon**: Gaming PC with dedicated NixOS drive (separate from Windows drive)
- **RK1 Cluster**: 4 identical compute modules (rk1-node1 through rk1-node4)

## Phase 1: Main Configuration Extensions

### 1.1 Update flake.nix
- Add x86_64-linux and aarch64-linux to forAllSystems (uncomment existing lines)
- Add disko input for declarative disk partitioning
- Add nixos-anywhere input
- Create nixosConfigurations section for NixOS hosts

### 1.2 Add NixOS modules support
- Create modules/nixos/ directory structure
- Add sops.nix module for system-level secrets (SSH host key derivation)
- Add common.nix for shared NixOS configuration
- Ensure isMinimal flag support for lightweight configs

## Phase 2: Installer Infrastructure

### 2.1 Create nixos-installer/
```
nixos-installer/
├── flake.nix                    # Minimal installer flake
├── minimal-configuration.nix    # Base config with isMinimal = true
└── (optional) iso/default.nix   # Custom ISO if needed
```

### 2.2 Minimal installer flake
- Limited inputs: nixpkgs, disko, parent flake
- Reference host configs from ../hosts/nixos/
- Include disko for disk partitioning
- Enable SSH and basic networking only

## Phase 3: Host Configurations

### 3.1 Ganon (Gaming PC) Setup
```
hosts/
├── common/
│   └── disks/
│       └── standard-btrfs.nix   # Standard btrfs layout (owns entire drive)
└── nixos/
    └── ganon/
        ├── configuration.nix     # Main config, imports from modules/
        └── hardware-configuration.nix
```

Key features:
- GRUB bootloader for dual-boot detection (separate drives)
- NVIDIA drivers and gaming optimizations
- Standard NixOS disk layout on dedicated drive
- LUKS encryption support
- System-level SOPS for secrets extraction

### 3.2 RK1 Cluster Nodes (Identical & Repeatable)
```
hosts/
├── common/
│   └── rk1-base.nix            # Shared configuration for all RK1 nodes
└── nixos/
    ├── rk1-node1/configuration.nix  # Only hostname differs
    ├── rk1-node2/configuration.nix  # Only hostname differs
    ├── rk1-node3/configuration.nix  # Only hostname differs
    └── rk1-node4/configuration.nix  # Only hostname differs
```

Individual node configs are minimal:
```nix
# rk1-node1/configuration.nix
{
  imports = [ ../../common/rk1-base.nix ];
  networking.hostName = "rk1-node1";
  # Any node-specific networking if needed
}
```

Shared rk1-base.nix features:
- isMinimal = true for lightweight cluster setup
- Rockchip-specific hardware configuration
- eMMC storage optimization
- Cluster networking for Turing Pi
- System-level SOPS for secrets

## Phase 4: SOPS/Age Integration

### 4.1 System-level secrets module (modules/nixos/sops.nix)
```nix
# System extracts user age keys from secrets.yaml
sops.secrets."user-age-keys/michael-${config.networking.hostName}" = {
  sopsFile = inputs.nix-secrets + "/secrets.yaml";
  path = "/run/secrets/user-age-key";
  mode = "0400";
  owner = config.users.users.michael.name;
};

# Activation script to place key for Home Manager
system.activationScripts.userAgeKey = ''
  mkdir -p /home/michael/.config/sops/age
  cp /run/secrets/user-age-key /home/michael/.config/sops/age/keys.txt
  chown -R michael:users /home/michael/.config/sops/age
  chmod 600 /home/michael/.config/sops/age/keys.txt
'';
```

### 4.2 Pre-generated keys workflow
Since you have host keys already:
1. Convert SSH host public keys to age format
2. Generate unique user age keys per host (ganon + 4 RK1 nodes)
3. Update nix-secrets repo with all keys
4. Re-encrypt secrets before any deployment

## Phase 5: Deployment Scripts

### 5.1 Simplified bootstrap script (scripts/bootstrap-nixos.sh)
```bash
# Much simpler than tutorial version since keys are pre-generated
function nixos_anywhere() {
  # Copy pre-generated SSH host keys to temp directory
  install -d -m755 "$temp/etc/ssh"
  cp "keys/${target_hostname}_ssh_host_ed25519_key" "$temp/etc/ssh/ssh_host_ed25519_key"
  chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

  # Deploy with nixos-anywhere
  SHELL=/bin/sh nix run github:nix-community/nixos-anywhere -- \
    --ssh-port "$ssh_port" \
    --extra-files "$temp" \
    --flake ./nixos-installer#"$target_hostname" \
    root@"$target_destination"
}
```

### 5.2 Full deployment script
```bash
# After nixos-anywhere completes, immediately deploy full config
nixos-rebuild switch --flake .#"$target_hostname" --target-host root@"$target_destination"
```

## Phase 6: Directory Structure (Final)

```
dots/
├── flake.nix (extended for NixOS)
├── nixos-installer/
│   ├── flake.nix
│   └── minimal-configuration.nix
├── hosts/
│   ├── common/
│   │   ├── disks/standard-btrfs.nix
│   │   └── rk1-base.nix
│   └── nixos/
│       ├── ganon/
│       └── rk1-node{1-4}/
├── modules/
│   ├── nixos/
│   │   ├── sops.nix
│   │   └── common.nix
│   └── (existing darwin/ and common/)
├── scripts/
│   ├── bootstrap-nixos.sh
│   └── helpers.sh
└── keys/ (temp directory for pre-generated SSH host keys)
```

## Phase 7: Ganon Specific Configuration

### 7.1 Standard disk configuration (no Windows partition concerns)
```nix
# hosts/common/disks/standard-btrfs.nix
{
  disko.devices = {
    disk.main = {
      device = "/dev/nvme0n1";  # Ganon's dedicated NixOS drive
      content.type = "gpt";
      content.partitions = {
        ESP = {
          # Standard EFI System Partition
        };
        root = {
          # LUKS-encrypted btrfs with subvolumes
          # @root, @nix, @home, @swap subvolumes
        };
      };
    };
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    os-prober.enable = true;  # Detect Windows on other drive
  };
}
```

## Phase 8: RK1 Cluster Deployment

### 8.1 Batch deployment
```bash
# Deploy Ganon first
./scripts/bootstrap-nixos.sh -n ganon -d 192.168.1.100 -k ~/.ssh/id_ed25519

# Deploy all RK1 nodes in sequence
for i in {1..4}; do
  ./scripts/bootstrap-nixos.sh -n rk1-node$i -d 192.168.1.1$i -k ~/.ssh/id_ed25519
done
```

### 8.2 RK1-specific considerations
- isMinimal = true reduces package set for compute modules
- Handle Rockchip bootloader in disko configuration
- Optimize for eMMC storage and limited resources
- Configure for Turing Pi cluster networking
- Identical configuration across all nodes for consistency

## Benefits of This Approach:
- **Predictable**: All keys pre-generated and tested
- **Faster**: No dynamic key generation during deployment
- **Simpler**: Bootstrap script focuses only on deployment
- **Reliable**: Keys are validated before any installation
- **Automatable**: Entire process can be scripted and repeated
- **Maintainable**: RK1 nodes share maximum code for consistency
- **Clean**: Ganon gets dedicated drive without Windows partition complexity