---
phase: 2
slug: komorebi
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-08
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Nix evaluation (no external test framework) |
| **Config file** | N/A |
| **Quick run command** | `nix flake check` |
| **Full suite command** | `nixos-rebuild dry-build --flake .#ocelot && nixos-rebuild dry-build --flake .#mantis` |
| **Estimated runtime** | ~30 seconds (flake check), ~120 seconds (full dry-build) |

---

## Sampling Rate

- **After every task commit:** Run `nix flake check`
- **After every plan wave:** Run `nixos-rebuild dry-build --flake .#ocelot && nixos-rebuild dry-build --flake .#mantis`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | KOMO-01 | smoke | `nix eval .#nixosConfigurations.ocelot.config.home-manager.users.michael.windows.configFiles` → non-empty | ❌ W0 | ⬜ pending |
| 02-01-02 | 01 | 1 | KOMO-01 | smoke | Read generated store path + `jq '.monitors, .border, .default_workspace_padding'` | ❌ W0 | ⬜ pending |
| 02-01-03 | 01 | 1 | KOMO-02 | smoke | `jq '.floating_applications | length'` on generated file ≥ 4 | ❌ W0 | ⬜ pending |
| 02-01-04 | 01 | 1 | KOMO-03 | smoke | `jq '.theme.palette, .theme.name'` == "Catppuccin", "Mocha" | ❌ W0 | ⬜ pending |
| 02-01-05 | 01 | 1 | KOMO-04 | smoke | `jq '.monitors | length'` ≥ 2 + distinct workspace names | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `users/michael/windows/komorebi/default.nix` — module created in this phase
- [ ] `users/michael/windows/default.nix` — `imports = [ ./komorebi ];` added
- [ ] Generated JSON validated via `jq .` after first build

*All Wave 0 items are created by the phase itself — no pre-existing test infrastructure needed.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| `KOMOREBI_CONFIG_HOME` env var set | KOMO-01 | Windows-side PowerShell profile, outside Nix | Verify `$Env:KOMOREBI_CONFIG_HOME` is set to `$Env:USERPROFILE\.config\komorebi` |
| komorebi loads generated config | KOMO-01 | Requires running Windows process | Start komorebi, check tiling behavior |
| Float rules take effect | KOMO-02 | Requires running Windows apps | Open Task Manager, Settings — verify they float |
| Multi-monitor layout applies | KOMO-04 | Requires physical multi-monitor | Connect second monitor, verify workspace config |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending