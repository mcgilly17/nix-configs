# Testing Patterns

**Analysis Date:** 2026-03-08

## Overview

This codebase has **no formal testing framework** installed or in use. The project consists of:
- **Nix configuration language** (declarative system configuration, validated at evaluation time by the Nix type system)
- **JavaScript utility scripts** (small integration hooks, 81–141 lines each, tested through integration with Claude Code IDE)

Given this composition, traditional test frameworks (Jest, Vitest, Mocha) are not applicable.

## Nix Configuration Validation

### How Nix Provides Testing

The Nix language is strongly typed and declaratively configured. Testing happens at **evaluation time**, not runtime:

1. **Type System:**
   ```nix
   options.hostSpec = lib.mkOption {
     type = lib.types.submodule {
       options = {
         hostName = lib.mkOption {
           type = lib.types.str;  # Type must be string
           description = "...";
         };
         isWSL = lib.mkOption {
           type = lib.types.bool;  # Type must be boolean
         };
       };
     };
   };
   ```

   **File:** `modules/common/host-spec.nix`

   Type violations are caught during `nix flake check` or `nixos-rebuild` before deployment.

2. **Configuration Composition:**
   ```nix
   imports = [
     inputs.home-manager.nixosModules.home-manager
     (myLibs.relativeToRoot "modules/common/core.nix")
     ./tailscale.nix
   ];
   ```

   **File:** `modules/nixos/common.nix`

   Missing modules, circular dependencies, and unresolved references are caught at build time.

3. **Conditional Validation:**
   ```nix
   keyd = lib.mkIf (!config.hostSpec.isWSL) {
     enable = true;
   };
   ```

   **File:** `modules/nixos/common.nix`

   Conditional logic is validated in context; invalid states (e.g., enabling keyd on WSL) are prevented by conditions.

### Manual Validation Workflow

**Build-time checks:**
```bash
# Validate configuration without rebuilding
nix flake check

# Evaluate and catch type errors
nixos-rebuild switch --flake .#hostname
```

**Files checked:**
- `flake.nix` - Flake structure and inputs
- `modules/**/*.nix` - Module definitions
- `hosts/**/*.nix` - Host configurations
- `users/**/*.nix` - User configurations (via Home Manager)

**Common errors caught:**
- Type mismatches (e.g., string where bool expected)
- Missing required options
- Infinite recursion in module composition
- Unresolved module imports
- Attribute access on wrong types

### Known Limitations

**No runtime testing:**
- Cannot verify actual system behavior post-deployment
- No automated rollback testing if configuration fails
- SSH connectivity and service startup are tested manually

**No property-based testing:**
- Cannot verify "all boolean options can be combined safely"
- No fuzzing of configuration parameter ranges

## JavaScript Utility Scripts

### Testing Strategy

The three JavaScript utility scripts are **integration-tested** through the Claude Code IDE, not through automated unit tests.

**Scripts:**
- `/.claude/hooks/gsd-check-update.js` - Version checking
- `/.claude/hooks/gsd-context-monitor.js` - Context warning system
- `/.claude/hooks/gsd-statusline.js` - IDE statusline display

### Integration Testing Approach

**File:** `.claude/settings.json`

```json
{
  "hooks": {
    "SessionStart": [{"hooks": [{"type": "command", "command": "node .claude/hooks/gsd-check-update.js"}]}],
    "PostToolUse": [{"hooks": [{"type": "command", "command": "node .claude/hooks/gsd-context-monitor.js"}]}]
  },
  "statusLine": {"type": "command", "command": "node .claude/hooks/gsd-statusline.js"}
}
```

**How testing works:**
1. **gsd-check-update.js** - Runs on IDE session start
   - Validates: npm registry connectivity, file I/O for version cache
   - Manual check: Run IDE, check `.claude/cache/gsd-update-check.json` exists with valid JSON

2. **gsd-context-monitor.js** - Runs after each tool execution
   - Validates: Stdin parsing, JSON structure, thresholds and warnings
   - Manual check: Use many tools in one session, verify warnings appear when context approaches limits

3. **gsd-statusline.js** - Runs continuously (provides IDE statusline)
   - Validates: Output format, color codes, metrics display
   - Manual check: Open IDE, verify statusline shows model name, context percentage, current task

### Manual Testing Checklist

#### gsd-check-update.js

- [ ] IDE starts fresh session → no error in console
- [ ] `.claude/cache/` directory created if missing
- [ ] On second run, `gsd-update-check.json` contains:
  - `update_available: boolean`
  - `installed: string` (semantic version)
  - `latest: string` (semantic version or "unknown")
  - `checked: number` (unix timestamp)
