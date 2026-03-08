# Architecture Research: Windows Config via Nix/WSL

## Module Structure

Create `users/michael/windows/` mirroring the existing `users/michael/linux/` pattern:

```
users/michael/windows/
├── default.nix          # Aggregator, guarded by isWSL, activation hook
├── komorebi/
│   └── default.nix      # komorebi.json via builtins.toJSON
├── whkd/
│   └── default.nix      # .whkdrc via string literal
├── yasb/
│   ├── default.nix      # config.yaml via Nix attrsets
│   └── styles.css       # Catppuccin Mocha CSS (raw file)
└── terminal/
    └── default.nix      # Windows Terminal color scheme
```

## Config Generation Approach

Use `xdg.configFile` to write generated configs to a staging area in WSL home:

- **komorebi.json**: `builtins.toJSON` for structured JSON config
- **.whkdrc**: Nix string literal (simple key-value format)
- **YASB config.yaml**: Nix attrsets converted to YAML (or string literal)
- **YASB styles.css**: Raw CSS file via `builtins.readFile`
- **Windows Terminal**: JSON fragment via `builtins.toJSON`

**Why not `home.file`**: It creates symlinks, and Windows apps can't follow WSL symlinks. Must use file copy.

## Activation Hook Design

Single centralized `home.activation.syncWindowsConfigs` in `windows/default.nix`:

```nix
home.activation.syncWindowsConfigs = lib.hm.dag.entryAfter ["writeBoundary"] ''
  WIN_HOME="/mnt/c/Users/michael"
  for dir in komorebi whkd yasb; do
    if [ -d "$HOME/.config/$dir" ]; then
      mkdir -p "$WIN_HOME/.config/$dir"
      cp -rf "$HOME/.config/$dir/." "$WIN_HOME/.config/$dir/"
    fi
  done
'';
```

Mirrors the `darwin/sops.nix` activation pattern already in the codebase.

## Guard Pattern

```nix
lib.mkIf (osConfig.hostSpec.isWSL or false)
```

Identical to existing `_1passwordcli.nix` guard. Applied at `windows/default.nix` level so individual app modules don't need guards.

## Windows Config Paths

| App | Windows Path |
|-----|-------------|
| komorebi | `C:\Users\michael\.config\komorebi\komorebi.json` |
| whkd | `C:\Users\michael\.config\whkd\.whkdrc` |
| YASB | `C:\Users\michael\.config\yasb\config.yaml` + `styles.css` |
| Windows Terminal | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |

## Build Order

1. **Activation scaffold** (`windows/default.nix`) — guard + sync hook
2. **whkd** — simplest config, text format, validates the sync pipeline
3. **komorebi** — JSON config, depends on whkd keybindings being defined
4. **YASB** — YAML + CSS, depends on komorebi workspace names
5. **Windows Terminal** — most complex (merge risk with existing user settings)

## Data Flow

```
Nix attrsets → xdg.configFile (WSL ~/.config/) → activation hook cp → /mnt/c/Users/michael/.config/
```

## Integration Points

- **Catppuccin colors**: Share color definitions between Linux (waybar CSS) and Windows (YASB CSS, komorebi theme)
- **Host detection**: `hostSpec.isWSL` already exists and is set for ocelot/mantis
- **Import path**: WSL host configs (e.g., `ocelot.nix`) import `../windows` alongside existing modules
