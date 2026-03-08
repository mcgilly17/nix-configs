# Windows Configuration via Nix/WSL

## What This Is

Declarative Windows desktop configuration managed through Nix and home-manager from within WSL. Generates config files for Windows-native apps (tiling window manager, status bar, hotkey daemon, terminal) and syncs them to the Windows filesystem on every home-manager activation. Any WSL host in the dotfiles repo automatically gets Windows-side config management.

## Core Value

Windows app configurations are generated declaratively in Nix — matching existing patterns for Linux (waybar, hyprland) — and automatically synced to the Windows side, so the Windows desktop environment is reproducible and version-controlled.

## Requirements

### Validated

- ✓ Nix flake-based dotfiles with home-manager — existing
- ✓ WSL hosts (ocelot, mantis) with `isWSL` host spec — existing
- ✓ Catppuccin Mocha theming across Linux tools — existing
- ✓ Waybar status bar config pattern (Nix attrsets + CSS file) — existing
- ✓ Per-host home-manager imports via `users/michael/hosts/*.nix` — existing

### Active

- [ ] Komorebi tiling window manager configuration (komorebi.json)
- [ ] whkd hotkey daemon configuration (.whkdrc)
- [ ] YASB status bar configuration (config.yaml + styles.css)
- [ ] Windows Terminal color scheme and settings (settings.json fragment)
- [ ] home.activation hook to sync configs from WSL to /mnt/c/Users/michael/
- [ ] Catppuccin Mocha/Sapphire theming consistent with Linux side
- [ ] Guard all Windows modules behind `isWSL` host spec flag
- [ ] Shared Catppuccin color definitions usable across both Linux and Windows configs

### Out of Scope

- Windows package installation (winget/scoop) — manual, not manageable from Nix
- Registry modifications — too fragile, not config-file based
- VS Code settings — managed separately via Settings Sync
- Wallpaper/desktop settings — not config-file driven
- Raycast configuration — Raycast has its own sync mechanism

## Context

- Komorebi uses `komorebi.json` for workspace/layout config and pairs with whkd (`.whkdrc`) for keybindings
- YASB (amnweb/yasb fork) uses `config.yaml` + `styles.css`, has dedicated Komorebi workspace widgets
- Windows Terminal settings live at `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`
- WSL can write to Windows filesystem at `/mnt/c/Users/michael/`
- Symlinks from WSL are not followed by Windows apps — must use file copy
- Komorebi has native Catppuccin theme support in its JSON config
- YASB uses Qt CSS (limited subset) for theming
- LGUG2Z (komorebi creator) runs this exact pattern: NixOS-WSL generating komorebi configs

## Constraints

- **File sync method**: Must copy files, not symlink (Windows apps can't follow WSL symlinks)
- **Windows username**: Hardcoded as "michael" for sync paths
- **Theme**: Catppuccin Mocha with Sapphire accent (matching Linux side)
- **Guard**: All Windows modules must be conditional on `hostSpec.isWSL`
- **Pattern**: Follow existing module patterns (like `users/michael/linux/waybar/`)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Config generation over symlinks | Windows apps can't follow WSL symlinks | — Pending |
| Hardcode Windows username | Same username across machines, simpler than auto-detect | — Pending |
| Guard on isWSL | Automatically applies to all current and future WSL hosts | — Pending |
| Mirror linux/ module pattern | Consistency with existing `users/michael/linux/` structure | — Pending |
| Catppuccin Mocha/Sapphire | Consistency with existing Linux theming | — Pending |

---
*Last updated: 2026-03-08 after initialization*
