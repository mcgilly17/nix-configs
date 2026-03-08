# Phase 1: Activation Scaffold - Context

**Gathered:** 2026-03-08
**Status:** Ready for planning

<domain>
## Phase Boundary

WSL-to-Windows config copy pipeline: module directory at `users/michael/windows/`, `hostSpec.isWSL` guard, custom Nix option for registering config files, and a single `home.activation` hook that copies registered configs from WSL to the Windows filesystem. No actual app configs are included — those arrive in phases 2-4.

</domain>

<decisions>
## Implementation Decisions

### Module organization
- Subdirectories per app: `windows/komorebi/`, `windows/whkd/`, `windows/yasb/` — mirrors `linux/waybar/`, `linux/hyprlock/` pattern
- Import from WSL common config (`hosts/nixos/wsl/common/default.nix`) — both ocelot and mantis (and future WSL hosts) get it automatically
- `isWSL` guard at the `windows/default.nix` aggregator level using `lib.mkIf` — sub-modules don't need their own guards
- No test/placeholder file in Phase 1 — scaffold is empty until Phase 2 adds komorebi config

### Sync destination paths
- Standard `.config/<app>/` paths on Windows: `/mnt/c/Users/michael/.config/komorebi/`, `.config/whkd/`, `.config/yasb/`
- Central `windowsHomePath` variable defined once in `windows/default.nix` (value: `/mnt/c/Users/michael`)
- Sync hook auto-creates destination directories with `mkdir -p`
- Standard 644 permissions on copied files

### Config registration mechanism
- Custom Nix option: `windows.configFiles` attrset
- Sub-modules register files: `windows.configFiles."komorebi/komorebi.json" = derivation;`
- Supports both individual files and directory trees
- Key is relative path under `.config/` by default, with optional target path override for apps that need non-standard locations
- Single activation hook iterates the attrset and copies all registered files

### Sync hook behavior
- Single `home.activation` entry copies all registered `windows.configFiles`
- Mount guard: check `/mnt/c` exists before attempting any copies; exit silently if not mounted
- Summary line per file: `[windows-sync] komorebi/komorebi.json -> synced`
- Continue on failure: copy as many files as possible, report failures at the end
- Always overwrite destination files (no diff/checksum comparison)

### Claude's Discretion
- Exact Nix option type definition for `windows.configFiles` (submodule structure)
- Activation hook ordering (entryAfter/entryBefore targets)
- Error message formatting
- Whether to use `$DRY_RUN_CMD` prefix (matching darwin sops pattern)

</decisions>

<specifics>
## Specific Ideas

- Follow existing `home.activation` patterns: `removeExistingGitconfig` (git module) and `setupSshKey` (darwin sops) as reference implementations
- The `hosts/nixos/wsl/common/default.nix` already sets `hostSpec.isWSL = true` and imports `users/michael` — the windows module import goes here

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `hostSpec.isWSL`: Already defined in `modules/common/host-spec.nix`, set `true` in WSL common config
- `home.activation` pattern: Used in `users/michael/common/core/git/default.nix` (entryBefore) and `users/michael/darwin/sops.nix` (entryAfter with `$DRY_RUN_CMD`)
- `lib.mkIf` conditional pattern: Used in `linux/waybar/default.nix` for feature-gating modules

### Established Patterns
- Module aggregators: `linux/default.nix` imports sub-modules as a flat list
- Per-app subdirectories: `linux/waybar/`, `linux/hyprlock/`, `linux/hypridle/` each have `default.nix`
- Host spec flags: `config.hostSpec.isWSL or false` pattern for safe access (see `_1passwordcli.nix`)

### Integration Points
- `hosts/nixos/wsl/common/default.nix`: Where the `windows/` module import will be added (line ~39, alongside existing `users/michael` import)
- `users/michael/default.nix`: Defines user account, does NOT import platform modules (those come from host files)
- `ocelot.nix` / `mantis.nix`: WSL host home-manager configs — no changes needed since import goes through WSL common

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-activation-scaffold*
*Context gathered: 2026-03-08*
