---
phase: 01-activation-scaffold
plan: "01"
subsystem: infra
tags: [nix, home-manager, wsl, activation-hook, windows-sync]

requires: []

provides:
  - windows.configFiles option (attrsOf path, default empty) for sub-modules to register files
  - home.activation.syncWindowsConfigs hook on WSL hosts (ocelot, mantis)
  - isWSL guard pattern — module is safe to import on any host, only activates under WSL
  - Mount guard that skips gracefully when /mnt/c/Users/michael is not accessible

affects:
  - 02-komorebi — will set windows.configFiles."komorebi/..." entries
  - 03-whkd — will set windows.configFiles."whkd/..." entries
  - 04-wt — will set windows.configFiles."windowsterminal/..." entries

tech-stack:
  added: []
  patterns:
    - "HM module option declared outside lib.mkIf so non-WSL hosts can evaluate the type"
    - "lib.hm.dag.entryAfter [\"writeBoundary\"] for activation hooks that need managed files to exist first"
    - "$DRY_RUN_CMD prefix on all write operations for dry-run compatibility"
    - "Mount guard pattern: check dir existence, echo + exit 0 on failure"
    - "lib.mapAttrsToList + lib.concatStringsSep to generate per-file shell commands at eval time"

key-files:
  created:
    - users/michael/windows/default.nix
  modified:
    - users/michael/hosts/ocelot.nix
    - users/michael/hosts/mantis.nix

key-decisions:
  - "Options declared unconditionally (outside lib.mkIf) so non-WSL hosts can import the module without type errors"
  - "entryAfter [writeBoundary] chosen over entryBefore — source paths must exist in the store before copying"
  - "Mount guard uses exit 0 (not abort) — missing /mnt/c is expected in non-mounted WSL contexts"
  - "Per-file $DRY_RUN_CMD prefix on cp and chmod — matches existing darwin/sops.nix activation pattern"

patterns-established:
  - "isWSL guard pattern: osConfig.hostSpec.isWSL or false in let-binding, lib.mkIf isWSL wraps entire config block"
  - "Windows sync hook: entryAfter writeBoundary, mount guard, _failed counter, per-entry logging"

requirements-completed: [SCAF-01, SCAF-02, SCAF-03, SCAF-04]

duration: 10min
completed: 2026-03-08
---

# Phase 1 Plan 01: Activation Scaffold Summary

**Home Manager module with windows.configFiles option, isWSL guard, and syncWindowsConfigs activation hook wired into ocelot and mantis WSL hosts**

## Performance

- **Duration:** 10 min
- **Started:** 2026-03-08T21:22:33Z
- **Completed:** 2026-03-08T21:32:38Z
- **Tasks:** 2
- **Files modified:** 3 (1 created, 2 modified)

## Accomplishments

- Created `users/michael/windows/default.nix` with the `windows.configFiles` option declared unconditionally so non-WSL hosts can evaluate the type without errors
- Installed `home.activation.syncWindowsConfigs` hook (entryAfter writeBoundary) on WSL hosts: mount guard, per-file copy with `$DRY_RUN_CMD`, `chmod 644`, logging, and `_failed` counter
- Wired `../windows` import into both `ocelot.nix` and `mantis.nix`; verified ganon (non-WSL) has no hook and builds without error
- Pre-commit hooks (deadnix, nixfmt-rfc-style, statix) passed on both task commits

## Task Commits

Each task was committed atomically:

1. **Task 1: Create windows/default.nix — option, guard, activation hook** - `5224838` (feat)
2. **Task 2: Wire ../windows import into ocelot.nix and mantis.nix** - `ed488e7` (feat)

**Plan metadata:** (docs commit — pending)

## Files Created/Modified

- `users/michael/windows/default.nix` - Core scaffold: windows.configFiles option, isWSL guard, syncWindowsConfigs activation hook
- `users/michael/hosts/ocelot.nix` - Added `../windows` to imports list
- `users/michael/hosts/mantis.nix` - Added `../windows` to imports list

## Decisions Made

- Options declared unconditionally outside `lib.mkIf` — non-WSL hosts must be able to import the module without type errors (Phase 2-4 sub-modules will reference the option type)
- `entryAfter ["writeBoundary"]` instead of `entryBefore` — source Nix store paths must exist before copying; writeBoundary ensures all managed files are in place
- Mount guard uses `exit 0` (not error abort) — `/mnt/c` not being mounted is a valid and expected state (e.g. WSL started without Windows integration)
- `$DRY_RUN_CMD` prefix on all write ops — matches darwin/sops.nix pattern established in existing codebase
- `../windows` import added only to WSL hosts (ocelot, mantis), not non-WSL hosts — no reason for non-WSL hosts to carry this import

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

- `nix flake check` reports a pre-existing catppuccin-starship build failure unrelated to this plan. Confirmed pre-existing by stash testing. Logged as out-of-scope (deviation rules: only fix issues directly caused by current task's changes).

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- Scaffold is fully live on ocelot and mantis
- `windows.configFiles` is empty (`{}` default) — Phase 2 komorebi module registers the first entries
- Phase 2 can safely set `windows.configFiles."komorebi/komorebi.json" = <store-path>` and the hook will copy it on next activation
- Blocker for Phase 2 noted in STATE.md: verify komorebi v0.1.40 applications.json schema before writing

---
*Phase: 01-activation-scaffold*
*Completed: 2026-03-08*
