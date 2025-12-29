# Tasks: Complete NixOS Host Configurations

**Input**: Design documents from `/specs/001-nixos-hosts/`
**Prerequisites**: plan.md, spec.md, research.md

**Tests**: Tests are NOT explicitly requested - manual verification commands provided instead.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

```text
# NixOS Dotfiles Structure
modules/nixos/sops.nix              # Secrets management module (UPDATED)
modules/darwin/sops.nix             # DELETED - was broken
users/michael/darwin/sops.nix       # Darwin user-level sops (UPDATED)
hosts/nixos/ganon/                  # Gaming PC configuration
hosts/nixos/glados/                 # Laptop configuration (ADDED TO FLAKE)
hosts/nixos/rk1/common/             # RK1 shared configuration (FIXED)
hosts/nixos/rk1/node{1-4}/          # Per-node configuration
nix-secrets/.sops.yaml              # External: key definitions
nix-secrets/secrets.yaml            # External: encrypted secrets
```

---

## Phase 1: Setup (Foundation Review)

**Purpose**: Verify current state and understand existing infrastructure

- [x] T001 Review current sops.nix implementation in modules/nixos/sops.nix
- [x] T002 [P] Verify nix-secrets .sops.yaml has all required host keys (michael, ganon, rk1-node{1-4})
- [x] T003 [P] Review existing host configurations in hosts/nixos/ganon/, hosts/nixos/glados/, hosts/nixos/rk1/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core secrets infrastructure that MUST be complete before ANY user story can be fully implemented

**✅ COMPLETE**: Secrets infrastructure implemented with Pattern B (derive age key from SSH key)

- [x] T004 Update sops.nix to extract michael's SSH private key to /run/secrets/private_keys/michael in modules/nixos/sops.nix
- [x] T005 Add activation script to derive user age key via ssh-to-age in modules/nixos/sops.nix
- [x] T006 ~~Create SSH host key deployment module~~ NOT NEEDED - user manually places SSH host keys before deployment
- [x] T007 ~~Configure SSH host key deployment~~ NOT NEEDED - handled manually
- [x] T008 Verify flake.nix imports sops module for applicable hosts - GLaDOS added to flake

**Additional work completed**:
- Deleted broken modules/darwin/sops.nix (referenced non-existent host SSH key)
- Updated users/michael/darwin/sops.nix to derive age key from ~/.ssh/id_ed25519
- Fixed RK1 common config: deprecated firmware option, disko import, networkmanager conflict
- Fixed all deadnix and statix warnings across codebase
- All 6 NixOS hosts now evaluate correctly (ganon, glados, rk1-node{1-4})

**Checkpoint**: ✅ Secrets infrastructure ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Secrets Management (Priority: P1) 🎯 MVP

**Goal**: sops-nix secrets decrypt correctly on all hosts with user age key derived from SSH key

**Independent Test**:
- `nix eval .#nixosConfigurations.ganon.config.networking.hostName` ✅ PASSES
- After rebuild: verify `/run/secrets/` populated and `~/.config/sops/age/keys.txt` exists

### Implementation for User Story 1

- [x] T009 [US1] Add sops secret definition for private_keys/michael in modules/nixos/sops.nix
- [x] T010 [US1] Implement user age key derivation activation script in modules/nixos/sops.nix
- [x] T011 [P] [US1] Ensure activation script creates ~/.config/sops/age/ directory with correct permissions in modules/nixos/sops.nix
- [x] T012 [US1] Add ssh-to-age to systemPackages in modules/nixos/sops.nix
- [ ] T013 [US1] Test secrets decryption on ganon (existing NixOS host) via nixos-rebuild
- [ ] T014 [US1] Verify user age key is correctly derived and placed at ~/.config/sops/age/keys.txt

**Checkpoint**: Secrets management configuration complete - needs hardware testing

---

## Phase 4: User Story 2 - SSH Access (Priority: P2)

**Goal**: SSH into all NixOS hosts from Darwin machines using key authentication

**Independent Test**: `ssh michael@<hostname>` from bowser/sephiroth returns working shell

### Implementation for User Story 2

