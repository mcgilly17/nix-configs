# Implementation Plan: Complete NixOS Host Configurations

**Branch**: `001-nixos-hosts` | **Date**: 2025-12-17 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-nixos-hosts/spec.md`

## Summary

Complete all NixOS host configurations (Ganon, GLaDOS, RK1 x4) with working secrets management via sops-nix. Primary focus is establishing the secrets/SSH infrastructure so all hosts can be managed remotely from Darwin machines. GLaDOS requires fresh deployment; Ganon and RK1 nodes need configuration updates.

## Technical Context

**Language/Version**: Nix (nixpkgs unstable), NixOS 24.05
**Primary Dependencies**: sops-nix, home-manager, disko, nixos-hardware, ssh-to-age
**Storage**: Btrfs (all hosts), LUKS (Ganon, GLaDOS), eMMC (RK1)
**Testing**: `nix flake check`, `nix build .#nixosConfigurations.<host>...`, manual SSH verification
**Target Platform**: x86_64-linux (Ganon, GLaDOS), aarch64-linux (RK1 x4)
**Project Type**: Infrastructure/dotfiles - NixOS configurations
**Performance Goals**: N/A (infrastructure)
**Constraints**: RK1 nodes have limited storage (eMMC), GLaDOS needs USB boot for initial install
**Scale/Scope**: 6 NixOS hosts + 2 Darwin hosts, 1 user (michael)

## Constitution Check

*GATE: No project constitution defined. Proceeding with standard NixOS best practices.*

- ✅ Declarative configuration (Nix flakes)
- ✅ Secrets never in plain text in repo (sops-nix)
- ✅ Reproducible builds (flake.lock pins inputs)
- ✅ Modular structure (common modules shared across hosts)

## Project Structure

### Documentation (this feature)

```text
specs/001-nixos-hosts/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (repository root)

```text
# NixOS Dotfiles Structure
flake.nix                           # Main flake with all host definitions
flake.lock                          # Pinned dependencies

hosts/
├── bowser/                         # Darwin (macOS) host
├── sephiroth/                      # Darwin (macOS) host
└── nixos/
    ├── ganon/                      # Gaming PC (x86_64)
    │   ├── default.nix
    │   ├── configuration.nix
    │   └── disks.nix
    ├── glados/                     # Laptop (x86_64) - ThinkPad X1 Carbon Gen 8
    │   ├── default.nix
    │   ├── configuration.nix
    │   └── disks.nix
    └── rk1/                        # ARM64 cluster
        ├── common/
        │   ├── default.nix         # Shared base config
        │   └── disks.nix           # Shared disk layout
        └── node{1-4}/
            └── default.nix         # Per-node hostname

modules/
├── nixos/
│   ├── common.nix                  # Shared NixOS settings
│   └── sops.nix                    # Secrets management (NEEDS UPDATE)
└── darwin/
    └── sops.nix                    # Darwin secrets

users/
└── michael/                        # User configuration
    ├── common/                     # Shared across all systems
    └── darwin/                     # Darwin-specific

