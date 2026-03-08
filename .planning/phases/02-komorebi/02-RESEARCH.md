# Phase 2: Komorebi - Research

**Researched:** 2026-03-08
**Domain:** komorebi tiling WM JSON configuration, Nix `builtins.toJSON` pattern, Catppuccin theming, float rules, multi-monitor workspaces
**Confidence:** HIGH

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| KOMO-01 | `komorebi.json` generated via `builtins.toJSON` with workspaces, layouts, borders, gaps | Full schema documented — exact field names and types confirmed from official schema.json |
| KOMO-02 | Application-specific float rules for common Windows apps (Settings, Task Manager, dialogs) | Exact class identifiers confirmed from official applications.yaml (TaskManagerWindow, Shell_Dialog, OperationStatusWindow); float rules live in `floating_applications` array in komorebi.json |
| KOMO-03 | Catppuccin Mocha theme applied via native `"theme"` config key | Native Catppuccin support confirmed: `{ "palette": "Catppuccin", "name": "Mocha" }` with Catppuccin color names for optional accents |
| KOMO-04 | Per-monitor workspace configuration support | `monitors` array with per-element workspace config confirmed; `display_index_preferences` available for serial-based ordering but optional (v2 requirement covers this) |
</phase_requirements>

---

## Summary

Phase 2 creates `users/michael/windows/komorebi/default.nix` — a Home Manager sub-module that registers a generated `komorebi.json` with the `windows.configFiles` system from Phase 1. The Nix module constructs a Nix attrset representing the full komorebi configuration and serializes it via `builtins.toJSON` wrapped in `pkgs.writeText`, then registers it as `windows.configFiles."komorebi/komorebi.json"`.

The komorebi JSON schema is well-documented and straightforward. The native Catppuccin support uses `{ "palette": "Catppuccin", "name": "Mocha" }` in the `theme` key. Float rules live directly in `komorebi.json` under `floating_applications` (not in `applications.json` which is managed by `komorebic fetch-asc` and would be overwritten). The `monitors` array holds per-monitor workspace arrays indexed by position (0 = primary, 1 = secondary). The per-monitor structure is the same for single and multi-monitor — single-monitor setup uses a one-element array.

The critical operational detail: komorebi looks for its config at `$Env:KOMOREBI_CONFIG_HOME` if set, otherwise `$Env:USERPROFILE`. The Phase 1 sync hook deposits files under `/mnt/c/Users/michael/.config/`, making the Nix key `"komorebi/komorebi.json"` resolve to `/mnt/c/Users/michael/.config/komorebi/komorebi.json` on the Windows side. The user must set `KOMOREBI_CONFIG_HOME = %USERPROFILE%\.config\komorebi` in their Windows environment (PowerShell profile or system env) for komorebi to find the file there. The `app_specific_configuration_path` in the generated JSON should point to `$Env:KOMOREBI_CONFIG_HOME/applications.json`.

**Primary recommendation:** Build `windows/komorebi/default.nix` as a Nix module that assembles the config attrset (workspaces, theme, borders, float rules) and registers it via `windows.configFiles."komorebi/komorebi.json" = pkgs.writeText "komorebi.json" (builtins.toJSON komorebiConfig)`.

---

## Standard Stack

### Core
| Library/Tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| `builtins.toJSON` | (Nix built-in) | Serialize Nix attrset to JSON string | Built into every Nix evaluation; no extra dependency |
| `pkgs.writeText` | (nixpkgs) | Create a Nix store file from a string | Standard pattern for generating config files in Nix; produces a derivation path |
| `windows.configFiles` | (Phase 1) | Register the generated file for sync | The sync pipeline already wired in Phase 1 |

### No New Dependencies
Phase 2 introduces zero new flake inputs or packages. It is pure Nix module authoring using `builtins.toJSON` and `pkgs.writeText`.

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `builtins.toJSON` + `pkgs.writeText` | `pkgs.writeTextFile` | Both work; `pkgs.writeText` is simpler one-liner |
| `builtins.toJSON` | `pkgs.formats.json { }.generate` | `pkgs.formats.json` is cleaner for large configs but adds indirection; `builtins.toJSON` is more readable for this project's size |
| Float rules in `komorebi.json` | Float rules in `applications.json` | `applications.json` is managed by `komorebic fetch-asc` and gets overwritten; komorebi.json is the only safe place for custom rules |