- [ ] T015 [US2] Verify SSH server enabled with ed25519 host keys in modules/nixos/common.nix
- [ ] T016 [US2] Configure SSH to disable password authentication in modules/nixos/common.nix
- [ ] T017 [P] [US2] Add michael's public SSH key to authorized_keys in modules/nixos/common.nix or users/michael/
- [ ] T018 [US2] Verify SSH authorized keys managed declaratively via nix-secrets or flake
- [ ] T019 [US2] Test SSH access from Darwin host to ganon

**Checkpoint**: SSH access working to existing hosts

---

## Phase 5: User Story 3 - RK1 Cluster Security (Priority: P3)

**Goal**: Replace insecure passwords and wrong host keys on RK1 nodes with secrets-managed configuration

**Independent Test**:
- `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` matches secrets
- `ssh -o PubkeyAuthentication=no michael@rk1-node1` is rejected

### Implementation for User Story 3

- [ ] T020 [US3] Add SSH host key deployment to RK1 common config in hosts/nixos/rk1/common/default.nix
- [ ] T021 [P] [US3] Configure sops secrets for host_keys.rk1-node1 (private and public) in hosts/nixos/rk1/node1/default.nix
- [ ] T022 [P] [US3] Configure sops secrets for host_keys.rk1-node2 in hosts/nixos/rk1/node2/default.nix
- [ ] T023 [P] [US3] Configure sops secrets for host_keys.rk1-node3 in hosts/nixos/rk1/node3/default.nix
- [ ] T024 [P] [US3] Configure sops secrets for host_keys.rk1-node4 in hosts/nixos/rk1/node4/default.nix
- [ ] T025 [US3] Deploy updated config to rk1-node1 first (SSH with current password, rebuild, verify)
- [ ] T026 [US3] Verify host key matches secrets on rk1-node1 after rebuild
- [ ] T027 [US3] Roll out to remaining RK1 nodes (node2, node3, node4)
- [ ] T028 [US3] Verify password authentication is rejected on all RK1 nodes

**Checkpoint**: All RK1 nodes secured with proper SSH keys from secrets

---

## Phase 6: User Story 4 - Complete Host Configurations (Priority: P4)

**Goal**: All hosts fully configured in flake with correct hardware settings

**Independent Test**: `nix eval .#nixosConfigurations.<host>.config.networking.hostName` for all 6 hosts ✅ PASSES

### Implementation for User Story 4

- [ ] T029 [US4] Update Ganon to use systemd-boot instead of GRUB in hosts/nixos/ganon/configuration.nix
- [ ] T030 [P] [US4] Verify NVIDIA RTX 30 series configuration in hosts/nixos/ganon/configuration.nix
- [ ] T031 [P] [US4] Verify Windows dual-boot entries detected by systemd-boot for ganon
- [ ] T032 [US4] Update GLaDOS disks.nix with Btrfs + LUKS layout in hosts/nixos/glados/disks.nix
- [ ] T033 [P] [US4] Add nixos-hardware ThinkPad X1 profile to GLaDOS in hosts/nixos/glados/configuration.nix
- [ ] T034 [P] [US4] Enable fprintd for fingerprint reader in hosts/nixos/glados/configuration.nix
- [ ] T035 [P] [US4] Configure TLP power management for GLaDOS in hosts/nixos/glados/configuration.nix
- [x] T036 [US4] Run nix flake check to verify all configurations evaluate without errors
- [ ] T037 [US4] Build all 6 host configurations to verify they compile (requires Linux builder)

**Checkpoint**: All configurations complete and building successfully

---

## Phase 7: User Story 5 - Deploy GLaDOS (Priority: P5)

**Goal**: Fresh NixOS install on ThinkPad X1 Carbon Gen 8

**Independent Test**:
- GLaDOS boots into NixOS with LUKS prompt
- `ssh michael@glados` from Darwin works
- `/run/secrets/` populated

### Pre-deployment Tasks (on Darwin)

