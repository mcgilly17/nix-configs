# Coding Conventions

**Analysis Date:** 2026-03-08

## Overview

This codebase consists primarily of **Nix** configuration language (~45 modules) with **JavaScript** utility scripts for GSD (Get Shit Done) workflow integration. No TypeScript or traditional testing frameworks are in use.

## Nix Conventions

### Module Structure

**Pattern:** Argument destructuring with ellipsis for module composition

```nix
{ config, lib, pkgs, inputs, outputs, myLibs, specialArgs, ... }:
```

Key arguments used:
- `config` - Reference to entire system configuration
- `lib` - NixOS library functions (mkOption, mkIf, etc.)
- `pkgs` - Package set from nixpkgs
- `inputs` - Flake inputs (home-manager, darwin, etc.)
- `outputs` - Custom outputs from flake.nix
- `myLibs` - Project-specific library helpers
- `specialArgs` - Custom arguments passed through the system

**File:** `modules/common/core.nix`, `modules/nixos/common.nix`

### Option Declaration Pattern

**Pattern:** Use `lib.mkOption` with comprehensive metadata

```nix
options.hostSpec = lib.mkOption {
  default = { };
  type = lib.types.submodule {
    options = {
      hostName = lib.mkOption {
        type = lib.types.str;
        description = "The hostname of the host";
        default = config.networking.hostName or "";
      };
    };
  };
};
```

**File:** `modules/common/host-spec.nix`

This pattern ensures:
- Clear type information
- Descriptions for documentation
- Sensible defaults
- Composability across hosts

### Conditional Configuration

**Pattern:** Use `lib.mkIf` for platform-specific or flag-based configurations

```nix
keyd = lib.mkIf (!config.hostSpec.isWSL) {
  enable = true;
  keyboards.default = { ... };
};

_1password.enable = !config.hostSpec.isWSL;
```

**File:** `modules/nixos/common.nix`

This enables:
- Clean separation of WSL vs. native Linux configs
- GPU-specific module loading
- Desktop vs. minimal host differentiation

### Module Imports

**Pattern:** Explicit relative imports with helper functions

```nix
imports = [
  inputs.home-manager.nixosModules.home-manager
  inputs.catppuccin.nixosModules.catppuccin
  (myLibs.relativeToRoot "modules/common/core.nix")
  ./tailscale.nix
];
```

**File:** `modules/nixos/common.nix`

Convention:
- Use `myLibs.relativeToRoot` for cross-project references (enables flake flexibility)
- Use relative `./` for sibling modules
- Use `inputs.*` for flake dependencies

### Naming Conventions

**Files:**
- Lowercase with hyphens: `sops.nix`, `tailscale.nix`, `host-spec.nix`
- Grouped by OS: `modules/nixos/`, `modules/darwin/`, `modules/common/`
- Functional naming: `keyd.nix` (what it configures), not `keyboard-setup.nix`

**Attributes:**
- camelCase for option names: `enableCompletion`, `passwordAuthentication`, `allowUnfree`
- kebab-case for command-line flags: `permit-root-login` → `PermitRootLogin` (SSH format varies)
- prefixed booleans: `enable`, `isWSL`, `hasGPU`, `isMinimal`

**Options:**
- Boolean flags prefixed with `is` or `has`: `isWSL`, `isServer`, `hasGPU`
- Resource limits in plain units: `min-free = 128000000` (bytes), `timestamp_timeout=120` (seconds)
- Comments explain purpose: `# Only ask for password every 2 hours`

### Comments

**When to comment:**
- **Configuration intent:** Why a particular setting exists
  - `# For nixos-anywhere, hosts can override` (allowability, not syntax)
  - `# Keep SSH agent forwarding working` (why `SSH_AUTH_SOCK` is preserved)
  - `# Disable old garbage collection since nh handles it now` (rationale for removal)
- **Non-obvious defaults:** Explain departures from NixOS defaults
  - `# warn-dirty = false` (prevents noise during development)