**Installation:** No new packages needed.

---

## Architecture Patterns

### Recommended File Structure

```
users/michael/windows/
├── default.nix          # (Phase 1) — option declaration + isWSL guard + activation hook
└── komorebi/
    └── default.nix      # (Phase 2) — komorebi.json generation and registration
```

The `windows/komorebi/default.nix` module must be imported by `windows/default.nix` (the aggregator). The aggregator already has the `isWSL` guard, so the komorebi sub-module does not need its own guard — it can freely set `windows.configFiles` unconditionally. The guard in the parent module ensures the sync hook only runs on WSL.

### Pattern 1: Sub-module File Registration

The canonical pattern for Phase 2 (established in Phase 1 RESEARCH.md):

```nix
# users/michael/windows/komorebi/default.nix
# Source: Phase 1 RESEARCH.md "Sub-module registration pattern"
{
  lib,
  pkgs,
  ...
}:
let
  komorebiConfig = {
    "$schema" = "https://raw.githubusercontent.com/LGUG2Z/komorebi/v0.1.40/schema.json";
    app_specific_configuration_path = "$Env:KOMOREBI_CONFIG_HOME/applications.json";
    # ... rest of config ...
  };
in
{
  windows.configFiles."komorebi/komorebi.json" =
    pkgs.writeText "komorebi.json" (builtins.toJSON komorebiConfig);
}
```

The aggregator `windows/default.nix` must add the import:

```nix
# In users/michael/windows/default.nix — add to imports list:
imports = [
  ./komorebi
];
```

### Pattern 2: komorebi.json Structure — Complete Schema

All fields verified against official schema.json (v0.1.40):

```nix
# Full komorebi config attrset in Nix — serializes to valid komorebi.json
{
  "$schema" = "https://raw.githubusercontent.com/LGUG2Z/komorebi/v0.1.40/schema.json";
  app_specific_configuration_path = "$Env:KOMOREBI_CONFIG_HOME/applications.json";
  window_hiding_behaviour = "Cloak";      # Hides unfocused windows cleanly
  cross_monitor_move_behaviour = "Insert";
  default_workspace_padding = 10;          # pixels around workspace edge
  default_container_padding = 10;          # pixels between tiled windows
  border = true;
  border_width = 8;
  border_offset = -1;

  # Catppuccin Mocha theme — native support, no custom colors needed
  theme = {
    palette = "Catppuccin";
    name = "Mocha";
    bar_accent = "Sapphire";              # Sapphire accent matches Linux side
    single_border = "Sapphire";           # Focused single window
    stack_border = "Green";              # Stacked windows
    floating_border = "Yellow";          # Floating windows
    monocle_border = "Mauve";            # Monocle layout
    unfocused_border = "Surface1";       # Unfocused windows
  };

  # Float rules — define in komorebi.json, NOT in applications.json
  floating_applications = [
    # Windows Settings (SystemSettings.exe)
    { kind = "Exe"; id = "SystemSettings.exe"; matching_strategy = "Equals"; }
    # Task Manager
    { kind = "Class"; id = "TaskManagerWindow"; matching_strategy = "Legacy"; }
    # File copy/move operation dialogs (Windows Explorer)
    { kind = "Class"; id = "OperationStatusWindow"; matching_strategy = "Legacy"; }
    # Control Panel
    { kind = "Title"; id = "Control Panel"; matching_strategy = "Equals"; }
  ];

  # Per-monitor workspace configuration
  # monitors[0] = primary monitor, monitors[1] = secondary, etc.
  monitors = [
    {
      workspaces = [
        { name = "I";   layout = "BSP"; }
        { name = "II";  layout = "VerticalStack"; }
        { name = "III"; layout = "HorizontalStack"; }
        { name = "IV";  layout = "Grid"; }
        { name = "V";   layout = "Monocle"; }
      ];
    }
    # Second monitor (only used when two monitors connected — komorebi ignores extra config entries)
    {
      workspaces = [
        { name = "1"; layout = "BSP"; }
        { name = "2"; layout = "VerticalStack"; }
        { name = "3"; layout = "HorizontalStack"; }
      ];
    }
  ];
}
```

