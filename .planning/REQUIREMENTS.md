# Requirements: Windows Config via Nix/WSL

**Defined:** 2026-03-08
**Core Value:** Windows app configurations are generated declaratively in Nix and automatically synced to the Windows side, so the Windows desktop environment is reproducible and version-controlled.

## v1 Requirements

### Scaffold

- [ ] **SCAF-01**: Windows module directory exists at `users/michael/windows/` with aggregator `default.nix`
- [ ] **SCAF-02**: All Windows modules guarded by `hostSpec.isWSL` flag
- [ ] **SCAF-03**: `home.activation` sync hook copies configs from WSL to `/mnt/c/Users/michael/`
- [ ] **SCAF-04**: Sync hook guards writes with `/mnt/c` mount check

### Komorebi

- [ ] **KOMO-01**: `komorebi.json` generated via `builtins.toJSON` with workspaces, layouts, borders, gaps
- [ ] **KOMO-02**: Application-specific float rules for common Windows apps (Settings, Task Manager, dialogs)
- [ ] **KOMO-03**: Catppuccin Mocha theme applied via native `"theme"` config key
- [ ] **KOMO-04**: Per-monitor workspace configuration support

### whkd

- [ ] **WHKD-01**: `.whkdrc` generated with workspace switching keybindings
- [ ] **WHKD-02**: Window movement and focus keybindings via `komorebic` commands
- [ ] **WHKD-03**: Layout cycling keybindings (BSP, stack, monocle)

### YASB

- [ ] **YASB-01**: `config.yaml` generated with bar layout and widget definitions
- [ ] **YASB-02**: Komorebi workspace widget showing active/populated workspaces
- [ ] **YASB-03**: Komorebi layout widget showing current layout
- [ ] **YASB-04**: Clock, CPU, memory system widgets
- [ ] **YASB-05**: `styles.css` with Catppuccin Mocha colors and Sapphire accent
- [ ] **YASB-06**: Media, volume, active window, and power menu widgets

## v2 Requirements

### Terminal

- **TERM-01**: Windows Terminal Catppuccin Mocha color scheme via Fragment Extensions
- **TERM-02**: Windows Terminal font and profile settings

### Shared Theming

- **THEME-01**: Shared Catppuccin color attrset usable across Linux and Windows modules
- **THEME-02**: Single source of truth for accent color (Sapphire)

### Advanced

- **ADV-01**: Comprehensive komorebi application rules library
- **ADV-02**: Per-host monitor serial number configuration

## Out of Scope

| Feature | Reason |
|---------|--------|
| Windows package installation via Nix | Not possible — winget/scoop run on Windows side |
| Registry modifications | Too fragile, not config-file based |
| WSL symlinks for config delivery | Windows apps cannot follow them (komorebi bug #854) |
| Full settings.json replacement | Windows Terminal rewrites it on every launch |
| AutoHotKey configs | whkd is simpler and purpose-built for komorebi |
| VS Code settings management | Has its own Settings Sync mechanism |
| Raycast configuration | Raycast has its own sync mechanism |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SCAF-01 | Phase 1 | Pending |
| SCAF-02 | Phase 1 | Pending |
| SCAF-03 | Phase 1 | Pending |
| SCAF-04 | Phase 1 | Pending |
| KOMO-01 | Phase 2 | Pending |
| KOMO-02 | Phase 2 | Pending |
| KOMO-03 | Phase 2 | Pending |
| KOMO-04 | Phase 2 | Pending |
| WHKD-01 | Phase 3 | Pending |
| WHKD-02 | Phase 3 | Pending |
| WHKD-03 | Phase 3 | Pending |
| YASB-01 | Phase 4 | Pending |
| YASB-02 | Phase 4 | Pending |
| YASB-03 | Phase 4 | Pending |
| YASB-04 | Phase 4 | Pending |
| YASB-05 | Phase 4 | Pending |
| YASB-06 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 17 total
- Mapped to phases: 17
- Unmapped: 0

---
*Requirements defined: 2026-03-08*
*Last updated: 2026-03-08 after initial definition*