- [ ] Check runs in background (doesn't block IDE startup)
- [ ] Network timeouts handled (10s limit) → graceful fallback to "unknown"

#### gsd-context-monitor.js

- [ ] Tool execution doesn't error when file is missing
- [ ] Metrics file read from `/tmp/claude-ctx-{session_id}.json`
- [ ] Warnings emitted when:
  - Remaining context ≤ 35% → "WARNING" level
  - Remaining context ≤ 25% → "CRITICAL" level
- [ ] Debouncing works:
  - First warning: Always shown
  - Subsequent warnings: Only shown after 5 tool uses
  - Severity escalation (WARNING → CRITICAL): Shown immediately, bypasses debounce
- [ ] GSD detection works:
  - Checks for `.planning/STATE.md` in working directory
  - Different message if GSD is active vs. inactive
- [ ] Stale metrics ignored (> 60 seconds old)
- [ ] Silent failure if metrics file is corrupted JSON
- [ ] Output format: `hookSpecificOutput` with `additionalContext` string

#### gsd-statusline.js

- [ ] Displays model name (e.g., "Claude", "Gemini")
- [ ] Shows context usage percentage: `0–100%` (scaled to usable context, not raw)
- [ ] Draws progress bar: `█` filled, `░` empty (10 segments)
- [ ] Color-codes context:
  - Green: < 50%
  - Yellow: 50–64%
  - Orange: 65–79%
  - Red blink: ≥ 80%
- [ ] Shows current task name if GSD active (reads from todos file)
- [ ] Shows directory basename
- [ ] Shows GSD update notification when available
- [ ] Format matches: `[gsd-update] | model | task | directory | [context-bar]`
- [ ] Metrics bridge file written to `/tmp/claude-ctx-{session_id}.json`

### Test Data

**No fixture files.** Data is generated at runtime:

- **metrics.json** - Generated by statusline hook
- **gsd-update-check.json** - Generated by update check hook
- **warned.json** - Generated by context monitor hook

All files are ephemeral and cleared on IDE restart (live in `/tmp`).

### Error Handling Validation

**Pattern:** All three scripts silently fail on errors

**Test**: Deliberately corrupt files in `/tmp` and verify:
1. Hook doesn't crash IDE
2. Hook exits with code 0
3. User sees no error message
4. Next tool execution succeeds normally

Examples of expected silent failures:
- Missing metrics file → exit silently (fresh session)
- Corrupted JSON → catch, skip parsing, exit(0)
- Stale metrics → exit silently (file older than threshold)
- stdin timeout → exit(0) after 3 seconds
- npm registry unreachable → latestversion set to "unknown"

### No Unit Testing

**Why no Jest/Vitest?**

1. **Scripts are tiny** - Each under 200 lines; minimal logic to test
2. **Integration-critical** - Must work with Claude Code IDE hooks; unit tests can't validate this
3. **File system and network I/O** - Heavily I/O bound; mocking would obscure real behavior
4. **Quick iteration** - Manual testing in IDE is faster than test infrastructure
5. **No shared libraries** - No code reuse requiring regression tests

### Coverage

**Estimated coverage by manual testing:**
- **gsd-check-update.js**: Happy path (update available, not available), network timeout, file I/O
- **gsd-context-monitor.js**: All threshold transitions, debouncing, stale data, GSD detection
- **gsd-statusline.js**: All color transitions, metrics caching, todos parsing, edge cases (no metrics, corrupted files)

**Gaps:**
- Can't test concurrent IDE sessions (multiple `session_id` values simultaneously)
- Can't test file permission errors (assume Unix-like, user has `~/.claude/` access)
- Can't test very large JSON files (metrics, todos)

## Validation Commands

### Nix Configuration

```bash
# Validate flake outputs and module structure
nix flake check

# Evaluate configuration for a specific host (catches type errors)
nix eval --json .#nixosConfigurations.hostname.config.hostSpec

# Dry-run rebuild (check for errors without modifying system)
nixos-rebuild dry-run --flake .#hostname

# Full rebuild on the system
nixos-rebuild switch --flake .#hostname
```

### JavaScript Scripts

```bash
# Validate Node.js syntax
node -c .claude/hooks/gsd-check-update.js
node -c .claude/hooks/gsd-context-monitor.js
node -c .claude/hooks/gsd-statusline.js

# Manual testing: Run hook in isolation
echo '{"session_id":"test-123"}' | node .claude/hooks/gsd-context-monitor.js

# Check for unhandled errors in IDE integration
# (Run inside Claude Code IDE and observe console)
```

## Recommended Testing for New Code

### If adding Nix modules:

1. **Validate types:**
   ```bash
   nix flake check
   ```

2. **Test configuration evaluation:**
   ```bash
   nix eval --json .#nixosConfigurations.hostname.config.newModule
   ```

3. **Manual verification:**
   - Boot the affected host
   - Verify services start: `systemctl status service-name`
   - Verify config files written: `cat /etc/config-file`
   - Verify conditionals work: Test on both WSL and native Linux

### If adding JavaScript hooks:

1. **Syntax check:**
   ```bash
   node -c path/to/hook.js
   ```

2. **Run in isolation:**
   ```bash
   # For stdin-based hooks
   echo '{"session_id":"test-123"}' | node .claude/hooks/hook-name.js

   # For file-based hooks
   node .claude/hooks/hook-name.js
   ```

3. **Integration test:**
   - Copy hook to `.claude/hooks/`
   - Update `.claude/settings.json` to register hook
   - Restart Claude Code IDE
   - Verify output appears in appropriate location (statusline, console, context warnings)

## Test Configuration Files

**None exist.** No `jest.config.js`, `vitest.config.ts`, `.mocharc.json`, or similar.

The only test-adjacent file is the Nix flake itself, which includes inputs for testing frameworks if they were ever added:

**File:** `flake.nix` - No testing framework inputs

---

*Testing analysis: 2026-03-08*