### Pattern 3: Catppuccin Theme Key

The `theme` key uses a tagged union in the JSON schema:

```json
{
  "theme": {
    "palette": "Catppuccin",
    "name": "Mocha"
  }
}
```

Valid Catppuccin `name` values: `"Frappe"`, `"Latte"`, `"Macchiato"`, `"Mocha"`.

Optional color override keys use Catppuccin color names:
`Rosewater`, `Flamingo`, `Pink`, `Mauve`, `Red`, `Maroon`, `Peach`, `Yellow`, `Green`, `Teal`, `Sky`, `Sapphire`, `Blue`, `Lavender`, `Text`, `Subtext1`, `Subtext0`, `Overlay2`, `Overlay1`, `Overlay0`, `Surface2`, `Surface1`, `Surface0`, `Base`, `Mantle`, `Crust`

Defaults without overrides:
- `single_border`: Blue
- `stack_border`: Green
- `floating_border`: Yellow
- `monocle_border`: Pink
- `unfocused_border`: Base
- `bar_accent`: Blue

### Pattern 4: Float Rules Location

**CRITICAL:** Float rules MUST be placed in `komorebi.json` under `floating_applications`, NOT in `applications.json`. The `applications.json` file is managed by `komorebic fetch-asc` which downloads the community configuration from the LGUG2Z/komorebi-application-specific-configuration repo and **overwrites** any custom rules. Edits to `applications.json` will be lost on next fetch.

Float rules in `komorebi.json` are persistent and user-controlled:

```nix
floating_applications = [
  # Simple exe match
  { kind = "Exe"; id = "SystemSettings.exe"; matching_strategy = "Equals"; }

  # Class match (Legacy strategy = exact Windows class string lookup)
  { kind = "Class"; id = "TaskManagerWindow"; matching_strategy = "Legacy"; }

  # Composite rule (array of conditions = AND — all must match)
  # Example: float Blender splash screens only, not main window
  [
    { kind = "Exe"; id = "blender.exe"; matching_strategy = "Equals"; }
    { kind = "Title"; id = "Blender"; matching_strategy = "DoesNotContain"; }
  ]
];
```

Valid `kind` values: `"Exe"`, `"Class"`, `"Title"`, `"Path"`
Valid `matching_strategy` values: `"Equals"`, `"Contains"`, `"StartsWith"`, `"EndsWith"`, `"DoesNotContain"`, `"DoesNotEqual"`, `"Regex"`, `"Legacy"`

### Pattern 5: Multi-Monitor Configuration

Monitors are indexed 0-based in the `monitors` array. Each monitor has independent workspaces. When fewer monitors are connected than configured, komorebi silently ignores extra entries:

```nix
monitors = [
  # Monitor 0 (primary)
  {
    workspaces = [
      { name = "I"; layout = "BSP"; }
    ];
  }
  # Monitor 1 (secondary — safe to define even on single-monitor setups)
  {
    workspaces = [
      { name = "1"; layout = "BSP"; }
    ];
  }
];
```

For **per-host serial-based ordering** (v2 requirement, not in KOMO-04 scope), use:
```nix
display_index_preferences = {
  "0" = "MONITOR_SERIAL_A";
  "1" = "MONITOR_SERIAL_B";
};
```
Serial IDs obtained via `komorebic monitor-info`. This is out of scope for v1 (ADV-02 in requirements).

### Pattern 6: `builtins.toJSON` Nix Serialization

Nix attrset keys that are valid JSON keys but contain `$` or `-` must be quoted as strings:

```nix
# Correct: "$schema" key with dollar sign
{
  "$schema" = "https://...";   # quoted string key — correct
  border_width = 8;             # bare identifier — correct for underscore names
  "cross-monitor" = "foo";      # quoted for hyphen — if needed
}
```

