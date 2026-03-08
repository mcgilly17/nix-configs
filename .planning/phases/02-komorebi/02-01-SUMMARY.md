---
phase: 02-komorebi
plan: "01"
subsystem: infra
tags: [nix, home-manager, wsl, komorebi, tiling-wm, catppuccin, windows-sync]

requires:
  - phase: 01-activation-scaffold
    provides: windows.configFiles option (attrsOf path) and syncWindowsConfigs activation hook

provides:
  - users/michael/windows/komorebi/default.nix — generates komorebi.json via builtins.toJSON
  - windows.configFiles."komorebi/komorebi.json" entry registered for WSL sync pipeline
  - Catppuccin Mocha theme, 4 float rules, and 2-monitor workspace config in generated JSON

affects:
  - 03-whkd — follows same sub-module pattern: create windows/whkd/default.nix, import in aggregator
  - 04-wt — follows same sub-module pattern for Windows Terminal fragment

tech-stack:
  added: []
  patterns:
    - "builtins.toJSON + pkgs.writeText for generating JSON config files from Nix attrsets"
    - "Sub-module pattern: windows/X/default.nix sets windows.configFiles unconditionally; parent aggregator isWSL guard applies"
    - "Quoted Nix attrset keys for JSON keys containing $: \"$schema\" = \"...\""
    - "No lib import in sub-modules that only set options (deadnix enforces this)"

key-files:
  created:
    - users/michael/windows/komorebi/default.nix
  modified:
    - users/michael/windows/default.nix

key-decisions:
  - "lib parameter omitted from sub-module function signature — deadnix pre-commit hook enforces no unused lambda patterns"
  - "Float rules placed in komorebi.json floating_applications (not applications.json) — applications.json is overwritten by komorebic fetch-asc"
  - "window_hiding_behaviour = Cloak (not Hide) — both hosts are Windows 11; Cloak uses cleaner Win11-specific API"
  - "No isWSL guard in sub-module — parent aggregator windows/default.nix wraps config in lib.mkIf isWSL; sub-module sets option unconditionally"

patterns-established:
  - "Sub-module registration: create windows/X/default.nix, add to aggregator imports list, no guard needed in sub-module"
  - "JSON generation: let komorebiConfig = { ... }; in { windows.configFiles.\"path\" = pkgs.writeText \"name\" (builtins.toJSON komorebiConfig); }"

requirements-completed: [KOMO-01, KOMO-02, KOMO-03, KOMO-04]

duration: 7min
completed: 2026-03-08
---

# Phase 2 Plan 01: Komorebi Summary

**komorebi.json generated via builtins.toJSON with Catppuccin Mocha theme, 4 float rules, and 2-monitor workspace config, wired into the Phase 1 windows.configFiles sync pipeline**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-08T22:01:51Z
- **Completed:** 2026-03-08T22:08:59Z
- **Tasks:** 2
- **Files modified:** 2 (1 created, 1 modified)

## Accomplishments

- Created `users/michael/windows/komorebi/default.nix` — Nix sub-module building a full `komorebiConfig` attrset and registering it via `windows.configFiles."komorebi/komorebi.json" = pkgs.writeText "komorebi.json" (builtins.toJSON komorebiConfig)`
- Added `imports = [ ./komorebi ];` to the `windows/default.nix` aggregator to wire the sub-module into the sync pipeline
- Verified generated JSON: valid, `theme.palette == "Catppuccin"`, `theme.name == "Mocha"`, 4 float rules, 2 monitor configs, `border == true`, `default_workspace_padding == 10`
- All three dry-builds confirmed: ocelot (WSL), mantis (WSL), ganon (non-WSL — proving the isWSL guard still works)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create komorebi module and wire aggregator import** - `72b84b8` (feat)
2. **Task 2: Validate generated komorebi.json content** - (validation only, no source changes — committed with plan metadata)

**Plan metadata:** (docs commit — pending)

## Files Created/Modified

