# Research: Complete NixOS Host Configurations

**Branch**: `001-nixos-hosts` | **Date**: 2025-12-17

## Key Decisions

### 1. User Age Key Derivation

**Decision**: Derive user age key from user SSH key using `ssh-to-age`, same pattern as host age keys.

**Rationale**:
- Unified pattern: both host and user age keys derive from SSH keys
- No separate age key to manage/backup
- User's SSH key already in secrets.yaml (`private_keys.michael`)
- `&michael` in .sops.yaml is already the age public key derived from this SSH key

**Alternatives Considered**:
- Standalone age key (rejected: extra key to manage, different pattern from hosts)
- Per-host user age keys (rejected: unnecessary complexity for single user)

**Implementation**:
```nix
# In activation script
ssh-to-age -private-key < /run/secrets/michael-ssh-key > ~/.config/sops/age/keys.txt
```

### 2. Darwin Secrets Handling

**Decision**: Darwin hosts use michael's user age key (`&michael`) directly since they lack host-level SSH keys.

**Rationale**:
- Darwin doesn't have `/etc/ssh/ssh_host_ed25519_key` by default
- User's age key is sufficient for single-user scenario
- Already configured in current `modules/darwin/sops.nix`

**Alternatives Considered**:
- Generate host SSH key for Darwin (rejected: non-standard, adds complexity)
- Skip secrets on Darwin (rejected: need secrets for git, API keys, etc.)

### 3. SSH Host Key Management for RK1

**Decision**: Deploy SSH host keys from nix-secrets to `/etc/ssh/` during system activation.

**Rationale**:
- Keys already exist in secrets.yaml (`host_keys.rk1-node{1-4}`)
- Ensures stable host keys across rebuilds
- Enables proper age key derivation

**Implementation Approach**:
- Use sops-nix to extract keys to `/run/secrets/`
- Activation script copies to `/etc/ssh/` with correct permissions
- Must happen before sshd starts

**Risk**: Chicken-egg problem on first deploy (host needs key to decrypt, but key is encrypted)
**Mitigation**: For RK1 (already running), we can SSH in with password, deploy, then disable password auth.

### 4. GLaDOS Disk Layout

**Decision**: Btrfs + LUKS with standard subvolumes, NO impermanence.

**Rationale**:
- Laptop needs encryption (theft protection)
- Btrfs provides snapshots, compression
- Impermanence adds significant complexity - save for future enhancement

**Layout**:
```
/dev/nvme0n1
├── ESP (512M, vfat) → /boot
└── LUKS encrypted
    └── Btrfs
        ├── @root → /
        ├── @home → /home
        ├── @nix → /nix
        └── @swap → swapfile
```

**Reference**: EmergentMind's `btrfs-luks-impermanence-disk.nix` (minus the impermanence parts)

### 5. Ganon Bootloader

**Decision**: Switch from GRUB to systemd-boot.

**Rationale**:
- Cleaner, faster boot
- Better UEFI integration
- Auto-detects Windows boot entries

**Risk**: Bootloader switch on existing system
**Mitigation**:
- Ensure EFI partition mounted at `/boot`
- May need manual `bootctl install`
- Keep GRUB config as backup initially

### 6. ThinkPad X1 Carbon Gen 8 Support

**Decision**: Use nixos-hardware profile + fprintd for fingerprint.

**Research Findings**:
- nixos-hardware has `lenovo-thinkpad-x1-9th-gen` (close enough for Gen 8)
- Standard Intel WiFi (iwlwifi) supported out of box
- Fingerprint reader: Synaptics, supported via fprintd

**Configuration**:
```nix
imports = [
  inputs.nix-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
];

services.fprintd.enable = true;
```

### 7. RK1 Configuration

**Decision**: Keep current configuration (mainline kernel + RK3588 modules), don't use nixos-rk3588 flake.

**Research Findings**:
- nixos-rk3588 doesn't support Turing RK1 (only Orange Pi 5, Rock 5A)
- Current config uses `linuxPackages_latest` with RK3588-specific modules
- UEFI boot via systemd-boot (Turing Pi 2 has UEFI firmware)

**No changes needed** to RK1 hardware config - focus on secrets/SSH.

## Open Questions (Resolved)

| Question | Resolution |
|----------|------------|
| How to derive user age key? | From SSH key via ssh-to-age |
| Darwin host age keys? | Use user's age key |
| RK1 kernel approach? | Keep mainline, no nixos-rk3588 |
| GLaDOS encryption? | Btrfs + LUKS, no impermanence |
| Ganon bootloader? | Switch to systemd-boot |

## References Used

- [EmergentMind nix-config](https://github.com/EmergentMind/nix-config) - Secrets architecture, disk layouts
- [Khanelinix](https://github.com/khaneliman/khanelinix) - Btrfs configuration patterns
- [Secrets Management Guide](https://unmovedcentre.com/posts/secrets-management/) - sops-nix patterns
- [Remote Install Guide](https://unmovedcentre.com/posts/remote-install-nixos-config/) - SSH key bootstrap
- nixos-hardware repository - ThinkPad profiles