`builtins.toJSON` handles:
- Nix `null` → JSON `null`
- Nix booleans → JSON booleans (`true`/`false`)
- Nix integers → JSON numbers
- Nix strings → JSON strings
- Nix lists → JSON arrays
- Nix attrsets → JSON objects

The output is compact (no pretty-printing). komorebi does not require pretty-printed JSON — compact is fine.

### Anti-Patterns to Avoid

- **Defining custom float rules in `applications.json`:** They will be overwritten by `komorebic fetch-asc`. All custom rules belong in `komorebi.json` under `floating_applications`.
- **Missing `KOMOREBI_CONFIG_HOME` env var:** komorebi defaults to `$USERPROFILE` (not `$USERPROFILE\.config\komorebi`). Without the env var, komorebi won't find the file at `.config/komorebi/komorebi.json`. Must document this as a manual setup step.
- **Using `lib.types.anything` instead of `lib.types.path`:** The `windows.configFiles` option expects a Nix store path (output of `pkgs.writeText`), not a raw string.
- **Using `pkgs.writeTextFile` with `executable = true`:** Config files should not be executable.
- **Composite float rule as attrset instead of list:** Composite rules (AND conditions) are arrays-of-arrays in the JSON — each inner array is one composite rule. The outer array is the list of rules, each of which can be either a simple rule object OR an array of conditions.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| JSON serialization | Manual string interpolation for JSON | `builtins.toJSON` | Handles escaping, quoting, nesting; hand-rolled JSON is brittle |
| File generation | `pkgs.writeShellScript` + `echo` | `pkgs.writeText "name" content` | Purpose-built for text files; deterministic store path |
| Catppuccin color values | Hex strings manually embedded | Native `"theme": { "palette": "Catppuccin", "name": "Mocha" }` | Komorebi has built-in Catppuccin support; no need to look up or hardcode hex values |
| Float rule escaping | Manual JSON string construction for matchers | Nix attrsets serialized via `builtins.toJSON` | All escaping handled automatically |

**Key insight:** The entire Phase 2 module is a Nix attrset that `builtins.toJSON` serializes. No manual JSON string construction, no escaping, no multi-line string templates.

---

## Common Pitfalls

