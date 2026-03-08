# Phase 1: Activation Scaffold - Research

**Researched:** 2026-03-08
**Domain:** Home Manager modules, Nix option types, home.activation hooks, WSL filesystem
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Subdirectories per app: `windows/komorebi/`, `windows/whkd/`, `windows/yasb/` — mirrors `linux/waybar/`, `linux/hyprlock/` pattern
- Import from WSL common config (`hosts/nixos/wsl/common/default.nix`) — both ocelot and mantis (and future WSL hosts) get it automatically
- `isWSL` guard at the `windows/default.nix` aggregator level using `lib.mkIf` — sub-modules don't need their own guards
- No test/placeholder file in Phase 1 — scaffold is empty until Phase 2 adds komorebi config
- Standard `.config/<app>/` paths on Windows: `/mnt/c/Users/michael/.config/komorebi/`, `.config/whkd/`, `.config/yasb/`
- Central `windowsHomePath` variable defined once in `windows/default.nix` (value: `/mnt/c/Users/michael`)
- Sync hook auto-creates destination directories with `mkdir -p`
- Standard 644 permissions on copied files
- Custom Nix option: `windows.configFiles` attrset
- Sub-modules register files: `windows.configFiles."komorebi/komorebi.json" = derivation;`
- Supports both individual files and directory trees
- Key is relative path under `.config/` by default, with optional target path override for apps that need non-standard locations
- Single activation hook iterates the attrset and copies all registered files
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

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SCAF-01 | Windows module directory exists at `users/michael/windows/` with aggregator `default.nix` | File structure pattern established; mirrors `users/michael/linux/` which uses flat import list |
| SCAF-02 | All Windows modules guarded by `hostSpec.isWSL` flag | `_1passwordcli.nix` provides exact pattern: `osConfig.hostSpec.isWSL or false` with `lib.mkIf` |
| SCAF-03 | `home.activation` sync hook copies configs from WSL to `/mnt/c/Users/michael/` | Two existing activation patterns in codebase: `entryBefore` (git) and `entryAfter` with `$DRY_RUN_CMD` (sops) |
| SCAF-04 | Sync hook guards writes with `/mnt/c` mount check | Shell guard pattern: `if [ -d /mnt/c ]; then ... fi` — standard bash, no Nix-specific complexity |
</phase_requirements>

---

## Summary

Phase 1 creates the scaffolding plumbing for WSL-to-Windows config delivery. The core work is: (1) a new Home Manager module at `users/michael/windows/default.nix` that declares a custom `windows.configFiles` option, guards everything on `hostSpec.isWSL`, and wires a `home.activation` hook; (2) adding that module's import to `hosts/nixos/wsl/common/default.nix` so ocelot and mantis both inherit it automatically. No app config files are staged in Phase 1 — the hook will iterate an empty attrset and no-op.

The codebase already has all the building blocks. The `hostSpec.isWSL` flag is defined in `modules/common/host-spec.nix` and set to `true` in WSL common config. The two existing `home.activation` usages (git's `entryBefore` and sops's `entryAfter` with `$DRY_RUN_CMD`) provide exact copy-paste reference patterns. The custom option needs to use `lib.types.attrsOf lib.types.path` to hold a mapping from relative config paths to store paths (derivations or files).

The key architectural insight: the `windows/default.nix` module runs inside Home Manager, so it accesses the NixOS `hostSpec` through `osConfig`. The `$DRY_RUN_CMD` prefix from the sops pattern should be used for all write operations so `home-manager switch --dry-run` works correctly. The mount guard (`[ -d /mnt/c ]`) must wrap the entire copy block to satisfy SCAF-04.

**Primary recommendation:** Model `windows/default.nix` directly on `users/michael/darwin/sops.nix` — same `osConfig` access pattern for the guard, same `entryAfter ["writeBoundary"]` hook with `$DRY_RUN_CMD`.

---

## Standard Stack

