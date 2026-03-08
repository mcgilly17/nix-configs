# Project Research Summary

**Project:** Windows Config via Nix/WSL
**Domain:** Dotfiles / NixOS-WSL system configuration
**Researched:** 2026-03-08
**Confidence:** HIGH

## Executive Summary

This project adds managed Windows desktop configuration to an existing NixOS-WSL dotfiles setup. The goal is to generate configs for komorebi (tiling WM), whkd (hotkeys), YASB (status bar), and Windows Terminal from Nix — maintaining the same Catppuccin Mocha aesthetic already used on the Linux side. The recommended approach follows the pattern documented by komorebi's own creator (LGUG2Z): generate configs as real files in WSL's `~/.config/`, then copy them to `/mnt/c/Users/michael/.config/` via a `home.activation` hook. This approach is already validated by an analogous pattern in the codebase (`kubectl.nix` for sops secrets).

The key architectural constraint is that Windows apps cannot follow WSL LX symlinks — any use of `home.file` (which creates symlinks) will cause configs to silently fail to load. Every module must write real files and rely on the central activation hook to copy them across the filesystem boundary. A second hard constraint is that Nix store paths (`/nix/store/...`) must never appear in generated config values, since Windows cannot resolve them. These two constraints shape every implementation decision.

The tools chosen (komorebi, whkd, YASB) are purpose-built for this use case, actively maintained as of early 2026, and all support the Catppuccin theme natively or via CSS. The implementation is straightforward Nix string/JSON/YAML generation — no exotic tooling needed. The main risks are well-documented, have clear preventions, and can all be addressed in Phase 1 (the activation scaffold) before any app config is written.

## Key Findings

### Recommended Stack

