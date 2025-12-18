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
modules/nixos/sops.nix              # Secrets management module (NEEDS UPDATE)
modules/nixos/ssh-host-keys.nix     # NEW: SSH host key deployment module
hosts/nixos/ganon/                  # Gaming PC configuration
hosts/nixos/glados/                 # Laptop configuration
hosts/nixos/rk1/common/             # RK1 shared configuration
hosts/nixos/rk1/node{1-4}/          # Per-node configuration
nix-secrets/.sops.yaml              # External: key definitions
nix-secrets/secrets.yaml            # External: encrypted secrets
```

---

## Phase 1: Setup (Foundation Review)

**Purpose**: Verify current state and understand existing infrastructure

- [ ] T001 Review current sops.nix implementation in modules/nixos/sops.nix
- [ ] T002 [P] Verify nix-secrets .sops.yaml has all required host keys (michael, ganon, rk1-node{1-4})
- [ ] T003 [P] Review existing host configurations in hosts/nixos/ganon/, hosts/nixos/glados/, hosts/nixos/rk1/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core secrets infrastructure that MUST be complete before ANY user story can be fully implemented

**⚠️ CRITICAL**: No host deployment can succeed until secrets infrastructure is fixed

- [ ] T004 Update sops.nix to extract michael's SSH private key to /run/secrets/michael-ssh-key in modules/nixos/sops.nix
- [ ] T005 Add activation script to derive user age key via ssh-to-age in modules/nixos/sops.nix
- [ ] T006 Create SSH host key deployment module in modules/nixos/ssh-host-keys.nix
- [ ] T007 [P] Configure SSH host key deployment to run before sshd in modules/nixos/ssh-host-keys.nix
- [ ] T008 Verify flake.nix imports new ssh-host-keys module for applicable hosts

**Checkpoint**: Secrets infrastructure ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Secrets Management (Priority: P1) 🎯 MVP

**Goal**: sops-nix secrets decrypt correctly on all hosts with user age key derived from SSH key

**Independent Test**:
- `nix build .#nixosConfigurations.ganon.config.system.build.toplevel`
- After rebuild: verify `/run/secrets/` populated and `~/.config/sops/age/keys.txt` exists

### Implementation for User Story 1

- [ ] T009 [US1] Add sops secret definition for private_keys.michael in modules/nixos/sops.nix
- [ ] T010 [US1] Implement user age key derivation activation script in modules/nixos/sops.nix
- [ ] T011 [P] [US1] Ensure activation script creates ~/.config/sops/age/ directory with correct permissions in modules/nixos/sops.nix
- [ ] T012 [US1] Add ssh-to-age to systemPackages in modules/nixos/sops.nix or common.nix
- [ ] T013 [US1] Test secrets decryption on ganon (existing NixOS host) via nixos-rebuild
- [ ] T014 [US1] Verify user age key is correctly derived and placed at ~/.config/sops/age/keys.txt

**Checkpoint**: Secrets management working on at least one host - core MVP functionality complete

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

**Independent Test**: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` for all 6 hosts

### Implementation for User Story 4

- [ ] T029 [US4] Update Ganon to use systemd-boot instead of GRUB in hosts/nixos/ganon/configuration.nix
- [ ] T030 [P] [US4] Verify NVIDIA RTX 30 series configuration in hosts/nixos/ganon/configuration.nix
- [ ] T031 [P] [US4] Verify Windows dual-boot entries detected by systemd-boot for ganon
- [ ] T032 [US4] Update GLaDOS disks.nix with Btrfs + LUKS layout in hosts/nixos/glados/disks.nix
- [ ] T033 [P] [US4] Add nixos-hardware ThinkPad X1 profile to GLaDOS in hosts/nixos/glados/configuration.nix
- [ ] T034 [P] [US4] Enable fprintd for fingerprint reader in hosts/nixos/glados/configuration.nix
- [ ] T035 [P] [US4] Configure TLP power management for GLaDOS in hosts/nixos/glados/configuration.nix
- [ ] T036 [US4] Run nix flake check to verify all configurations evaluate without errors
- [ ] T037 [US4] Build all 6 host configurations to verify they compile

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

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational - Core MVP
- **User Story 2 (Phase 4)**: Depends on US1 (needs secrets working)
- **User Story 3 (Phase 5)**: Depends on US1 + US2 (needs secrets + SSH patterns)
- **User Story 4 (Phase 6)**: Depends on US1 (needs secrets for host builds)
- **User Story 5 (Phase 7)**: Depends on US4 (GLaDOS config must be complete)
- **Polish (Phase 8)**: Depends on all above

### User Story Dependencies

```
Phase 1: Setup
    ↓
Phase 2: Foundational (BLOCKS ALL)
    ↓
Phase 3: US1 Secrets (MVP) ←── Critical path
    ↓
Phase 4: US2 SSH Access
    ↓
┌───────────────────────────┐
│  Can proceed in parallel: │
│  - Phase 5: US3 RK1       │
│  - Phase 6: US4 Configs   │
└───────────────────────────┘
    ↓
Phase 7: US5 GLaDOS Deploy
    ↓
Phase 8: Final Verification
```

### Parallel Opportunities

**Within Phase 2 (Foundational)**:
- T007 can run parallel after T006 is complete

**Within Phase 3 (US1 Secrets)**:
- T011 can run parallel with T009, T010

**Within Phase 5 (US3 RK1)**:
- T021, T022, T023, T024 (all node configs) can run in parallel

**Within Phase 6 (US4 Configs)**:
- T030, T031 (Ganon verification) can run in parallel
- T033, T034, T035 (GLaDOS laptop features) can run in parallel

**Within Phase 8 (Verification)**:
- T055, T056, T057 can run in parallel

---

## Parallel Example: RK1 Node Configuration

```bash
# Launch all RK1 node secret configs in parallel:
Task: "Configure sops secrets for host_keys.rk1-node1 in hosts/nixos/rk1/node1/default.nix"
Task: "Configure sops secrets for host_keys.rk1-node2 in hosts/nixos/rk1/node2/default.nix"
Task: "Configure sops secrets for host_keys.rk1-node3 in hosts/nixos/rk1/node3/default.nix"
Task: "Configure sops secrets for host_keys.rk1-node4 in hosts/nixos/rk1/node4/default.nix"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (review current state)
2. Complete Phase 2: Foundational (fix sops.nix)
3. Complete Phase 3: User Story 1 (secrets working)
4. **STOP and VALIDATE**: Test on ganon - secrets decrypt, age key derived
5. This alone provides working secrets management

### Incremental Delivery

1. Setup + Foundational → Infrastructure ready
2. Add US1 (Secrets) → Test on ganon → Core functionality (MVP!)
3. Add US2 (SSH) → Test SSH to ganon → Remote management enabled
4. Add US3 (RK1) → Test all 4 nodes → Cluster secured
5. Add US4 (Configs) → Build all hosts → Configurations complete
6. Add US5 (GLaDOS) → Deploy laptop → Full fleet deployed

### Risk Mitigation

| Task | Risk | Mitigation |
|------|------|------------|
| T029 (Ganon bootloader) | Bootloader switch fails | Keep GRUB config commented as backup |
| T025-T027 (RK1 deploy) | SSH lockout | Keep one node on old config until verified |
| T045-T048 (GLaDOS deploy) | Hardware issues | nixos-hardware has X1 Carbon profile |
| T040-T042 (GLaDOS keys) | Secrets chicken-egg | Pre-generate keys before deploy |

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Manual verification via nix build and SSH commands (no automated tests)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- RK1 deployment requires SSH with current insecure password first
- GLaDOS requires physical USB boot for initial deployment
