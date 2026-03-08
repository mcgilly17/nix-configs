---
phase: 1
slug: activation-scaffold
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-08
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Nix flake evaluation (no test framework — this is a Nix dotfiles repo) |
| **Config file** | `flake.nix` |
| **Quick run command** | `nix flake check` |
| **Full suite command** | `nix flake check && nixos-rebuild dry-build --flake .#ocelot && nixos-rebuild dry-build --flake .#mantis` |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** Run `nix flake check`
- **After every plan wave:** Run `nix flake check && nixos-rebuild dry-build --flake .#ocelot && nixos-rebuild dry-build --flake .#mantis`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | SCAF-01 | smoke | `nix eval .#nixosConfigurations.ocelot.config.home-manager.users.michael.windows.configFiles` | ❌ W0 | ⬜ pending |
| 01-01-02 | 01 | 1 | SCAF-02 | smoke | `nixos-rebuild dry-build --flake .#ganon` (non-WSL host builds without windows module) | ❌ W0 | ⬜ pending |
| 01-01-03 | 01 | 1 | SCAF-03 | smoke | `nix eval .#nixosConfigurations.ocelot.config.home-manager.users.michael.home.activation.syncWindowsConfigs` | ❌ W0 | ⬜ pending |
| 01-01-04 | 01 | 1 | SCAF-04 | manual | N/A — runtime WSL mount check | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements. Nix flake evaluation serves as the test harness — no additional test framework needed.

- [ ] Verify `nix flake check` runs from project root
- [ ] Verify `nixos-rebuild dry-build --flake .#ocelot` completes successfully
- [ ] Document manual test procedure for SCAF-04 (mount guard)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Mount guard exits silently when `/mnt/c` absent | SCAF-04 | Requires WSL runtime with unmounted drive — cannot simulate in nix eval | 1. Unmount `/mnt/c` or test on non-WSL host 2. Run `home-manager switch` 3. Verify no windows-sync errors in output 4. Verify build succeeds |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