All four tools are installed Windows-side via `winget` (outside Nix's scope) and configured via files that Nix generates. Config generation uses only built-in Nix primitives: `builtins.toJSON` for structured data, string literals for simple text formats, and `builtins.readFile` for raw CSS. No additional Nix libraries are required.

**Core technologies:**
- **komorebi v0.1.40**: Rust-based tiling WM — purpose-built for Windows, actively maintained, native Catppuccin support
- **whkd v0.2.10**: Hotkey daemon by komorebi's author — simple text config, replaces AutoHotKey entirely
- **YASB v1.9.0 (amnweb fork)**: Python/Qt6 status bar — komorebi workspace widget, YAML + CSS config
- **Windows Terminal JSON Fragments**: Additive color scheme mechanism — survives Terminal's settings.json rewrites
- **`home.activation` hook**: NixOS-Home Manager activation DAG — the only safe way to copy files across WSL/Windows boundary

### Expected Features

Dependencies force a strict build order: the scaffold must exist before any config module, and komorebi workspace names must be defined before YASB can reference them.

**Must have (table stakes):**
- isWSL guard + `windows/` module scaffold — prerequisite for everything; nothing else can exist without it
- komorebi.json generation — workspaces, layouts, gaps, borders, float rules, Catppuccin Mocha theme
- whkd keybindings — workspace switching, window management, layout cycling via `komorebic`
- YASB config.yaml + styles.css — workspace/layout widgets, clock/CPU/memory, Catppuccin Mocha CSS
- Activation sync hook with mount guard — copies all configs to `/mnt/c/`, guarded by `mountpoint -q /mnt/c`

**Should have (differentiators):**
- Windows Terminal JSON Fragment — Catppuccin Mocha color scheme without touching `settings.json`
- Shared Catppuccin Nix attrset — DRY color definitions reused by both Linux (waybar) and Windows (YASB, komorebi)
- Comprehensive application rules — float rules for common Windows dialogs and system windows
- YASB advanced widgets — media, volume, active window title, power menu

**Defer (v2+):**
- Per-monitor workspace configuration — requires monitor serial numbers; high complexity, low daily impact
- Any package installation via Nix — not possible; winget is Windows-side only

### Architecture Approach

The module tree mirrors the existing `users/michael/linux/` structure. A top-level `windows/default.nix` acts as an aggregator guarded by `lib.mkIf (osConfig.hostSpec.isWSL or false)`, importing app submodules and owning the single `home.activation.syncWindowsConfigs` hook. App submodules (`komorebi/`, `whkd/`, `yasb/`, `terminal/`) write to `xdg.configFile` (staging to WSL `~/.config/`). The activation hook then copies all staged configs to `/mnt/c/Users/michael/.config/` with a plain `cp -rf`. This keeps the data flow simple and auditable: Nix attrsets → `xdg.configFile` → `~/.config/` → activation `cp` → Windows filesystem.

**Major components:**
1. `windows/default.nix` — aggregator, isWSL guard, `home.activation.syncWindowsConfigs` with mount guard
2. `komorebi/default.nix` — `builtins.toJSON` attrset → `komorebi.json`; uses hardcoded paths, no `$Env:` vars
3. `whkd/default.nix` — Nix string literal → `.whkdrc`; simplest module, validates pipeline end-to-end
4. `yasb/default.nix` + `yasb/styles.css` — YAML config via `builtins.toJSON`; raw CSS via `builtins.readFile`
5. `terminal/default.nix` — JSON Fragment at `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\dots\`

### Critical Pitfalls

1. **WSL symlinks silently fail** — Never use `home.file`; always use `home.activation` with `cp`. Windows throws `STATUS_IO_REPARSE_TAG_NOT_HANDLED` with no visible error to the user (komorebi bug #854).
2. **Nix store paths in generated configs** — Any `${pkgs.something}` reference embeds `/nix/store/...` paths Windows cannot resolve. Use only literal strings and Nix attrsets in config values.
3. **komorebi.json does not expand `$Env:` variables** — Only `$Env:USERPROFILE` is supported. Use hardcoded `C:\\Users\\michael\\...` paths; any other `$Env:` reference triggers a silent restart loop.
4. **Windows Terminal overwrites `settings.json` on every launch** — Use JSON Fragment Extensions (additive mechanism); never write a full `settings.json`.
5. **`/mnt/c` may not be mounted during activation** — Guard all writes with `mountpoint -q /mnt/c`; silently succeed if not mounted rather than erroring.

## Implications for Roadmap

Based on research, the dependency graph is clear and forces a 4-phase structure. Steps 2 and 3 from the FEATURES.md MVP ordering can be combined because they share no runtime dependency — the activation hook copies whatever exists.

### Phase 1: Activation Scaffold

**Rationale:** The isWSL guard and activation hook with mount guard are prerequisites for every other module. Establishing this first validates the WSL-to-Windows copy pipeline before any real config is written. This is the highest-leverage phase — getting it wrong (using symlinks) causes silent failures everywhere.
**Delivers:** `windows/default.nix` with `lib.mkIf isWSL`, `home.activation.syncWindowsConfigs` with `mountpoint -q /mnt/c` guard, import wired into WSL host config.
**Addresses:** isWSL guard feature, activation sync hook feature.
**Avoids:** Pitfalls #1 (symlinks) and #5 (mount guard) — both must be solved here before any config is added.

### Phase 2: Core Window Manager (whkd + komorebi)

**Rationale:** whkd is the simplest config (plain text) and should be written first to prove the pipeline works end-to-end. komorebi follows because it's the core WM — nothing else is meaningful without it. These two are grouped because whkd keybindings call `komorebic` commands and the configs are semantically coupled.
**Delivers:** `whkd/default.nix` (.whkdrc), `komorebi/default.nix` (komorebi.json with workspaces, Catppuccin Mocha theme, float rules via applications.json).
**Uses:** `builtins.toJSON` for komorebi, string literal for whkd.
**Avoids:** Pitfalls #2 (store paths), #3 (env vars — hardcode paths), #7 (use applications.json not .yaml).

### Phase 3: Visual Layer (YASB)

**Rationale:** YASB workspace widget references komorebi workspace names, so it cannot be configured until Phase 2 defines them. YASB is grouped together (config.yaml + styles.css) because neither is useful without the other.
**Delivers:** `yasb/default.nix` (config.yaml with komorebi workspace/layout widgets, clock, CPU, memory), `yasb/styles.css` (Catppuccin Mocha, explicit font names).
**Implements:** YASB status bar architecture component.
**Avoids:** Pitfall #6 (Qt CSS fonts — use `"JetBrainsMono NF"` not `monospace`), Pitfall #2 (store paths in YAML).

### Phase 4: Polish (Windows Terminal + Shared Colors)

**Rationale:** Windows Terminal fragment is independent of the WM stack and can be deferred without blocking daily use. The shared Catppuccin attrset refactor is most valuable after multiple color consumers exist (YASB, komorebi, Terminal) — doing it before them is premature DRY.
**Delivers:** `terminal/default.nix` (JSON Fragment at correct path), optional shared `catppuccin.nix` color attrset refactor.
**Avoids:** Pitfall #4 (Terminal settings.json rewrite — use Fragment Extensions exclusively).

### Phase Ordering Rationale

- Phase 1 before everything: the copy mechanism must exist before configs do; symlink vs. copy is a non-recoverable architectural decision
- whkd before komorebi in Phase 2: validates the pipeline with the simplest possible config before adding JSON complexity
- YASB after komorebi: hard semantic dependency on workspace names being defined
- Terminal last: independent of WM stack, additive, and lowest risk — safe to defer

### Research Flags

Phases with standard, well-documented patterns (skip research-phase during planning):
- **Phase 1:** `home.activation` DAG is well-documented in Home Manager docs; existing `kubectl.nix` is a direct template
- **Phase 2 (whkd):** Plain text config, trivial Nix string generation
- **Phase 3 (YASB CSS):** Raw file via `builtins.readFile`, no generation complexity

Phases that may benefit from deeper research during planning:
- **Phase 2 (komorebi JSON):** Application rules (`applications.json` v2 format) are the most complex part — the full schema for float/manage rules should be verified against v0.1.40 release notes before writing
- **Phase 4 (Terminal Fragment):** The exact Fragment path discovery mechanism and whether it requires the directory to pre-exist on Windows warrants a quick verification pass

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All tools verified against GitHub releases (Feb 2026); versions confirmed current |
| Features | HIGH | MVP ordering is dependency-forced, not opinion-based; anti-features are clearly bounded |
| Architecture | HIGH | Activation hook pattern confirmed by komorebi author's own NixOS-WSL setup; existing codebase has analogous pattern |
| Pitfalls | HIGH | Critical pitfalls sourced from official GitHub issues and maintainer statements; not speculation |

**Overall confidence:** HIGH

### Gaps to Address

- **komorebi applications.json v2 schema**: The exact structure of `applications.json` for float/manage rules in v0.1.40 should be verified during Phase 2 planning. The deprecation of `.yaml` is confirmed but the v2 JSON format details were not fully researched.
- **YASB widget schema for komorebi integration**: YASB requires `komorebi >= v0.18.0` for workspace widget; the exact widget config keys should be cross-checked against YASB v1.9.0 docs during Phase 3 planning.
- **Windows Terminal Fragment path on first run**: Whether the `Fragments/dots/` directory must be created before Terminal first launch, or whether it can be created by the activation hook, needs validation on the actual Windows side.

## Sources

### Primary (HIGH confidence)
- LGUG2Z/komorebi GitHub releases — v0.1.40 confirmed Feb 2026
- LGUG2Z/whkd GitHub releases — v0.2.10 confirmed Sep 2025
- amnweb/yasb GitHub wiki — v1.9.0 and komorebi integration docs confirmed Feb 2026
- LGUG2Z NixOS-WSL public dotfiles — activation hook pattern and pitfall documentation
- Microsoft Windows Terminal documentation — JSON Fragment Extensions mechanism
- Komorebi GitHub issue #854 — WSL symlink failure documented
- Komorebi GitHub issue #660 — `$Env:` variable limitation confirmed by maintainer

### Secondary (MEDIUM confidence)
- Home Manager documentation — `home.activation` DAG and `xdg.configFile` behavior
- Existing codebase patterns — `kubectl.nix` activation hook, `_1passwordcli.nix` isWSL guard

### Tertiary (LOW confidence)
- Qt CSS subset behavior — documented via community YASB issues; explicit font name requirement needs first-run validation

---
*Research completed: 2026-03-08*
*Ready for roadmap: yes*
