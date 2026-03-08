# Roadmap: Windows Config via Nix/WSL

## Overview

Starting from an existing NixOS-WSL dotfiles repo, this roadmap builds out declarative Windows desktop configuration in four phases. Phase 1 establishes the activation scaffold — the WSL-to-Windows file copy mechanism that every subsequent module depends on. Phase 2 configures komorebi (the tiling window manager). Phase 3 adds whkd keybindings that call into komorebi. Phase 4 completes the visual layer with the YASB status bar. Each phase delivers a coherent, verifiable capability, and the dependency order is forced by the tools themselves.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Activation Scaffold** - Windows module directory, isWSL guard, and sync hook that copies configs from WSL to the Windows filesystem (completed 2026-03-08)
- [ ] **Phase 2: Komorebi** - komorebi tiling WM config (komorebi.json) with workspaces, layouts, float rules, and Catppuccin Mocha theme
- [ ] **Phase 3: whkd** - whkd hotkey daemon config (.whkdrc) with workspace switching, window management, and layout cycling keybindings
- [ ] **Phase 4: YASB** - YASB status bar config.yaml and styles.css with komorebi widgets, system widgets, and Catppuccin Mocha theming

## Phase Details

### Phase 1: Activation Scaffold
**Goal**: The WSL-to-Windows config copy pipeline exists, is guarded against missing mounts, and is wired into WSL hosts so any config placed in it syncs automatically
**Depends on**: Nothing (first phase)
**Requirements**: SCAF-01, SCAF-02, SCAF-03, SCAF-04
**Success Criteria** (what must be TRUE):
  1. `users/michael/windows/default.nix` exists and is imported by WSL host configs (ocelot, mantis)
  2. Running `home-manager switch` on a non-WSL host does not evaluate or apply any Windows module
  3. After activation on a WSL host with `/mnt/c` mounted, any file staged by a Windows module appears at `/mnt/c/Users/michael/.config/`
  4. If `/mnt/c` is not mounted during activation, the hook exits silently without failing the build
**Plans:** 1/1 plans complete

Plans:
- [x] 01-01-PLAN.md — Windows sync scaffold: module, option, isWSL guard, activation hook, and host wiring

### Phase 2: Komorebi
**Goal**: komorebi is fully configured via Nix, synced to Windows, and ready to manage windows with Catppuccin Mocha theming, sensible layouts, and float rules for system dialogs
**Depends on**: Phase 1
**Requirements**: KOMO-01, KOMO-02, KOMO-03, KOMO-04
**Success Criteria** (what must be TRUE):
  1. `komorebi.json` is generated at the correct Windows path with workspace definitions, layout configuration, border and gap settings, and Catppuccin Mocha applied via the native `"theme"` key
  2. Float rules for common Windows system dialogs (Settings, Task Manager, file pickers) are present and take effect when komorebi loads
  3. Per-monitor workspace configuration is present in `komorebi.json` and takes effect when multiple monitors are connected
**Plans:** 1 plan

Plans:
- [ ] 02-01-PLAN.md — Komorebi module: generate komorebi.json with workspaces, Catppuccin Mocha theme, float rules, and multi-monitor config

### Phase 3: whkd
**Goal**: whkd hotkey daemon is configured via Nix with keybindings for all window management operations, providing keyboard-driven control of the komorebi tiling layout
**Depends on**: Phase 2
**Requirements**: WHKD-01, WHKD-02, WHKD-03
**Success Criteria** (what must be TRUE):
  1. `.whkdrc` is generated and synced to Windows with keybindings for switching between all defined workspaces
  2. Keybindings for moving windows between workspaces and changing window focus direction are present and wired to `komorebic` commands
  3. Keybindings for cycling through layouts (BSP, stack, monocle) are present and functional
**Plans**: TBD

### Phase 4: YASB
**Goal**: YASB status bar is configured via Nix with komorebi workspace and layout widgets, system resource widgets, and Catppuccin Mocha styling that visually matches the Linux side
**Depends on**: Phase 3
**Requirements**: YASB-01, YASB-02, YASB-03, YASB-04, YASB-05, YASB-06
**Success Criteria** (what must be TRUE):
  1. `config.yaml` is generated and synced to Windows with bar layout, komorebi workspace widget showing active/populated workspaces, and komorebi layout widget showing current layout name
  2. Clock, CPU, and memory widgets appear on the bar and display live system data
  3. Media player, volume, active window title, and power menu widgets appear on the bar and respond correctly to user interaction
  4. `styles.css` applies Catppuccin Mocha colors with Sapphire accent using explicit font names, producing a visual appearance consistent with the Linux waybar
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Activation Scaffold | 1/1 | Complete   | 2026-03-08 |
| 2. Komorebi | 0/1 | Planning | - |
| 3. whkd | 0/TBD | Not started | - |
| 4. YASB | 0/TBD | Not started | - |
