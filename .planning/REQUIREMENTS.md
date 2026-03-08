# Requirements: Windows Config via Nix/WSL

**Defined:** 2026-03-08
**Core Value:** Windows app configurations are generated declaratively in Nix and automatically synced to the Windows side, so the Windows desktop environment is reproducible and version-controlled.

## v1 Requirements

### Scaffold

- [x] **SCAF-01**: Windows module directory exists at `users/michael/windows/` with aggregator `default.nix`
- [x] **SCAF-02**: All Windows modules guarded by `hostSpec.isWSL` flag
- [x] **SCAF-03**: `home.activation` sync hook copies configs from WSL to `/mnt/c/Users/michael/`
- [x] **SCAF-04**: Sync hook guards writes with `/mnt/c` mount check

### Komorebi

- [x] **KOMO-01**: `komorebi.json` generated via `builtins.toJSON` with workspaces, layouts, borders, gaps
- [x] **KOMO-02**: Application-specific float rules for common Windows apps (Settings, Task Manager, dialogs)
- [x] **KOMO-03**: Catppuccin Mocha theme applied via native `"theme"` config key
- [x] **KOMO-04**: Per-monitor workspace configuration support

### whkd

- [x] **WHKD-01**: `.whkdrc` generated with workspace switching keybindings
- [x] **WHKD-02**: Window movement and focus keybindings via `komorebic` commands
- [x] **WHKD-03**: Layout cycling keybindings (BSP, stack, monocle)

### YASB

- [x] **YASB-01**: `config.yaml` generated with bar layout and widget definitions
- [x] **YASB-02**: Komorebi workspace widget showing active/populated workspaces
- [x] **YASB-03**: Komorebi layout widget showing current layout
- [x] **YASB-04**: Clock, CPU, memory system widgets
- [x] **YASB-05**: `styles.css` with Catppuccin Mocha colors and Sapphire accent
- [x] **YASB-06**: Media, volume, active window, and power menu widgets

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
| SCAF-01 | Phase 1 | Complete |
| SCAF-02 | Phase 1 | Complete |
| SCAF-03 | Phase 1 | Complete |
| SCAF-04 | Phase 1 | Complete |
| KOMO-01 | Phase 2 | Complete |
| KOMO-02 | Phase 2 | Complete |
| KOMO-03 | Phase 2 | Complete |
| KOMO-04 | Phase 2 | Complete |
| WHKD-01 | Phase 3 | Complete |
| WHKD-02 | Phase 3 | Complete |
| WHKD-03 | Phase 3 | Complete |
| YASB-01 | Phase 4 | Complete |
| YASB-02 | Phase 4 | Complete |
| YASB-03 | Phase 4 | Complete |
| YASB-04 | Phase 4 | Complete |
| YASB-05 | Phase 4 | Complete |
| YASB-06 | Phase 4 | Complete |

**Coverage:**
- v1 requirements: 17 total
- Mapped to phases: 17
- Unmapped: 0

---
*Requirements defined: 2026-03-08*
*Last updated: 2026-03-08 after initial definition*