### Pitfall 1: KOMOREBI_CONFIG_HOME Must Be Set Manually
**What goes wrong:** Komorebi starts but ignores the generated `komorebi.json` at `.config/komorebi/komorebi.json` — it looks in `$USERPROFILE` (i.e., `C:\Users\michael\`) instead.
**Why it happens:** Komorebi defaults to `$Env:USERPROFILE` if `KOMOREBI_CONFIG_HOME` is unset. The Phase 1 sync hook deposits files under `.config/`, not directly in `USERPROFILE`.
**How to avoid:** Document as a one-time Windows-side manual step: add `$Env:KOMOREBI_CONFIG_HOME = "$Env:USERPROFILE\.config\komorebi"` to the PowerShell profile (`$PROFILE`). This is outside Nix's control.
**Warning signs:** `komorebic start` reports no config file found, or loads default settings.

### Pitfall 2: `builtins.toJSON` Produces Compact JSON
**What goes wrong:** Not actually a problem — komorebi accepts compact JSON. But if debugging, the output looks unreadable.
**Why it happens:** `builtins.toJSON` outputs compact JSON without indentation.
**How to avoid:** Use `nix eval --raw '(builtins.toJSON {...})' | jq .` to pretty-print during debugging. No code change needed.

### Pitfall 3: Float Rules in `applications.json` Get Overwritten
**What goes wrong:** Custom float rules for Settings, Task Manager etc. disappear after running `komorebic fetch-asc`.
**Why it happens:** `komorebic fetch-asc` downloads and overwrites `applications.json` from the community repo. Custom entries are lost.
**How to avoid:** Put ALL custom float rules in `komorebi.json` under `floating_applications`. Never rely on `applications.json` for custom rules.

### Pitfall 4: The `windows.configFiles` aggregator needs the komorebi sub-module imported
**What goes wrong:** `windows.configFiles."komorebi/komorebi.json"` is never set — the file isn't synced.
**Why it happens:** `windows/komorebi/default.nix` exists but `windows/default.nix` does not import it.
**How to avoid:** The aggregator `windows/default.nix` must have `imports = [ ./komorebi ];`. This is where Phase 2 differs from Phase 1 — Phase 1 created the aggregator with no imports; Phase 2 adds the first import.
**Warning signs:** `nix eval .#nixosConfigurations.ocelot.config.home-manager.users.michael.windows.configFiles` returns `{}`.

### Pitfall 5: Nix attrset key `$schema` syntax
**What goes wrong:** Nix parse error: `$schema = ...` is not valid Nix syntax.
**Why it happens:** Nix bare identifiers cannot start with `$`.
**How to avoid:** Always quote attrset keys containing `$`: `"$schema" = "...";`

### Pitfall 6: `window_hiding_behaviour = "Cloak"` requires Windows 11
**What goes wrong:** Komorebi fails to start or shows errors on Windows 10.
**Why it happens:** The `Cloak` window hiding behaviour uses a Windows 11-specific API.
**How to avoid:** Both ocelot and mantis are assumed to be Windows 11 hosts (standard for WSL2 with Hyper-V). If Windows 10 support is ever needed, use `"Hide"` instead. For this project, `"Cloak"` is correct.

---

## Code Examples

Verified patterns from official sources and Phase 1 research:

### Complete `windows/komorebi/default.nix`

```nix
# Source: komorebi schema.json (v0.1.40) + Phase 1 sub-module registration pattern
{
  lib,
  pkgs,
  ...
}:
let
  komorebiConfig = {
    "$schema" = "https://raw.githubusercontent.com/LGUG2Z/komorebi/v0.1.40/schema.json";
    app_specific_configuration_path = "$Env:KOMOREBI_CONFIG_HOME/applications.json";
    window_hiding_behaviour = "Cloak";
    cross_monitor_move_behaviour = "Insert";
    default_workspace_padding = 10;
    default_container_padding = 10;
    border = true;
    border_width = 8;
    border_offset = -1;

    theme = {
      palette = "Catppuccin";
      name = "Mocha";
      bar_accent = "Sapphire";
      single_border = "Sapphire";
      unfocused_border = "Surface1";
    };

    floating_applications = [
      # Windows Settings
      { kind = "Exe"; id = "SystemSettings.exe"; matching_strategy = "Equals"; }
      # Task Manager
      { kind = "Class"; id = "TaskManagerWindow"; matching_strategy = "Legacy"; }
      # Windows Explorer file operation dialogs
      { kind = "Class"; id = "OperationStatusWindow"; matching_strategy = "Legacy"; }
      # Control Panel
      { kind = "Title"; id = "Control Panel"; matching_strategy = "Equals"; }
    ];

    monitors = [
      {
        workspaces = [
          { name = "I";   layout = "BSP"; }
          { name = "II";  layout = "VerticalStack"; }
          { name = "III"; layout = "HorizontalStack"; }
          { name = "IV";  layout = "Grid"; }
          { name = "V";   layout = "Monocle"; }
        ];
      }
      {
        workspaces = [
          { name = "1"; layout = "BSP"; }
          { name = "2"; layout = "VerticalStack"; }
          { name = "3"; layout = "HorizontalStack"; }
        ];
      }
    ];
  };
in
{
  windows.configFiles."komorebi/komorebi.json" =
    pkgs.writeText "komorebi.json" (builtins.toJSON komorebiConfig);
}
```

### Update to `windows/default.nix` aggregator

```nix
# Add imports list to users/michael/windows/default.nix:
# Source: Phase 1 PLAN — aggregator currently has no imports
{
  lib,
  osConfig ? { },
  config,
  ...
}:
let
  isWSL = osConfig.hostSpec.isWSL or false;
  cfg = config.windows;
  # ... existing let bindings ...
in
{
  imports = [
    ./komorebi   # ADD THIS — Phase 2
  ];

  options.windows.configFiles = lib.mkOption { ... };  # unchanged

  config = lib.mkIf isWSL { ... };  # unchanged
}
```

### Validation: Verify Generated JSON

```bash
# Confirm the generated JSON is valid and has expected keys:
nix eval --raw .#nixosConfigurations.ocelot.config.home-manager.users.michael.windows.configFiles | \
  nix eval --raw --impure --expr 'let x = builtins.fromJSON (builtins.readFile /nix/store/...); in x.theme.palette'
# Expected: "Catppuccin"

# Simpler: just verify the configFiles attrset is populated:
nix eval .#nixosConfigurations.ocelot.config.home-manager.users.michael.windows.configFiles
# Expected: { "komorebi/komorebi.json" = "/nix/store/..."; }
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `applications.yaml` (v1 ASC) | `applications.json` (v2 ASC) | v0.1.30 / Nov 2024 | v1 deprecated; do not edit applications.yaml |
| Custom hex color themes | Native Catppuccin/Base16 palette support | Recent versions | No manual color lookup needed for Mocha theme |
| Float rules in `applications.yaml` | Float rules in `komorebi.json` `floating_applications` | Since v2 schema | Float rules in komorebi.json persist across `fetch-asc` |
| `window_hiding_behaviour = "Hide"` | `window_hiding_behaviour = "Cloak"` | Windows 11 era | Cloak is cleaner on Windows 11; Hide still works on Win10 |

**Deprecated/outdated:**
- `applications.yaml` (v1): Deprecated Nov 2024. Still loads for backward compat but no new features.
- Float rules in `applications.json`: Will be overwritten by `komorebic fetch-asc`.

---

## Open Questions

1. **`KOMOREBI_CONFIG_HOME` vs `$USERPROFILE` path — where does komorebi look for `komorebi.json`?**
   - What we know: Default is `$Env:USERPROFILE`; Phase 1 sync deposits to `.config/komorebi/`. These do not match without `KOMOREBI_CONFIG_HOME`.
   - What's unclear: Whether the user already has `KOMOREBI_CONFIG_HOME` set, or whether the plan should include a note to set it.
   - Recommendation: The plan should include a "Windows-side prerequisite" task: document that `$Env:KOMOREBI_CONFIG_HOME = "$Env:USERPROFILE\.config\komorebi"` must be in PowerShell profile. This is a one-time manual step outside Nix.

2. **`app_specific_configuration_path` — does it need to exist?**
   - What we know: The field points to `applications.json`. If the file doesn't exist, komorebi may error or warn on startup.
   - What's unclear: Whether pointing to a non-existent file causes a hard startup failure or just a warning.
   - Recommendation: Set the path as `$Env:KOMOREBI_CONFIG_HOME/applications.json` and note that `komorebic fetch-asc` must be run once to populate it. The generated `komorebi.json` should be valid even if `applications.json` doesn't exist yet — verify this assumption.

3. **`display_index_preferences` — needed for KOMO-04?**
   - What we know: KOMO-04 requires "per-monitor workspace configuration present in `komorebi.json`". The `monitors` array itself satisfies this.
   - What's unclear: Whether KOMO-04 also requires serial-based monitor ordering (`display_index_preferences`), or just that multiple monitors have distinct workspace configs in the array.
   - Recommendation: The `monitors` array with two elements satisfies KOMO-04 as stated. Serial-based ordering is ADV-02 (v2 requirement). The plan should define two monitor configs in the array without `display_index_preferences`.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | None (Nix dotfiles repo — Nix evaluation is the test harness) |
| Config file | N/A |
| Quick run command | `nix flake check` |
| Full suite command | `nixos-rebuild dry-build --flake .#ocelot && nixos-rebuild dry-build --flake .#mantis` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| KOMO-01 | `windows.configFiles."komorebi/komorebi.json"` is set and evaluates to a store path | smoke | `nix eval .#nixosConfigurations.ocelot.config.home-manager.users.michael.windows.configFiles` → expect non-empty attrset | ❌ Wave 0 (file created in this phase) |
| KOMO-01 | Generated JSON contains `monitors`, `border`, `default_workspace_padding` | smoke | `nix eval --raw .#nixosConfigurations.ocelot.config.home-manager.users.michael.windows.configFiles` + `cat /nix/store/...-komorebi.json \| python3 -m json.tool` | ❌ Wave 0 |
| KOMO-02 | `floating_applications` array present in generated JSON with ≥4 rules | smoke | Read generated store file + `jq '.floating_applications \| length'` | ❌ Wave 0 |
| KOMO-03 | `theme.palette == "Catppuccin"` and `theme.name == "Mocha"` in generated JSON | smoke | `jq '.theme.palette, .theme.name'` on generated file | ❌ Wave 0 |
| KOMO-04 | `monitors` array has ≥2 elements with distinct workspace names | smoke | `jq '.monitors \| length'` and `jq '.monitors[0].workspaces[0].name, .monitors[1].workspaces[0].name'` | ❌ Wave 0 |

**Note on smoke test execution:** All smoke tests above reduce to: build the flake, find the generated store path from the `configFiles` attrset, run `jq` against it. A single shell function can automate this after `nix build`.

### Sampling Rate
- **Per task commit:** `nix flake check` (syntax + basic eval — fast, ~10s)
- **Per wave merge:** `nixos-rebuild dry-build --flake .#ocelot && nixos-rebuild dry-build --flake .#mantis`
- **Phase gate:** Full dry-build of both WSL hosts + JSON content spot-check before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `users/michael/windows/komorebi/default.nix` — the module itself (created in this phase)
- [ ] `windows/default.nix` needs `imports = [ ./komorebi ];` added
- [ ] Manual verification: confirm generated JSON is valid via `python3 -m json.tool` or `jq .`

---

## Sources

### Primary (HIGH confidence)
- `https://raw.githubusercontent.com/LGUG2Z/komorebi/master/schema.json` — full JSON schema including theme, floating_applications, monitors, layout enum values, border/gap fields
- `https://raw.githubusercontent.com/LGUG2Z/komorebi-application-specific-configuration/master/applications.yaml` — canonical float/ignore identifiers for Windows system apps (TaskManagerWindow, Shell_Dialog, OperationStatusWindow)
- `https://lgug2z.github.io/komorebi/common-workflows/multi-monitor-setup.html` — monitors array structure, display_index_preferences
- `https://lgug2z.github.io/komorebi/common-workflows/floating-applications.html` — floating_applications placement in komorebi.json
- `https://komorebi.lgug2z.com/reference/komorebi-windows/` — theme Catppuccin palette/name values and color override names
- Codebase: `users/michael/windows/default.nix` — Phase 1 scaffold confirming `windows.configFiles` option type and registration pattern

### Secondary (MEDIUM confidence)
- `https://lgug2z.github.io/komorebi/example-configurations.html` — example komorebi.json with Base16 theme structure (pattern transfers to Catppuccin)
- `https://lgug2z.github.io/komorebi/common-workflows/komorebi-config-home.html` — KOMOREBI_CONFIG_HOME default behavior and override instructions
- WebSearch results confirming: v1 applications.yaml deprecated Nov 2024; float rules in komorebi.json persist across `komorebic fetch-asc`

### Tertiary (LOW confidence)
- `app_specific_configuration_path` behavior when `applications.json` does not yet exist — not verified with a hard launch test; assume graceful warning rather than hard failure

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — `builtins.toJSON` + `pkgs.writeText` are stdlib Nix; Phase 1 scaffold confirmed working
- Architecture (module structure): HIGH — directly follows Phase 1 established sub-module pattern
- komorebi JSON schema: HIGH — verified from official schema.json and example configs
- Catppuccin theme keys: HIGH — confirmed from schema.json CatppuccinTheme struct
- Float rule identifiers: HIGH — sourced from official komorebi-application-specific-configuration/applications.yaml
- Float rules in komorebi.json (not applications.json): HIGH — confirmed by two sources (community note + behavior of fetch-asc)
- Multi-monitor structure: HIGH — confirmed from official multi-monitor docs
- KOMOREBI_CONFIG_HOME requirement: MEDIUM — documented behavior confirmed; actual Windows-side behavior not empirically tested in this WSL environment

**Research date:** 2026-03-08
**Valid until:** 2026-06-08 (komorebi JSON schema is stable; float identifiers may evolve but core structure is stable)
