# Features Research: Windows Config via Nix/WSL

## Table Stakes (Must Have)

### Module Scaffold
- **isWSL guard on windows/ module** — everything conditional on `hostSpec.isWSL`
- **Complexity**: Low
- **Dependency**: None — prerequisite for everything else

### Komorebi Configuration
- **komorebi.json generation** — workspaces, layouts, borders, gaps, rules
- **Application-specific rules** — float rules for dialogs, popups, system windows
- **Catppuccin Mocha theme** — native support via `"theme": {"palette": "CatppuccinMocha"}`
- **Complexity**: Medium
- **Dependency**: Module scaffold

### whkd Keybindings
- **.whkdrc generation** — workspace switching, window movement, layout cycling, focus
- **komorebic integration** — bindings call `komorebic` commands
- **Complexity**: Low
- **Dependency**: Module scaffold

### YASB Status Bar
- **config.yaml generation** — bar layout, widget definitions
- **Komorebi workspace widget** — show active/populated workspaces
- **Komorebi layout widget** — show current layout (BSP, stack, etc.)
- **Clock, CPU, memory widgets** — basic system info
- **Complexity**: Medium
- **Dependency**: Komorebi config (workspace names must match)

### YASB Catppuccin Theming
- **styles.css with Catppuccin Mocha colors** — consistent with Linux side
- **Sapphire accent** — matching existing accent choice
- **Complexity**: Low
- **Dependency**: YASB config

### Activation Sync Hook
- **home.activation script** — copies all generated configs to Windows filesystem
- **Mount guard** — check `/mnt/c` is mounted before writing
- **Complexity**: Low
- **Dependency**: At least one config module exists

## Differentiators (Nice-to-Have)

### Shared Catppuccin Color Attrset
- **Single Nix attrset** with all Catppuccin Mocha colors
- **Used by both Linux and Windows modules** — DRY across platforms
- **Complexity**: Low
- **Dependency**: None, but most valuable after multiple consumers exist

### Windows Terminal Color Scheme
- **Fragment extension** with Catppuccin Mocha color scheme
- **Avoids overwriting user's settings.json** — additive, not destructive
- **Complexity**: Medium (fragment path discovery)
- **Dependency**: Module scaffold

### Per-Monitor Workspace Configuration
- **Different workspace layouts per monitor** — tailored to monitor arrangement
- **Complexity**: Medium (requires knowing monitor serial numbers)
- **Dependency**: Komorebi config

### YASB Advanced Widgets
- **Media widget** — now playing info
- **Volume widget** — system volume control
- **Active window widget** — show focused window title
- **Power menu widget** — shutdown/restart/lock
- **Complexity**: Low each
- **Dependency**: YASB config

### komorebi Application Rules Library
- **Comprehensive float rules** — cover common Windows apps (Settings, Task Manager, etc.)
- **Managed window rules** — force-manage apps that komorebi ignores
- **Complexity**: Medium (requires testing each app)
- **Dependency**: Komorebi config

## Anti-Features (Do NOT Build)

| Feature | Reason |
|---------|--------|
| Windows package installation via Nix | Not possible — winget/scoop run on Windows side |
| Registry modifications | Too fragile, not config-file based |
| WSL symlinks for config delivery | Windows apps cannot follow them — confirmed bug |
| Full settings.json replacement | Windows Terminal rewrites it on every launch |
| AutoHotKey configs | whkd is simpler and purpose-built for komorebi |
| VS Code settings management | Has its own Settings Sync mechanism |
| Nix store path references in configs | Windows cannot resolve `/nix/store/...` paths |

## MVP Ordering (Forced by Dependencies)

1. isWSL guard + module scaffold
2. komorebi.json + whkdrc (core WM, useless without both)
3. YASB config.yaml + styles.css (visual layer on WM)
4. Activation sync hook (wires everything to Windows)
5. Windows Terminal fragment (optional polish)
6. Shared Catppuccin refactor (DRY improvement)

**Note**: Steps 2-4 can be a single phase since they are all config generation with no runtime dependency between them. The sync hook just needs all files to exist.
