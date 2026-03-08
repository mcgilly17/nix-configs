# Pitfalls Research: Windows Config via Nix/WSL

## Critical Pitfalls

### 1. WSL Symlinks Are Not Followed by Windows Apps
- **Severity**: CRITICAL — configs silently fail to load
- **Details**: komorebi, YASB, and whkd all fail to read configs via WSL LX symlinks. Windows throws `STATUS_IO_REPARSE_TAG_NOT_HANDLED`. Documented as komorebi bug #854.
- **Warning signs**: App starts but uses default config; no error message
- **Prevention**: Use `cp` in `home.activation`, never `home.file` (which creates symlinks)
- **Phase**: Must be established in Phase 1 (activation scaffold)
- **Existing pattern**: `kubectl.nix` already uses activation hook for sops secrets copy

### 2. Nix Store Paths Leak Into Generated Configs
- **Severity**: HIGH — Windows cannot resolve `/nix/store/...` paths
- **Details**: Any `${pkgs.something}` reference in config generation embeds absolute Nix store paths. Windows apps fail silently or error on these paths.
- **Warning signs**: Config references `/nix/store/` in generated JSON/YAML
- **Prevention**: Only use literal strings and Nix attrsets in config generation — no `pkgs.*` references in values that Windows apps read
- **Phase**: All config generation phases (2-4)
- **Source**: LGUG2Z documented this as his primary pitfall

### 3. Windows Terminal Rewrites settings.json on Every Launch
- **Severity**: HIGH — activation hook output gets overwritten immediately
- **Details**: Writing a full `settings.json` via activation is a losing battle. Terminal overwrites it on launch.
- **Warning signs**: Color scheme reverts after opening/closing Terminal
- **Prevention**: Use Windows Terminal **JSON Fragment Extensions** at `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\dots\catppuccin.json` — additive mechanism that survives Terminal rewrites
- **Phase**: Windows Terminal phase
- **Source**: Official Microsoft GitHub issue + Microsoft docs

### 4. /mnt/c May Not Be Mounted During Activation
- **Severity**: MEDIUM — activation fails silently or errors
- **Details**: Boot-time activation scripts may run before `/mnt/c` is available, especially on first WSL startup after Windows boot.
- **Warning signs**: Configs appear stale after `home-manager switch`
- **Prevention**: Guard all writes with `mountpoint -q /mnt/c` check; silently succeed if not mounted (configs stay stale but don't error)
- **Phase**: Phase 1 (activation scaffold)

### 5. Komorebi Does Not Expand Environment Variables
- **Severity**: MEDIUM — causes silent restart loops
- **Details**: komorebi.json does not expand `$Env:` variables except the single hard-coded `$Env:USERPROFILE`. Any other variable reference causes komorebi to crash and restart in a loop.
- **Warning signs**: komorebi keeps restarting, high CPU usage
- **Prevention**: Use hardcoded `C:\\Users\\michael\\...` paths only — no `$Env:` references
- **Phase**: Komorebi config phase
- **Source**: Komorebi maintainer confirmed in issue #660

### 6. YASB CSS Uses Qt's Limited Subset
- **Severity**: LOW — causes error dialogs but doesn't crash
- **Details**: `font-family: monospace` and other generic CSS font names cause Qt error dialogs. Must use explicit Windows font names like `"JetBrainsMono NF"`.
- **Warning signs**: Qt error dialog on YASB startup about font
- **Prevention**: Use explicit font names in styles.css; test on Windows before committing
- **Phase**: YASB theming phase

### 7. applications.yaml Is Deprecated
- **Severity**: LOW — silent config ignore
- **Details**: As of November 2024, komorebi no longer reads `applications.yaml`. Must use `applications.json` (v2 format) for application-specific rules.
- **Warning signs**: Float rules don't apply; apps that should float are tiled
- **Prevention**: Only generate `applications.json`, never `.yaml`
- **Phase**: Komorebi config phase

## Phase Mapping Summary

| Phase | Pitfalls to Address |
|-------|-------------------|
| Phase 1 (Scaffold) | #1 (symlinks), #4 (mount guard) |
| Phase 2 (Komorebi) | #2 (store paths), #5 (env vars), #7 (applications.yaml) |
| Phase 3 (YASB) | #2 (store paths), #6 (Qt CSS fonts) |
| Phase 4 (Terminal) | #3 (settings.json rewrite) |

## Prevention Checklist

- [ ] Activation hook uses `cp`, not symlinks
- [ ] Mount guard on `/mnt/c` in activation script
- [ ] No `/nix/store/` paths in any generated config value
- [ ] No `$Env:` variables in komorebi.json
- [ ] Explicit font names in YASB CSS
- [ ] Windows Terminal uses Fragment Extensions, not full settings.json
- [ ] Application rules use `.json` format (not `.yaml`)