- [ ] T038 [US5] Generate SSH host key for GLaDOS: ssh-keygen -t ed25519 -f glados_host_key
- [ ] T039 [US5] Derive age public key from GLaDOS SSH key: cat glados_host_key.pub | ssh-to-age
- [ ] T040 [US5] Add &glados age key to nix-secrets .sops.yaml
- [ ] T041 [US5] Add host_keys.glados.private and host_keys.glados.public to nix-secrets secrets.yaml
- [ ] T042 [US5] Run sops updatekeys secrets.yaml to rekey for GLaDOS
- [ ] T043 [US5] Build GLaDOS configuration: nix build .#nixosConfigurations.glados.config.system.build.toplevel

### Deployment Tasks (on GLaDOS hardware)

- [ ] T044 [US5] Create bootable NixOS USB with flake support
- [ ] T045 [US5] Boot GLaDOS from USB and partition disk with disko
- [ ] T046 [US5] Deploy configuration via nixos-install or nixos-anywhere
- [ ] T047 [US5] Copy SSH host key to /etc/ssh/ before first boot
- [ ] T048 [US5] Reboot and verify LUKS prompt works

### Post-deployment Verification

- [ ] T049 [US5] Verify WiFi connects on GLaDOS
- [ ] T050 [US5] Verify fingerprint reader works (fprintd-enroll)
- [ ] T051 [US5] Verify SSH access from Darwin host
- [ ] T052 [US5] Verify secrets decrypt correctly

**Checkpoint**: GLaDOS fully deployed and operational

---

## Phase 8: Polish & Final Verification

**Purpose**: Confirm all success criteria met across all hosts

- [ ] T053 Run nix flake check - verify passes with zero errors
- [ ] T054 Build all 6 hosts: ganon, glados, rk1-node{1-4}
- [ ] T055 [P] Verify SSH works from bowser to all NixOS hosts
- [ ] T056 [P] Verify /run/secrets/ populated on all NixOS hosts
- [ ] T057 [P] Verify ~/.config/sops/age/keys.txt valid on all hosts
- [ ] T058 Verify RK1 host keys match secrets (ssh-keygen -lf on each)
- [ ] T059 Verify Ganon boots with systemd-boot showing NixOS and Windows
- [ ] T060 Verify GLaDOS hardware all working (WiFi, display, fingerprint)
- [ ] T061 Update .sops.yaml if any keys were regenerated during implementation

---

## Progress Summary

### Completed
- **Phase 1**: Full review complete
- **Phase 2**: Pattern B secrets infrastructure implemented
- **Phase 3**: T009-T012 complete (sops.nix configuration done, needs hardware test)
- **Phase 6**: T036 complete (all configs evaluate), GLaDOS added to flake

### Implementation Notes

**Pattern B (Derive age key from SSH key)**:
- NixOS: Host SSH key → host age key → decrypt user SSH key → derive user age key
- Darwin: User SSH key → derive user age key (simpler, no host-level)

**Bootstrap Pattern**:
1. Manually place SSH key on machine (host key for NixOS, user key for Darwin)
2. System activation derives age key automatically via ssh-to-age
3. sops-nix uses age key to decrypt secrets

**Key Commits**:
- `913a0f9` refactor(sops): derive user age key from SSH key (Pattern B)
- `e17dca2` fix(rk1): correct config issues for evaluation
- `165f510` chore: update flake inputs
- `1adda62` style: fix deadnix and statix warnings + add GLaDOS

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: ✅ COMPLETE
- **Foundational (Phase 2)**: ✅ COMPLETE
- **User Story 1 (Phase 3)**: Configuration complete, needs hardware testing
- **User Story 2 (Phase 4)**: Depends on US1 (needs secrets working)
- **User Story 3 (Phase 5)**: Depends on US1 + US2 (needs secrets + SSH patterns)
- **User Story 4 (Phase 6)**: Partially complete (evaluation works)
- **User Story 5 (Phase 7)**: Depends on US4 (GLaDOS config must be complete)
- **Polish (Phase 8)**: Depends on all above

### Next Steps

1. Test secrets decryption on ganon (T013-T014)
2. Verify SSH configuration in common.nix (T015-T019)
3. Complete GLaDOS hardware config (T032-T035)
4. Deploy to actual hardware

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Manual verification via nix eval and SSH commands (no automated tests)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- RK1 deployment requires SSH with current insecure password first
- GLaDOS requires physical USB boot for initial deployment
