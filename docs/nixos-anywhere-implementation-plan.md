# NixOS-Anywhere Implementation Plan

## Overview
Implementation of nixos-anywhere for remote NixOS installation to gaming PC (Ganon) and RK1 cluster nodes on Turing Pi 2.

## Architecture Decisions

### Key Decisions Made
- **Secrets Management**: SOPS/age with SSH host key derivation
- **Key Strategy**: Pre-generate SSH host keys and user age keys (not dynamic)
- **Configuration Philosophy**: Keep host configs minimal (system-level only)
- **Module Pattern**: Use host-spec pattern for configuration flags (isMinimal, isServer, etc.)
- **Boot Method**: UEFI/systemd-boot for all systems (including RK1)
- **Shared Configs**: Base configurations contain common settings
- **User Management**: Same michael user everywhere, conditional features via isMinimal

### Host Architecture
- **Ganon**: x86_64 gaming PC with NVIDIA, dual-boot Windows (separate drive)
- **RK1 Nodes 1-4**: ARM64 Rockchip RK3588 on Turing Pi 2, minimal cluster nodes

## Implementation Progress

### ✅ Phase 1: Infrastructure Setup (COMPLETED)
- [x] Extended flake.nix with Linux architectures (x86_64-linux, aarch64-linux)
- [x] Added disko and nixos-anywhere inputs to flake
- [x] Created nixosConfigurations for all 5 hosts
- [x] Changed formatter from alejandra to nixfmt-rfc-style
- [x] Maintained existing Darwin configurations

### ✅ Phase 2.1: Module Structure (COMPLETED)
- [x] Created `modules/nixos/common.nix` with Home Manager integration
- [x] Created `modules/nixos/sops.nix` for secrets management
- [x] Created `modules/common/host-spec.nix` for configuration flags
- [x] Updated `modules/common/core.nix` with:
  - nh program for better Nix tooling
  - Enhanced sudo configuration
  - zramSwap for memory efficiency
  - SOPS/age tools

### ✅ Phase 2.2: System Improvements (COMPLETED)
- [x] Set correct timezone (America/Los_Angeles)
- [x] Set correct keyboard layout (US)
- [x] Added system-level zsh configuration
- [x] Enabled NetworkManager for connectivity
- [x] Configured SSH for nixos-anywhere deployment

### ✅ Phase 2.3: Host Configurations (COMPLETED)

#### Ganon (Gaming PC)
- [x] Minimal hardware-specific configuration
- [x] NVIDIA drivers and settings
- [x] OpenGL support
- [x] Gamemode for performance
- [x] hostSpec: `isGaming = true`

#### RK1 Base Configuration
- [x] Research-backed configuration for RK3588
- [x] UEFI/systemd-boot setup
- [x] ARM64-specific kernel parameters
- [x] Network optimization via systemd-networkd
- [x] Power management with TLP
- [x] Performance tuning for cluster workloads
- [x] hostSpec: `isMinimal = true, isServer = true, isClusterNode = true`

#### RK1 Nodes 1-4
- [x] Minimal individual configurations
- [x] Only contain hostname
- [x] Inherit everything from rk1-base

### 📍 Phase 2.5: Disko Configurations (IN PROGRESS)
- [ ] Create `common/disks/ganon-disk.nix` - GRUB dual-boot setup
- [ ] Create `common/disks/rk1-disk.nix` - Simple eMMC layout

### 🔜 Phase 2.6: NixOS-Installer Flake
- [ ] Create minimal installer flake
- [ ] Configure for bootstrap deployment
- [ ] Include essential tools

### 🔜 Phase 2.7: Build Testing
- [ ] Test Ganon configuration builds
- [ ] Test RK1 configurations build
- [ ] Verify all imports resolve

## Phase 3: Secrets Management Setup
- [ ] Generate SSH host keys for all 5 hosts
- [ ] Generate user age keys (michael@hostname format)
- [ ] Update nix-secrets repository
- [ ] Configure SOPS rules
- [ ] Test secret decryption

## Phase 4: Deployment Scripts
- [ ] Create deployment wrapper script
- [ ] Add host-specific deployment commands
- [ ] Configure nixos-anywhere options
- [ ] Add rollback procedures

## Phase 5: Testing & Documentation
- [ ] Deploy to test VM first
- [ ] Deploy to Ganon
- [ ] Deploy to RK1 nodes
- [ ] Document deployment process
- [ ] Create troubleshooting guide

## Technical Details

### Module Hierarchy
```
flake.nix
├── nixosConfigurations
│   ├── ganon → hosts/nixos/ganon
│   └── rk1-node[1-4] → hosts/nixos/rk1-node[1-4]
│
modules/
├── common/
│   ├── core.nix (cross-platform base)
│   └── host-spec.nix (configuration flags)
└── nixos/
    ├── common.nix (NixOS base + Home Manager)
    └── sops.nix (secrets management)

hosts/
├── common/
│   └── rk1-base.nix (shared RK1 config)
└── nixos/
    ├── ganon/configuration.nix
    └── rk1-node[1-4]/configuration.nix
```

### Host Specifications
- **hostSpec.isMinimal**: Reduces packages for resource-constrained hosts
- **hostSpec.isServer**: Server-specific configurations
- **hostSpec.isGaming**: Gaming-specific hardware/software
- **hostSpec.isClusterNode**: Cluster-specific networking/services

### Network Architecture
- **Ganon**: Standard NetworkManager
- **RK1 Nodes**: systemd-networkd for predictable naming

### Secrets Flow
1. System boots with SSH host key
2. SOPS uses host key to decrypt user age key
3. User age key copied to ~/.config/sops/age/keys.txt
4. Home Manager can decrypt user secrets

## Commands Reference

### Build Testing
```bash
# Test individual host builds
nix build .#nixosConfigurations.ganon.config.system.build.toplevel
nix build .#nixosConfigurations.rk1-node1.config.system.build.toplevel

# Check flake
nix flake check
```

### Deployment (after secrets setup)
```bash
# Deploy to Ganon
nixos-anywhere --flake .#ganon root@ganon-ip

# Deploy to RK1 nodes
nixos-anywhere --flake .#rk1-node1 root@rk1-node1-ip
```

## Notes
- RK1 configuration based on gnull/nixos-rk3588 research
- UEFI firmware required for RK1 NVMe support
- Gamemode stays system-level (needs kernel capabilities)
- All application-level configs go in Home Manager