### Core (all already in the project)
| Library/Feature | Version | Purpose | Why Standard |
|-----------------|---------|---------|--------------|
| home-manager | master (nixos-unstable) | User config management, `home.activation` hook | Already in flake.nix |
| `lib.hm.dag` | (bundled with home-manager) | DAG ordering for activation scripts | Only correct way to order activation steps |
| `lib.mkIf` | (nixpkgs lib) | Conditional module inclusion | Established pattern in this repo |
| `lib.types.attrsOf` | (nixpkgs lib) | Custom option type for config file registry | Matches decision: attrset of path values |
| `lib.mkOption` | (nixpkgs lib) | Declaring custom Nix options | Used in `host-spec.nix` and `dock.nix` |

### No New Dependencies
This phase introduces zero new packages or flake inputs. It is pure Nix module authoring using libraries already present.

---

## Architecture Patterns

### Recommended File Structure

```
users/michael/windows/
├── default.nix          # Aggregator: option declaration + isWSL guard + activation hook
├── komorebi/
│   └── default.nix      # (Phase 2) — empty dir created in Phase 1 scaffold
├── whkd/
│   └── default.nix      # (Phase 3)
└── yasb/
    └── default.nix      # (Phase 4)
```

The aggregator `windows/default.nix` does three things in one file:
1. Declares `windows.configFiles` option
2. Guards the entire module body with `lib.mkIf osConfig.hostSpec.isWSL`
3. Implements the `home.activation` hook that iterates `config.windows.configFiles`

Phase 1 creates the directory structure but only needs `windows/default.nix`. The per-app subdirectories may be created as placeholders with no `default.nix` yet (they get imported in Phase 2+).

### Pattern 1: Custom Option Declaration (`attrsOf path`)

The `windows.configFiles` option is an attrset mapping relative destination paths to Nix store paths.

```nix
# Source: nixpkgs lib.types documentation + dock.nix pattern in this repo
options.windows = {
  configFiles = lib.mkOption {
    type = lib.types.attrsOf lib.types.path;
    default = { };
    description = ''
      Attrset of files to copy to the Windows config directory.
      Keys are relative paths under $WINDOWS_HOME/.config/
      Values are Nix store paths (files or directories).
      Example: { "komorebi/komorebi.json" = ./komorebi.json; }
    '';
  };
};
```

**Type choice rationale:** `attrsOf path` is the simplest type that satisfies all Phase 1 requirements. Keys are relative strings, values are Nix store paths. If a future phase needs per-entry metadata (e.g., `targetPath` override), the type can be widened to `attrsOf (submodule {...})` without breaking existing callers — the submodule approach from `dock.nix` shows this pattern.

**Alternative (submodule) if discretion opts for richer metadata:**
```nix
# Source: resources/lib/dock.nix in this repo
configFiles = lib.mkOption {
  type = lib.types.attrsOf (lib.types.submodule {
    options = {
      source = lib.mkOption { type = lib.types.path; };
      target = lib.mkOption {
        type = lib.types.str;
        description = "Override target path relative to WINDOWS_HOME (default: .config/<key>)";
        default = "";
      };
    };
  });
  default = { };
};
```

Start with `attrsOf path` (simpler); upgrade to submodule only if Phase 2 planning reveals a concrete need for `target` overrides.

### Pattern 2: `isWSL` Guard at Aggregator Level

```nix
# Source: users/michael/common/tui/_1passwordcli.nix (exact pattern)
{
  lib,
  osConfig ? { },   # Safe default for hosts without osConfig (non-NixOS, Darwin)
  config,
  ...
}:
let
  isWSL = osConfig.hostSpec.isWSL or false;
in
lib.mkIf isWSL {
  # All option declarations and config go here
  options.windows = { ... };
  config = { ... };   # or just inline the config attrs
}
```

**Important:** When using `lib.mkIf` at the top level of a module, the module must split `options` and `config` explicitly. The `lib.mkIf` wraps the `config` section but NOT the `options` section — options must always be declared unconditionally so other modules can reference the type. Correct structure:

```nix
{
  lib,
  osConfig ? { },
  config,
  ...
}:
let
  isWSL = osConfig.hostSpec.isWSL or false;
  cfg = config.windows;
in
{
  options.windows.configFiles = lib.mkOption { ... };

  config = lib.mkIf isWSL {
    home.activation.syncWindowsConfigs = ...;
  };
}
```

This ensures non-WSL hosts can evaluate the module (option exists) but the activation hook is never installed.

### Pattern 3: `home.activation` Hook with `$DRY_RUN_CMD` and Mount Guard