**When NOT to comment:**
- Self-explanatory configuration: `openssh.enable = true;`
- Standard package lists: No need to comment each archive/text tool
- Obvious option combinations: `git` is used by nix flakes (standard practice)

**Formatting:**
- Inline comments for single-line clarifications: `connect-timeout = 5;  # Reasonable timeout`
- Block comments for multi-line rationale

### Module Organization

**Pattern:** Logical grouping by purpose, not by length

Structure in `modules/nixos/`:
- `common.nix` - Cross-platform core (Home Manager, services, SSH, etc.)
- `sops.nix` - Secrets management
- `tailscale.nix` - VPN configuration
- `wsl.nix` - WSL-specific settings
- `docker.nix` - Container runtimes
- `default.nix` - Imports umbrella for host-specific selection

**File:** `modules/nixos/` directory structure

### Attribute Set Style

**Pattern:** Structured with clear nesting

```nix
services = {
  avahi = {
    enable = true;
    nssmdns4 = true;
  };
  keyd = lib.mkIf (!config.hostSpec.isWSL) {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "overload(control, esc)";
      };
    };
  };
};
```

Convention:
- One attribute per line when nesting
- Explicit closing braces aligned with opening
- Conditionals wrap entire blocks when possible (not individual attributes)

### Imports in Modules

**Pattern:** Always import dependencies at top, before main body

```nix
{ config, lib, pkgs, inputs, ... }:
{
  imports = [ ... ];
  options = { ... };
  config = { ... };
}
```

Three-part module structure consistently applied across all modules.

## JavaScript Conventions

### File Organization

**Files:** `/.claude/hooks/*.js`

Patterns observed:
- **Shebang:** `#!/usr/bin/env node` for executable scripts
- **Module type:** CommonJS (`require`, no ES6 imports)
- **Scope:** Small utility scripts (81–141 lines) with focused responsibility

**File:** `.claude/hooks/gsd-check-update.js`, `gsd-context-monitor.js`, `gsd-statusline.js`

### Naming Patterns

**Functions:**
- camelCase: `detectConfigDir()`, `execSync()`, `readFileSync()`
- Descriptive action words: `detect`, `check`, `spawn`, `exit`

**Variables:**
- camelCase for local/config: `cacheDir`, `projectVersionFile`, `metricsPath`, `stdinTimeout`
- CONSTANT_CASE for thresholds: `WARNING_THRESHOLD`, `CRITICAL_THRESHOLD`, `STALE_SECONDS`, `DEBOUNCE_CALLS`
- Plural for arrays/collections: `files`, `archives`, `warnData.callsSinceWarn`

**Patterns:**
- `let` for mutable state (prefer for non-const reassignment)
- `const` for immutable bindings
- Short-lived variables: `cwd`, `dir`, `ctx`, `bar`, `msg`

### Code Style

**Formatting:** No explicit formatter configured (no `.prettierrc` or `.eslintrc`)

Observed patterns from codebase:
- **Indentation:** 2 spaces
- **Line length:** ~100 characters (observed in examples)
- **Semicolons:** Always present
- **Quotes:** Single quotes for strings (except JSON)
- **Spacing:** Space after `if/for/while`, space around operators

Example from `gsd-statusline.js`:
```javascript
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
process.stdin.setEncoding('utf8');
if (remaining != null) {
  const usableRemaining = Math.max(0, ((remaining - AUTO_COMPACT_BUFFER_PCT) / (100 - AUTO_COMPACT_BUFFER_PCT)) * 100);
}
```

### Error Handling

**Pattern:** Silent failures with fallbacks, never throw

```javascript
try {
  const metrics = JSON.parse(fs.readFileSync(metricsPath, 'utf8'));
} catch (e) {
  // Silent fail -- never block tool execution
  process.exit(0);
}
```

**Files:** All three JS files use identical try-catch pattern

