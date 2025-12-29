# Feature Specification: Complete NixOS Host Configurations

**Feature Branch**: `001-nixos-hosts`
**Created**: 2025-12-17
**Status**: Draft
**Input**: User description: "finish adding all my nixos hosts (big computer that has dual boot to windows and nixos) and then the rk1 chips"

## Clarifications

### Session 2025-12-17

- Q: What is the current deployment status of each host? → A: Ganon and RK1 nodes already have NixOS installed; GLaDOS needs fresh deployment
- Q: Should GLaDOS be included in scope? → A: Yes, add GLaDOS to complete all NixOS hosts
- Q: What OS is currently on GLaDOS? → A: Windows 11 (full wipe OK)
- Q: What is the primary focus? → A: Secrets management (sops-nix/age) working correctly + SSH access to all hosts; remote install is secondary
- Q: How should user age keys work? → A: Derive from user SSH key (same pattern as host age keys) - user SSH key in secrets.yaml → extract → ssh-to-age → user age key
- Q: Darwin host age keys? → A: Darwin doesn't have host-level SSH keys; use michael's user SSH key (already `&michael` in .sops.yaml) for Darwin decryption
- Q: RK1 nodes status? → A: All 4 running NixOS but have insecure passwords and wrong host keys (not from secrets)
- Q: Ganon status? → A: Already running NixOS, RTX 30 series GPU, own NVMe drive, GRUB bootloader (ugly, want systemd-boot)
- Q: GLaDOS model? → A: ThinkPad X1 Carbon Gen 8
- Q: GLaDOS disk layout? → A: Use Btrfs + LUKS (like EmergentMind pattern) for laptop security, WITHOUT impermanence (keep it simple for now)
- Q: GLaDOS hardware? → A: Standard ThinkPad + fingerprint reader; YubiKey support desired later

## Host Status Summary

| Host | Status | Current Issues | Target State |
|------|--------|---------------|--------------|
| **Ganon** | Running NixOS | GRUB bootloader, may need config alignment | systemd-boot, secrets working, SSH access |
| **RK1 (x4)** | Running NixOS | Insecure passwords, wrong host keys | Proper SSH keys from secrets, secure config |
| **GLaDOS** | Windows 11 | Not deployed | Fresh NixOS install with Btrfs+LUKS |

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Secrets Management for All Hosts (Priority: P1)

As the system administrator, I want sops-nix secrets to decrypt correctly on all hosts (NixOS and Darwin) so that sensitive configuration (SSH keys, passwords, API tokens) is available after deployment.

**Why this priority**: Without working secrets, hosts cannot authenticate users, access protected resources, or function in a production capacity. This is the foundation for everything else.

**Independent Test**: Can be verified by rebuilding any host and confirming secrets are decrypted at `/run/secrets/` and user age keys are available at `~/.config/sops/age/keys.txt`.

**Acceptance Scenarios**:

1. **Given** a NixOS host has its SSH host key, **When** the system activates, **Then** sops-nix derives the host age key and decrypts system secrets.
2. **Given** michael's SSH private key is in secrets.yaml, **When** system activation runs, **Then** the SSH key is extracted and `ssh-to-age` derives the user age key.
3. **Given** user age key is derived, **When** Home Manager activates, **Then** user-level secrets decrypt correctly.
4. **Given** a Darwin host, **When** the system activates, **Then** secrets decrypt using michael's user age key (no host SSH key needed).

---

### User Story 2 - SSH Access to All NixOS Hosts (Priority: P2)

As the system administrator, I want to SSH into all NixOS hosts (Ganon, GLaDOS, RK1 nodes) from my macOS machines so that I can manage and rebuild them remotely.

**Why this priority**: SSH access enables remote management, which is essential for headless RK1 nodes and convenient for desktop/laptop hosts.

**Independent Test**: Can be verified by running `ssh michael@<hostname>` from a Darwin host and getting a shell.

**Acceptance Scenarios**:

1. **Given** a NixOS host is running with sops secrets deployed, **When** I SSH using my key, **Then** I authenticate successfully without password.
2. **Given** SSH host keys are from secrets (pre-generated), **When** I connect, **Then** the host key matches what's in secrets (no regeneration on rebuild).
3. **Given** all 6 NixOS hosts are configured, **When** I run SSH to each hostname, **Then** all respond with working shells.

---

### User Story 3 - Fix RK1 Cluster Security (Priority: P3)

As the system administrator, I want to replace the insecure passwords and wrong host keys on the RK1 nodes with proper secrets-managed configuration.

**Why this priority**: RK1 nodes are currently insecure. They need proper SSH host keys from secrets and password authentication disabled.

**Independent Test**: Can be verified by rebuilding an RK1 node and confirming it uses the SSH host key from secrets.yaml.

**Acceptance Scenarios**:

1. **Given** RK1 node has insecure config, **When** I rebuild with updated config, **Then** SSH host key matches what's in nix-secrets.
2. **Given** secrets are deployed, **When** I try password SSH, **Then** it's rejected (key-only auth).
3. **Given** all 4 nodes are updated, **When** I SSH to each, **Then** host keys are stable across rebuilds.

---

### User Story 4 - Complete Host Configurations in Flake (Priority: P4)

As the system administrator, I want Ganon, GLaDOS, and all 4 RK1 nodes fully configured in the flake so that I can build and deploy any host from the repository.

**Why this priority**: Complete configurations enable reproducible deployments and consistent management across all hosts.

**Independent Test**: Can be verified by running `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` for each host.

**Acceptance Scenarios**:

1. **Given** host configuration exists in the flake, **When** I run `nix flake check`, **Then** all NixOS configurations evaluate without errors.
2. **Given** Ganon configuration is complete, **When** I rebuild, **Then** NVIDIA RTX 30 series drivers and systemd-boot work correctly.
3. **Given** RK1 node configurations exist, **When** I rebuild any node, **Then** ARM64/RK3588 settings are applied.
4. **Given** GLaDOS configuration is complete, **When** I deploy, **Then** ThinkPad X1 Carbon Gen 8 hardware works (WiFi, fingerprint, power management).

---

### User Story 5 - Deploy GLaDOS Laptop (Priority: P5)

As the system administrator, I want to deploy NixOS to GLaDOS (ThinkPad X1 Carbon Gen 8, currently Windows 11) so that all my Linux machines are managed through the same flake.

**Why this priority**: GLaDOS is the only host without NixOS. Deployment completes the full fleet.

**Independent Test**: Can be fully tested by booting GLaDOS into NixOS and verifying SSH + secrets work.

**Acceptance Scenarios**:

1. **Given** GLaDOS has Windows 11, **When** I deploy NixOS via USB boot, **Then** the laptop boots into NixOS with Btrfs+LUKS.
2. **Given** GLaDOS is running NixOS, **When** secrets activate, **Then** sops-nix decrypts secrets using the host's SSH key.
3. **Given** GLaDOS is deployed, **When** I SSH from a Darwin host, **Then** I get a working shell.

---

### Edge Cases

- What happens if SSH host key is regenerated on a host? (Must update age key in nix-secrets and rekey)
- What if nix-secrets repo is inaccessible during build? (Build fails - must ensure git access)
- How to bootstrap a new host that doesn't have its age key in nix-secrets yet? (Pre-generate SSH key, derive age key, add to .sops.yaml before first deploy)
- What happens if user SSH key changes? (Must update `&michael` in .sops.yaml and rekey)
- RK1 chicken-egg: How to deploy new host keys when current auth uses insecure password? (SSH in with password, deploy keys, then rebuild)

## Requirements *(mandatory)*

### Functional Requirements

**Secrets Architecture (Critical):**
- **FR-001**: Each NixOS host MUST derive its host age key from SSH host key (`/etc/ssh/ssh_host_ed25519_key`) using `ssh-to-age`.
- **FR-002**: User age key MUST be derived from user SSH key using the same `ssh-to-age` pattern (not a separate standalone age key).
- **FR-003**: Darwin hosts MUST use michael's user age key (`&michael` in .sops.yaml) for decryption since they lack host-level SSH keys.
- **FR-004**: nix-secrets `.sops.yaml` MUST contain: host age public keys for all NixOS hosts + michael's user age public key.
- **FR-005**: System activation MUST: extract user SSH private key from secrets → derive age key via `ssh-to-age -private-key` → place at `~/.config/sops/age/keys.txt`.

**Secrets Flow on NixOS:**
- **FR-006**: Host age key (from SSH host key) decrypts system secrets including `private_keys.michael`.
- **FR-007**: `private_keys.michael` (user SSH key) is extracted to `/run/secrets/`.
- **FR-008**: Activation script derives user age key from extracted SSH key and places at `~/.config/sops/age/keys.txt`.
- **FR-009**: Home Manager uses user age key to decrypt user-level secrets.

**SSH Host Key Management:**
- **FR-010**: SSH host keys for RK1 nodes MUST come from nix-secrets (already stored as `host_keys.rk1-node{1-4}`).
- **FR-011**: System MUST deploy SSH host keys from secrets to `/etc/ssh/` before SSH server starts.
- **FR-012**: SSH host key deployment MUST happen early in activation (before sops-nix needs them).