```nix
# Source: users/michael/darwin/sops.nix (entryAfter with $DRY_RUN_CMD)
# Source: users/michael/common/core/git/default.nix (entryBefore)
config = lib.mkIf isWSL {
  home.activation.syncWindowsConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/mnt/c" ]; then
      echo "[windows-sync] /mnt/c not mounted — skipping"
      exit 0
    fi

    WINDOWS_HOME="/mnt/c/Users/michael"
    failed=0

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (relPath: srcPath: ''
        dest="$WINDOWS_HOME/.config/${relPath}"
        $DRY_RUN_CMD mkdir -p "$(dirname "$dest")"
        if $DRY_RUN_CMD cp "${srcPath}" "$dest" 2>/dev/null; then
          echo "[windows-sync] ${relPath} -> synced"
        else
          echo "[windows-sync] ${relPath} -> FAILED" >&2
          failed=1
        fi
      '') cfg.configFiles
    )}

    if [ "$failed" -ne 0 ]; then
      echo "[windows-sync] Some files failed to copy — check output above" >&2
    fi
  '';
};
```

**Hook ordering decision:** `entryAfter ["writeBoundary"]` is the correct choice. The `writeBoundary` target runs after Home Manager writes all managed files to the store/profile, so any derivation paths referenced in `cfg.configFiles` are guaranteed to exist. The sops module uses `entryAfter ["setupSecrets"]` for a similar "copy something to a real path after it exists" pattern.

**`$DRY_RUN_CMD` behavior:** When home-manager runs with `--dry-run`, `$DRY_RUN_CMD` expands to `echo` instead of being empty, so all write commands are echoed but not executed. This matches the sops pattern exactly.

**Nix string interpolation in the hook:** The `lib.concatStringsSep` + `lib.mapAttrsToList` pattern generates the per-file copy commands at eval time (when `cfg.configFiles` is populated). In Phase 1, `cfg.configFiles` is `{}`, so the generated block is empty — the hook runs, checks the mount, finds no files to copy, and exits silently.

### Pattern 4: Import Integration

```nix
# In: hosts/nixos/wsl/common/default.nix (EXISTING FILE — add one line)
imports = [
  # ... existing imports ...
  ../../../../users/michael
  ../../../../users/michael/windows   # ADD THIS LINE
];
```

Wait — this import is at the NixOS system level, but `windows/default.nix` is a Home Manager module (it uses `home.activation`, `options.windows`, etc.). The correct integration point is NOT in the NixOS module, but in the Home Manager user config.

**Correct integration path:**

The `users/michael/default.nix` delegates to `users/michael/hosts/<hostname>.nix` via:
```nix
home-manager.users.${michael.username} = import (
  specialArgs.myLibs.relativeToRoot "users/${michael.username}/hosts/${config.networking.hostName}.nix"
);
```

Both `ocelot.nix` and `mantis.nix` exist at `users/michael/hosts/`. The windows module must be imported from within these host-specific Home Manager configs, OR from a shared location that both import.

**Best approach:** Add to a shared location that both ocelot and mantis already import. Looking at both host configs:
- Both import `../common/home.nix`, `../common/core`, `../common/tui`, `../common/shells`, `../common/ai-tools`, `../common/dev`

There is no existing "WSL common" Home Manager config. Options:
1. **Add import directly to both `ocelot.nix` and `mantis.nix`** — explicit, matches existing pattern of per-host files, no new abstraction
2. **Create `users/michael/common/wsl.nix`** and import it from both host files — DRY but adds abstraction

The CONTEXT.md says: "Import from WSL common config (`hosts/nixos/wsl/common/default.nix`)". But that is a NixOS module, not a Home Manager module. This is a clarification needed during planning:

**The windows module must be imported from the Home Manager layer, not the NixOS layer.**

The simplest approach matching the locked decision's intent: add `../windows` to the imports in BOTH `ocelot.nix` and `mantis.nix`. The `isWSL` guard inside `windows/default.nix` ensures it's a no-op on non-WSL hosts if ever imported elsewhere.

### Anti-Patterns to Avoid