- `users/michael/windows/komorebi/default.nix` - Komorebi sub-module: full komorebiConfig attrset with schema, border/padding settings, Catppuccin Mocha theme, 4 float rules, 2-monitor workspace config, registered via windows.configFiles
- `users/michael/windows/default.nix` - Added `imports = [ ./komorebi ];` to wire sub-module into aggregator

## Decisions Made

- `lib` parameter omitted from sub-module function signature — the module body only sets `windows.configFiles`, which requires only `pkgs`. The `deadnix` pre-commit hook enforces no unused lambda patterns; this was caught and fixed before the Task 1 commit.
- Float rules defined in `komorebi.json` under `floating_applications`, not in `applications.json` — the `applications.json` file is managed by `komorebic fetch-asc` (downloads community config) and overwrites any custom rules. Custom rules in `komorebi.json` are persistent.
- `window_hiding_behaviour = "Cloak"` chosen over `"Hide"` — both target hosts (ocelot, mantis) run Windows 11 where Cloak uses a clean Win11-specific API for hiding unfocused windows.
- No `isWSL` guard in the komorebi sub-module — the parent aggregator `windows/default.nix` already wraps the entire `config` block in `lib.mkIf isWSL`. The sub-module sets `windows.configFiles` unconditionally, which is correct because the option is declared unconditionally for type-checking purposes.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed unused `lib` parameter from sub-module function signature**
- **Found during:** Task 1 commit (pre-commit hook caught it)
- **Issue:** The plan's module template included `lib,` in the function args, but the komorebi sub-module body never calls any `lib.*` functions. The `deadnix` pre-commit hook reported "Unused lambda pattern: lib" and blocked the commit.
- **Fix:** Changed `{ lib, pkgs, ... }:` to `{ pkgs, ... }:` in `komorebi/default.nix`
- **Files modified:** `users/michael/windows/komorebi/default.nix`
- **Verification:** deadnix passed on re-commit, module evaluates correctly
- **Committed in:** `72b84b8` (Task 1 commit, after fix)

---

**Total deviations:** 1 auto-fixed (Rule 1 - unused import)
**Impact on plan:** Minor cleanup required by pre-commit enforcement. No scope change.

## Issues Encountered

- Pre-existing `catppuccin-starship` build failure in `nix flake check` — confirmed pre-existing from Phase 1 SUMMARY. Not introduced by this plan. Out of scope (deviation rules: only fix issues caused by current task's changes).
- New file `komorebi/default.nix` required `git add` before Nix could resolve the import path — Nix flake uses the git-tracked source tree, so untracked files are not visible to the evaluator.

## User Setup Required

One-time Windows-side manual step (outside Nix control):

Add to PowerShell profile (`$PROFILE`) on ocelot and mantis:
```powershell
$Env:KOMOREBI_CONFIG_HOME = "$Env:USERPROFILE\.config\komorebi"
```

This tells komorebi to look for `komorebi.json` at `C:\Users\michael\.config\komorebi\komorebi.json`, which is where the Phase 1 sync hook deposits the file. Without this, komorebi defaults to `$USERPROFILE` (i.e., `C:\Users\michael\`) and ignores the generated config.

Additionally, run once to populate `applications.json` (referenced by the generated config):
```powershell
komorebic fetch-asc
```

## Next Phase Readiness

- Sub-module pattern is fully established — Phase 3 (whkd) can follow the same pattern: create `windows/whkd/default.nix`, add `./whkd` to the aggregator imports list, no isWSL guard needed
- The `windows.configFiles` pipeline now has its first real entry — the sync hook will copy `komorebi.json` to `/mnt/c/Users/michael/.config/komorebi/komorebi.json` on next HM activation on ocelot/mantis
- Blocker from STATE.md resolved: komorebi v0.1.40 `applications.json` schema verified — custom float rules must go in `komorebi.json` not `applications.json`

---
*Phase: 02-komorebi*
*Completed: 2026-03-08*