**SSH Access (Critical):**
- **FR-013**: All NixOS hosts MUST have SSH server enabled with ed25519 host keys.
- **FR-014**: User MUST be able to authenticate via SSH key (no password).
- **FR-015**: SSH authorized keys MUST be managed declaratively (michael's public key from secrets or flake).

**GLaDOS Bootstrap:**
- **FR-016**: Before first deploy, MUST generate SSH host key for GLaDOS.
- **FR-017**: MUST derive age public key from GLaDOS SSH key and add to `.sops.yaml`.
- **FR-018**: MUST rekey secrets.yaml so GLaDOS can decrypt.
- **FR-019**: Disk layout MUST use Btrfs + LUKS encryption (standard subvolumes: @root, @nix, @home, @swap - NO impermanence).

**Host-Specific - Ganon:**
- **FR-020**: NVIDIA RTX 30 series proprietary drivers with OpenGL 32-bit support.
- **FR-021**: Switch from GRUB to systemd-boot for cleaner dual-boot.
- **FR-022**: Maintain dual-boot with Windows (separate disk).
- **FR-023**: LUKS encryption on NixOS partition (already configured).

**Host-Specific - RK1 Cluster:**
- **FR-024**: All 4 nodes MUST use identical base configuration with hostname differentiation.
- **FR-025**: Nodes MUST use systemd-networkd for predictable network interface naming.
- **FR-026**: Nodes MUST include RK3588-specific kernel modules (already configured).
- **FR-027**: SSH host keys MUST be deployed from secrets (replacing current insecure setup).

**Host-Specific - GLaDOS:**
- **FR-028**: ThinkPad X1 Carbon Gen 8 hardware support via nixos-hardware.
- **FR-029**: Laptop settings: TLP power management, WiFi, display.
- **FR-030**: Fingerprint reader support (fprintd).
- **FR-031**: `isLaptop = true` hostSpec pattern.
- **FR-032**: YubiKey support (future enhancement, not blocking).

**All Hosts:**
- **FR-033**: All NixOS hosts MUST enable zram swap.
- **FR-034**: All NixOS hosts MUST use Btrfs filesystem with compression.
- **FR-035**: All NixOS hosts MUST import common NixOS module and sops module.

### Key Entities

- **Host Age Key**: Derived from SSH host key (`/etc/ssh/ssh_host_ed25519_key`) using `ssh-to-age`. Public key in `.sops.yaml`, private key auto-derived on host. Used for system-level secret decryption.
- **User Age Key**: Derived from user SSH key (`private_keys.michael`) using `ssh-to-age`. Public key is `&michael` in `.sops.yaml`. Private key derived at activation time. Used for user/Home Manager secret decryption.
- **nix-secrets Repository**: Private git repo containing `.sops.yaml` (lists who can decrypt) and `secrets.yaml` (encrypted secrets including SSH keys, passwords, API tokens, host SSH keys).
- **Host Configuration**: NixOS system definition in `hosts/nixos/<hostname>/` importing common modules and host-specific settings.
- **SSH Host Key (from secrets)**: Pre-generated ed25519 key pair stored in secrets.yaml under `host_keys.<hostname>`. Deployed to `/etc/ssh/` during activation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 6 NixOS hosts build successfully with `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- **SC-002**: System secrets decrypt to `/run/secrets/` on all NixOS hosts after rebuild.
- **SC-003**: User age key derived and available at `~/.config/sops/age/keys.txt` on all hosts.
- **SC-004**: SSH access works from Darwin hosts to all NixOS hosts without password.
- **SC-005**: `nix flake check` passes with zero errors for all configurations.
- **SC-006**: nix-secrets `.sops.yaml` contains age public keys for: ganon, glados, rk1-node{1-4}, and michael (user).
- **SC-007**: RK1 nodes use SSH host keys from secrets (verifiable via `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`).
- **SC-008**: Ganon boots with systemd-boot showing both NixOS and Windows options.
- **SC-009**: GLaDOS boots into NixOS with working WiFi, display, and fingerprint reader.

## Assumptions

- nix-secrets repository exists at `github.com/mcgilly17/nix-secrets` and is accessible.
- `ssh-to-age` tool is available in the Nix environment for key derivation.
- Ganon is currently running NixOS and accessible (can rebuild remotely or locally).
- RK1 nodes are accessible via SSH with current insecure password (for initial key deployment).
- GLaDOS requires fresh NixOS deployment via USB boot.
- Host SSH keys for RK1 nodes already exist in secrets.yaml (verified: `host_keys.rk1-node{1-4}`).
- Darwin hosts (bowser, sephiroth) work correctly with user-level age key decryption.
- nixos-hardware has ThinkPad X1 Carbon Gen 8 profile available.

## References

- [Secrets Management Guide](https://unmovedcentre.com/posts/secrets-management/) - sops-nix patterns, ssh-to-age workflow
- [Remote Install Guide](https://unmovedcentre.com/posts/remote-install-nixos-config/) - nixos-anywhere workflow, SSH key bootstrap
- [EmergentMind nix-config](https://github.com/EmergentMind/nix-config) - Reference architecture for multi-host secrets, Btrfs+LUKS disk layout
- [Khanelinix](https://github.com/khaneliman/khanelinix) - Reference for Btrfs disk configuration patterns
- nixos-hardware ThinkPad X1 Carbon Gen 8 profile