- **Declaring options inside `lib.mkIf`:** Options must be declared unconditionally; only `config` sections go inside `mkIf`
- **Forgetting `osConfig ? {}`:** Without the default, Darwin and standalone home-manager evaluations crash when accessing `osConfig.hostSpec`
- **Using `entryBefore ["writeBoundary"]`:** The copy hook needs derivation paths to exist; must run AFTER `writeBoundary`, not before
- **Putting windows import in NixOS module layer:** `home.activation`, `options.*`, and `config.home.*` are Home Manager attributes — they must live in a Home Manager module, imported from the HM layer
- **Hardcoding the username in the hook:** Use `config.home.homeDirectory` pattern or pass through `windowsHomePath` variable derived at eval time, not runtime

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Activation ordering | Custom ordering hacks | `lib.hm.dag.entryAfter` / `entryBefore` | HM's DAG system handles all ordering correctly |
| Attrset iteration in shell | Manual shell arrays | `lib.mapAttrsToList` + `lib.concatStringsSep` in Nix | Nix generates the shell loop at eval time; cleaner than runtime iteration |
| Dry-run support | Custom `$1 == "--dry-run"` check | `$DRY_RUN_CMD` prefix | HM sets this automatically; hand-rolling breaks native `--dry-run` support |
| Directory creation | Per-file `mkdir` calls | `mkdir -p "$(dirname "$dest")"` in the loop | Handles nested paths without explicit directory pre-creation |

---

## Common Pitfalls

### Pitfall 1: Options Declared Inside `lib.mkIf`
**What goes wrong:** Nix evaluation error when another module references `config.windows.configFiles` — the option doesn't exist on non-WSL hosts.
**Why it happens:** Wrapping `options` in `lib.mkIf` makes them conditional; other modules can't type-check or merge values against a non-existent option.
**How to avoid:** Always declare `options.windows.configFiles` unconditionally at the top level; wrap only `config = lib.mkIf isWSL { ... }`.
**Warning signs:** `error: attribute 'windows' missing` on Darwin or non-WSL NixOS builds.

### Pitfall 2: Home Manager Module Imported from NixOS Layer
**What goes wrong:** Nix evaluation errors about unknown `home.*` attributes at the NixOS module level, or the module silently does nothing because HM attributes are ignored in NixOS context.
**Why it happens:** NixOS modules and HM modules have different attribute namespaces; importing a HM module into a NixOS `imports = []` list doesn't work.
**How to avoid:** Import `windows/default.nix` from within a Home Manager module (e.g., from `ocelot.nix` / `mantis.nix`), not from `hosts/nixos/wsl/common/default.nix`.
**Warning signs:** No `windows` namespace available in host config; activation hook never runs.

### Pitfall 3: Mount Check Timing
**What goes wrong:** `/mnt/c` exists as a directory stub even when Windows filesystem isn't mounted (WSL creates the mountpoint directory unconditionally).
**Why it happens:** WSL creates `/mnt/c` as a directory regardless of whether the Windows drive is mounted; checking `[ -d /mnt/c ]` alone may not be sufficient.
**How to avoid:** Check for a file that only exists when mounted: `[ -d /mnt/c/Users ]` or `[ -f /mnt/c/Windows/System32/cmd.exe ]`. The more reliable check is `[ -d /mnt/c/Users/michael ]` — that directory only exists when the drive is actually mounted and accessible.
**Warning signs:** Hook attempts copies and fails with permission errors instead of skipping silently.

### Pitfall 4: `$DRY_RUN_CMD` and Shell Variable Quoting
**What goes wrong:** `$DRY_RUN_CMD cp "$src" "$dest"` fails when `$src` contains spaces (Nix store paths don't, but it's still good practice).
**Why it happens:** `$DRY_RUN_CMD` expands to `echo` in dry-run mode, which prints the command correctly, but the actual `cp` call needs proper quoting.
**How to avoid:** Always quote the store path variables in the generated shell: `"${srcPath}"` in the Nix string interpolation ensures the path is embedded as a quoted literal in the generated shell script.

### Pitfall 5: Empty attrset iteration generates no shell code
**What goes wrong:** In Phase 1, `cfg.configFiles = {}` so `lib.mapAttrsToList` returns `[]` and `lib.concatStringsSep` returns `""`. The hook body is just the mount check with no copy commands — this is correct and expected.
**Why it happens:** Correct behavior — Phase 1 scaffold is intentionally empty.
**How to avoid:** Don't add placeholder files to test the hook. Trust the evaluation. Phase 2 will add the first real file.