**Rationale:** These are hooks in Claude Code IDE. Errors must not disrupt the user's tool execution. Instead:
1. Log silently (no stderr spam)
2. Exit cleanly with code 0
3. Provide graceful degradation (statusline still renders, context monitoring continues)

### Async Patterns

**Pattern:** Use `require('child_process').spawn()` for background operations

```javascript
const child = spawn(process.execPath, ['-e', `
  // inline script
`], {
  stdio: 'ignore',
  windowsHide: true,
  detached: true  // Required on Windows for proper process detachment
});
child.unref();  // Allow parent to exit even if child is running
```

**File:** `gsd-check-update.js` (lines 44–81)

This pattern ensures:
- Non-blocking updates in IDE hooks
- Cross-platform compatibility (windowsHide for Windows)
- Parent process not held up by child

### Stream Processing

**Pattern:** Accumulate stdin, then parse

```javascript
let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  const data = JSON.parse(input);
  // process
});
```

**File:** `gsd-context-monitor.js`, `gsd-statusline.js`

Always includes timeout guard to prevent hangs:
```javascript
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
```

### Environment Detection

**Pattern:** Multi-fallback config directory detection

```javascript
function detectConfigDir(baseDir) {
  const envDir = process.env.CLAUDE_CONFIG_DIR;
  if (envDir && fs.existsSync(path.join(envDir, 'get-shit-done', 'VERSION'))) {
    return envDir;
  }
  for (const dir of ['.config/opencode', '.opencode', '.gemini', '.claude']) {
    if (fs.existsSync(path.join(baseDir, dir, 'get-shit-done', 'VERSION'))) {
      return path.join(baseDir, dir);
    }
  }
  return envDir || path.join(baseDir, '.claude');
}
```

**File:** `gsd-check-update.js` (lines 15–27)

Supports multiple AI code editors (Claude Code, OpenCode, Gemini) and custom config via `CLAUDE_CONFIG_DIR` environment variable.

### Comments in JavaScript

**When to comment:**
- **Hook mechanism:** Explain what hook/event this script handles
  - `// PostToolUse hook (Gemini uses AfterTool)`
  - `// SessionStart hook - runs once per session`
- **Non-obvious logic:** State machine transitions, debouncing logic
  ```javascript
  // Severity escalation (WARNING -> CRITICAL) bypasses debounce
  const severityEscalated = currentLevel === 'critical' && warnData.lastLevel === 'warning';
  ```
- **Thresholds and magic numbers:**
  ```javascript
  const WARNING_THRESHOLD = 35;  // remaining_percentage <= 35%
  const CRITICAL_THRESHOLD = 25; // remaining_percentage <= 25%
  ```
- **Platform/environment notes:**
  ```javascript
  // Respect CLAUDE_CONFIG_DIR for custom config directory setups (#870)
  // Timeout guard: if stdin doesn't close within 3s (e.g. pipe issues on Windows/Git Bash)
  ```

**When NOT to comment:**
- Straightforward variable assignments: `const cwd = process.cwd();`
- Standard library calls: `fs.existsSync()`, `JSON.parse()`
- Obvious conditionals

### No Testing

**Note:** These utility scripts have no test files. As single-file utilities focused on integration:
- Tested via integration with Claude Code IDE
- Manual verification of output format
- No unit test framework in use

---

## Cross-Language Patterns

### Configuration as Code

Both Nix and JavaScript follow "configuration as code" principles:
- **Nix:** Declarative system configuration with types
- **JavaScript:** Imperative configuration detection and management
- **Result:** Reproducible, version-controlled system state

### Error Handling Philosophy

**Principle:** Fail gracefully, never block execution

- **Nix:** Type system prevents invalid configurations at evaluation time
- **JavaScript:** Try-catch silently, exit cleanly, preserve user experience

### Documentation

- **Nix:** Use `description` fields in options; self-documenting through option declarations
- **JavaScript:** Use inline comments sparingly; code should be obvious
- **Both:** Clarify *why* not *what* (reasoning, intent, constraints)

---

*Convention analysis: 2026-03-08*
