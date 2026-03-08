# Stack Research: Windows Config via Nix/WSL

## Core Stack

### Tiling Window Manager: komorebi v0.1.40
- **What**: Rust-based tiling WM for Windows, sits on top of DWM
- **Config**: `komorebi.json` at `%USERPROFILE%\.config\komorebi\komorebi.json`
- **Nix generation**: `builtins.toJSON` — structured Nix attrsets to JSON
- **Install**: `winget install LGUG2Z.komorebi` (Windows-side, manual)
- **Native Catppuccin**: Built-in theme support — `"theme": {"palette": "CatppuccinMocha"}`
- **Confidence**: HIGH (verified GitHub releases Feb 2026)

### Hotkey Daemon: whkd v0.2.10
- **What**: Simple hotkey daemon by komorebi's author
- **Config**: `.whkdrc` at `~/.config/whkd/.whkdrc`
- **Format**: Plain text `modifier + key : command` — trivial Nix string
- **Install**: `winget install LGUG2Z.whkd` (Windows-side, manual)
- **Confidence**: HIGH (verified GitHub releases Sep 2025)
- **Do NOT use**: AutoHotKey — whkd is simpler, purpose-built for komorebi

### Status Bar: YASB v1.9.0 (amnweb fork)
- **What**: Python + Qt6 status bar with komorebi workspace widgets
- **Config**: `config.yaml` + `styles.css` at `C:\Users\michael\.config\yasb\`
- **Nix generation**: YAML via `builtins.toJSON` (valid YAML superset), CSS via `builtins.readFile`
- **Install**: `winget install AmN.yasb` (Windows-side, manual)
- **Requires**: komorebi >= v0.18.0 for workspace widget integration
- **Do NOT use**: da-rth/yasb (unmaintained original fork)
- **Confidence**: HIGH (verified GitHub releases Feb 2025, wiki Feb 2026)

### Terminal: Windows Terminal
- **Config**: `settings.json` at `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\`
- **Better approach**: Use **JSON Fragment Extensions** at `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\dots\`
- **Nix generation**: `builtins.toJSON` for color scheme fragments
- **Confidence**: HIGH

## Config Generation Methods

| App | Format | Nix Method | Pattern |
|-----|--------|-----------|---------|
| komorebi | JSON | `builtins.toJSON` | Like `home-manager` JSON options |
| whkd | Plain text | String literal | Like shell aliases |
| YASB config | YAML | `builtins.toJSON` (JSON is valid YAML) | Structured attrsets |
| YASB styles | CSS | `builtins.readFile ./styles.css` | Like `waybar/style.css` |
| Windows Terminal | JSON | `builtins.toJSON` | Fragment extension |

## Sync Mechanism

- Use `home.activation` with `lib.hm.dag.entryAfter ["writeBoundary"]`
- Copy files from WSL `$HOME/.config/` to `/mnt/c/Users/michael/.config/`
- **Never use symlinks** — Windows apps cannot follow WSL symlinks
- Pattern confirmed by LGUG2Z (komorebi creator) in his own NixOS-WSL setup

## Module Structure

Follow `users/michael/linux/waybar/` pattern:
```
users/michael/windows/
├── default.nix      # Aggregator + activation hook, guarded by isWSL
├── komorebi/
│   └── default.nix
├── whkd/
│   └── default.nix
├── yasb/
│   ├── default.nix
│   └── styles.css
└── terminal/
    └── default.nix
```

## Key Constraints

- `applications.yaml` is deprecated (Nov 2024) — use `applications.json` (v2 format)
- komorebi JSON does not expand `$Env:` variables (except `$Env:USERPROFILE`)
- YASB CSS uses Qt's limited subset — explicit font names required (not `monospace`)
- `KOMOREBI_CONFIG_HOME` env var controls config directory location