---

## Code Examples

### Complete `windows/default.nix` (Phase 1 scaffold)

```nix
# Source: patterns from users/michael/common/tui/_1passwordcli.nix (osConfig guard)
#         and users/michael/darwin/sops.nix (entryAfter + $DRY_RUN_CMD)
{
  lib,
  osConfig ? { },
  config,
  ...
}:
let
  isWSL = osConfig.hostSpec.isWSL or false;
  cfg = config.windows;
  windowsHomePath = "/mnt/c/Users/michael";
in
{
  options.windows.configFiles = lib.mkOption {
    type = lib.types.attrsOf lib.types.path;
    default = { };
    description = ''
      Files to copy to the Windows config directory at activation time.
      Keys: relative path under $windowsHomePath/.config/
      Values: Nix store path (file or directory)
    '';
  };

  config = lib.mkIf isWSL {
    home.activation.syncWindowsConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "${windowsHomePath}" ]; then
        echo "[windows-sync] ${windowsHomePath} not accessible — skipping (is /mnt/c mounted?)"
        exit 0
      fi

      _failed=0

      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (relPath: srcPath: ''
          _dest="${windowsHomePath}/.config/${relPath}"
          $DRY_RUN_CMD mkdir -p "$(dirname "$_dest")"
          if $DRY_RUN_CMD cp "${srcPath}" "$_dest"; then
            echo "[windows-sync] ${relPath} -> synced"
          else
            echo "[windows-sync] ${relPath} -> FAILED" >&2
            _failed=1
          fi
        '') cfg.configFiles
      )}

      if [ "$_failed" -ne 0 ]; then
        echo "[windows-sync] Some files failed to copy" >&2
      fi
    '';
  };
}
```

### Integration in `ocelot.nix` and `mantis.nix`

```nix
# Source: existing pattern in users/michael/hosts/ocelot.nix
{ pkgs, ... }:
{
  imports = [
    ../common/home.nix
    ../common/core
    ../common/tui
    ../common/shells
    ../common/ai-tools
    ../common/dev
    ../windows          # ADD THIS LINE — windows sync scaffold
  ];
  # ... rest of host config unchanged ...
}
```

### Sub-module registration pattern (for Phase 2 reference)

```nix
# How Phase 2 komorebi module will register files:
# Source: decision in CONTEXT.md
{
  config,
  lib,
  pkgs,
  ...
}:
{
  windows.configFiles = {
    "komorebi/komorebi.json" = pkgs.writeText "komorebi.json" (builtins.toJSON {
      # ... config ...
    });
  };
}
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| WSL symlinks for config delivery | File copy via `home.activation` | Windows apps (komorebi) cannot follow LX symlinks — copy is mandatory (komorebi #854) |
| Per-module activation hooks | Single aggregated hook iterating attrset | Simpler, one hook to maintain, consistent behavior |
| `listOf` for file registry | `attrsOf` | Attrset allows idiomatic sub-module registration by key, no ordering concerns |

---

## Open Questions

1. **Mount guard specificity: `/mnt/c` vs `/mnt/c/Users/michael`**
   - What we know: WSL may create `/mnt/c` as a stub directory even when the drive isn't mounted
   - What's unclear: Whether checking `/mnt/c/Users/michael` is more reliable than `/mnt/c` or `/mnt/c/Users`
   - Recommendation: Use `[ ! -d "${windowsHomePath}" ]` (i.e., check `/mnt/c/Users/michael` directly) — this is more specific and will only be true when the user's home exists on the mounted drive

2. **Import location: host files vs new wsl-common HM module**
   - What we know: Both ocelot.nix and mantis.nix are identical; adding the same import to both is duplication
   - What's unclear: Whether the CONTEXT.md intent was "WSL common NixOS module" (wrong layer) or "shared HM config"
   - Recommendation: During planning, create a single `users/michael/common/wsl.nix` that both host files import — this is cleaner than duplicating the import line. The `isWSL` guard in `windows/default.nix` means it's safe to import anywhere.

3. **`$DRY_RUN_CMD` with `cp` of directory vs file**
   - What we know: `cp` behavior differs for files vs directories (need `-r` for directories)
   - What's unclear: Phase 1 has no files — but the option type is `path` which can be a directory
   - Recommendation: The activation hook should detect file vs directory and use `cp -r` for directories. Add a conditional in the generated shell: `if [ -d "${srcPath}" ]; then $DRY_RUN_CMD cp -r ...; else $DRY_RUN_CMD cp ...; fi`

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | None detected — this is a Nix dotfiles repo |
| Config file | N/A |
| Quick run command | `nixos-rebuild dry-build --flake .#ocelot` (build check only) |
| Full suite command | `nix flake check` + `nixos-rebuild dry-build --flake .#ocelot` + `nixos-rebuild dry-build --flake .#mantis` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SCAF-01 | `users/michael/windows/default.nix` exists and is importable | smoke | `nix eval .#nixosConfigurations.ocelot.config.home-manager.users.michael.windows.configFiles` | ❌ Wave 0 |
| SCAF-02 | Non-WSL hosts do not apply windows module | smoke | `nix eval .#darwinConfigurations.bowser.config.home-manager.users.michael.home.activation 2>&1 \| grep -v windows-sync` or `nixos-rebuild dry-build --flake .#ganon` | ❌ Wave 0 |
| SCAF-03 | Activation hook present in WSL host activation | smoke | `nix eval .#nixosConfigurations.ocelot.config.home-manager.users.michael.home.activation.syncWindowsConfigs` | ❌ Wave 0 |
| SCAF-04 | Mount guard exits silently when `/mnt/c` absent | manual-only | Cannot automate without WSL runtime; verify by reading activation script source | N/A |