# External (private repo)
nix-secrets/                        # github.com/mcgilly17/nix-secrets
├── .sops.yaml                      # Key definitions
└── secrets.yaml                    # Encrypted secrets
```

**Structure Decision**: Existing dotfiles structure. Changes will be made to:
- `modules/nixos/sops.nix` - Update user age key derivation
- `hosts/nixos/*/` - Host-specific configurations
- `nix-secrets/` - Add GLaDOS keys, verify RK1 keys

## Implementation Phases

### Phase 1: Secrets Infrastructure (P1 - Critical Path)

**Goal**: Fix sops-nix to derive user age key from SSH key, deploy SSH host keys from secrets.

**Tasks**:
1. Update `modules/nixos/sops.nix`:
   - Change from expecting pre-made age key to deriving from SSH key
   - Extract `private_keys.michael` → `/run/secrets/michael-ssh-key`
   - Add activation script: `ssh-to-age -private-key < /run/secrets/michael-ssh-key > ~/.config/sops/age/keys.txt`

2. Create SSH host key deployment module:
   - For hosts with pre-generated keys in secrets (RK1 nodes)
   - Deploy to `/etc/ssh/ssh_host_ed25519_key{,.pub}` before sshd starts
   - Ensure correct permissions (600 for private, 644 for public)

3. Verify nix-secrets `.sops.yaml` has all required keys:
   - `&michael` (user age key from SSH)
   - `&ganon` (host age key)
   - `&rk1-node{1-4}` (host age keys)
   - Add `&glados` after generating its SSH key

**Verification**:
- `nix build .#nixosConfigurations.ganon.config.system.build.toplevel`
- Check `/run/secrets/` populated after rebuild
- Check `~/.config/sops/age/keys.txt` exists with valid age key

### Phase 2: RK1 Cluster Security Fix (P3)

**Goal**: Replace insecure passwords with secrets-managed SSH keys.

**Tasks**:
1. Update RK1 common config to deploy SSH host keys from secrets
2. Ensure password authentication is disabled
3. Add michael's public key to authorized_keys
4. Test on one node first (rk1-node1), then roll out to others

**Deployment Steps** (per node):
```bash
# From bowser, SSH with current insecure password
ssh root@rk1-node1

# On the node, pull latest config and rebuild
cd /etc/nixos  # or wherever config is
git pull
nixos-rebuild switch --flake .#rk1-node1

# Verify new host key matches secrets
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

**Verification**:
- SSH with key works: `ssh michael@rk1-node1`
- Password rejected: `ssh -o PubkeyAuthentication=no michael@rk1-node1` (should fail)
- Host key stable across rebuilds

### Phase 3: Ganon Updates (P4)

**Goal**: Switch to systemd-boot, verify secrets working.

**Tasks**:
1. Update `hosts/nixos/ganon/configuration.nix`:
   - Change bootloader from GRUB to systemd-boot
   - Verify NVIDIA config is correct for RTX 30 series
   - Ensure Windows boot entry is detected

2. Generate/verify Ganon's age key in `.sops.yaml`

**Note**: Switching bootloader on existing install requires care:
- Backup current boot config
- Ensure EFI partition is mounted at `/boot`
- May need to run `bootctl install` manually first time

**Verification**:
- `systemd-boot` shows NixOS and Windows entries
- Secrets decrypt correctly
- NVIDIA drivers load (`nvidia-smi` works)

### Phase 4: GLaDOS Bootstrap & Deploy (P5)

**Goal**: Fresh NixOS install on ThinkPad X1 Carbon Gen 8.

**Pre-deployment Tasks**:
1. Generate SSH host key for GLaDOS:
   ```bash
   ssh-keygen -t ed25519 -f glados_host_key -N "" -C "root@glados"
   ```

2. Derive age public key:
   ```bash
   cat glados_host_key.pub | ssh-to-age
   ```

3. Add to nix-secrets:
   - Add `&glados` to `.sops.yaml`
   - Add `host_keys.glados.{private,public}` to `secrets.yaml`
   - Run `sops updatekeys secrets.yaml`

4. Update GLaDOS configuration:
   - `hosts/nixos/glados/configuration.nix`: Add ThinkPad hardware, fingerprint
   - `hosts/nixos/glados/disks.nix`: Btrfs + LUKS layout
   - Add to `flake.nix` nixosConfigurations (already present)

5. Build and verify:
   ```bash
   nix build .#nixosConfigurations.glados.config.system.build.toplevel
   ```

**Deployment Steps**:
1. Create bootable NixOS USB with flake support
2. Boot GLaDOS from USB
3. Partition disk with disko
4. Deploy configuration with nixos-anywhere or manual nixos-install
5. Copy SSH host key to `/etc/ssh/` before first boot (or let secrets deploy it)
6. Reboot and verify

**Verification**:
- Boots into NixOS with LUKS prompt
- WiFi connects
- Fingerprint reader works (`fprintd-enroll`)
- SSH from Darwin works
- Secrets decrypt correctly

### Phase 5: Final Verification (All Hosts)

**Goal**: Confirm all success criteria met.

**Checklist**:
- [ ] `nix flake check` passes
- [ ] All 6 hosts build: `for h in ganon glados rk1-node{1..4}; do nix build .#nixosConfigurations.$h.config.system.build.toplevel; done`
- [ ] SSH works to all hosts from bowser
- [ ] `/run/secrets/` populated on all NixOS hosts
- [ ] `~/.config/sops/age/keys.txt` valid on all hosts
- [ ] RK1 host keys match secrets
- [ ] Ganon has systemd-boot
- [ ] GLaDOS hardware working

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Ganon bootloader switch fails | Keep GRUB config commented, test in VM first if possible |
| RK1 SSH lockout during update | Keep one node on old config until others verified |
| GLaDOS hardware not supported | nixos-hardware has X1 Carbon profiles; fallback to manual config |
| Secrets chicken-egg on new host | Pre-generate keys, add to .sops.yaml before deploy |

## Dependencies & Order

```
Phase 1 (Secrets Infrastructure)
    ↓
Phase 2 (RK1 Security) ←── depends on Phase 1
    ↓
Phase 3 (Ganon Updates) ←── depends on Phase 1
    ↓
Phase 4 (GLaDOS Deploy) ←── depends on Phase 1
    ↓
Phase 5 (Final Verification) ←── depends on all above
```

Phase 2, 3, 4 can be done in parallel after Phase 1 is complete.