**Note on SCAF-04:** The mount guard behavior is runtime-dependent (needs actual `/mnt/c` absence). The nix build-time check is: verify the guard condition string appears in the generated activation script. Full runtime validation requires manual `home-manager switch` on a WSL host with `/mnt/c` unmounted.

### Sampling Rate
- **Per task commit:** `nix flake check` (syntax + basic eval)
- **Per wave merge:** `nixos-rebuild dry-build --flake .#ocelot && nixos-rebuild dry-build --flake .#mantis`
- **Phase gate:** Both WSL host dry-builds pass + non-WSL host (e.g., ganon) still builds before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] No automated test framework — Nix flake evaluation is the test harness
- [ ] Verify: `nix eval` commands above work from project root with flake
- [ ] Manual test procedure documented for SCAF-04 (mount guard)

---

## Sources

### Primary (HIGH confidence)
- Codebase: `users/michael/common/tui/_1passwordcli.nix` — `osConfig.hostSpec.isWSL or false` pattern
- Codebase: `users/michael/darwin/sops.nix` — `home.activation` with `entryAfter`, `$DRY_RUN_CMD`, mount-existence check pattern
- Codebase: `users/michael/common/core/git/default.nix` — `home.activation.entryBefore` pattern
- Codebase: `resources/lib/dock.nix` — `lib.types.submodule` and `lib.mkOption` pattern for custom options
- Codebase: `modules/common/host-spec.nix` — `hostSpec.isWSL` option definition
- Codebase: `hosts/nixos/wsl/common/default.nix` — WSL common NixOS module, `isWSL = true` set here
- Codebase: `users/michael/hosts/ocelot.nix`, `mantis.nix` — HM import structure for WSL hosts
- Codebase: `users/michael/linux/default.nix` — aggregator pattern to mirror

### Secondary (MEDIUM confidence)
- Home Manager docs: `lib.hm.dag.entryAfter ["writeBoundary"]` is the standard "after all files written" hook target
- Nix lib docs: `lib.types.attrsOf lib.types.path` is appropriate for string-keyed store path registries

### Tertiary (LOW confidence)
- WSL mount behavior: `/mnt/c` may exist as stub even unmounted — based on common WSL knowledge, not empirically verified in this environment

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all libraries are already in use in the project; zero new dependencies
- Architecture patterns: HIGH — directly derived from existing codebase patterns with exact file references
- Pitfalls: MEDIUM — module layering pitfall (NixOS vs HM) is HIGH confidence; mount guard specificity is MEDIUM (WSL internals)

**Research date:** 2026-03-08
**Valid until:** 2026-06-08 (stable Nix/HM APIs — no fast-moving ecosystem here)
