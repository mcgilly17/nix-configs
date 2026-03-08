# Codebase Structure

**Analysis Date:** 2026-03-08

## Directory Layout

```
/home/michael/Projects/dots/
├── flake.nix                           # Root flake: inputs, outputs, system definitions
├── flake.lock                          # Locked dependency versions
├── devenv.nix                          # Development environment configuration
├── devenv.lock                         # Development environment lockfile
├── README.md                           # Project overview and component reference
├── TODO.md                             # Roadmap and outstanding tasks
│
├── hosts/                              # System-specific host configurations
│   ├── bowser/                         # macOS: MacBook Pro 16" M1 Max (Darwin)
│   │   └── default.nix                 # Entry point: imports common + darwin modules + user config
│   │
│   └── nixos/                          # NixOS hosts
│       ├── ganon/                      # x86_64 gaming PC with NVIDIA GPU
│       │   ├── default.nix             # Imports disko, nixos modules, user config
│       │   ├── configuration.nix       # Hardware config specifics
│       │   └── disks.nix               # Declarative disk partitioning
│       │
│       ├── glados/                     # x86_64 server/workstation
│       │   ├── default.nix
│       │   ├── configuration.nix
│       │   └── disks.nix
│       │
│       ├── wsl/                        # Windows Subsystem for Linux hosts
│       │   ├── common/                 # Shared WSL configuration
│       │   │   └── default.nix
│       │   ├── ocelot/                 # x86_64 WSL with GPU (primary Windows)
│       │   │   └── default.nix
│       │   └── mantis/                 # x86_64 WSL with GPU (secondary Windows)
│       │       └── default.nix
│       │
│       └── rk1/                        # ARM64 Rockchip RK3588 cluster nodes (Turing Pi 2)
│           ├── common/                 # Shared RK1 base configuration
│           │   ├── default.nix
│           │   └── disks.nix
│           ├── sephiroth/              # aarch64 development node
│           │   └── default.nix
│           ├── zenith-1/               # aarch64 K3s cluster control plane
│           │   └── default.nix
│           ├── zenith-2/               # aarch64 K3s cluster agent
│           │   └── default.nix
│           └── zenith-3/               # aarch64 K3s cluster agent
│               └── default.nix
│
├── modules/                            # Reusable system configuration modules
│   ├── common/                         # OS-agnostic, host-agnostic modules
│   │   ├── core.nix                    # Base tools: git, archives, text processing, nix config
│   │   └── host-spec.nix               # Module options for host capability flags
│   │
│   ├── darwin/                         # macOS-specific modules
│   │   ├── default.nix                 # Entry point: auto-imports all modules in directory
│   │   ├── nix-core.nix                # Darwin Nix configuration
│   │   ├── system.nix                  # macOS system defaults
│   │   ├── tailscale.nix               # Tailscale VPN configuration
│   │   ├── dock-config.nix             # Dock appearance and organization
│   │   ├── wm/                         # Window manager (Yabai) and hotkeys (skhd)
│   │   │   ├── default.nix
│   │   │   ├── yabai.nix               # Tiling window manager
│   │   │   └── skhd.nix                # Keyboard shortcut daemon
│   │   │
│   │   └── apps/                       # App categories and installation via Homebrew
│   │       ├── default.nix             # App category aggregator
│   │       ├── desktop.nix             # GUI applications (Chrome, etc.)
│   │       ├── creative.nix            # Creative tools (Audio, Video, Graphic design)
│   │       ├── creative-light.nix      # Lighter creative tools
│   │       └── development.nix         # Development tools (Docker, etc.)
│   │
│   └── nixos/                          # NixOS-specific modules
│       ├── default.nix                 # Entry point: auto-imports all modules
│       ├── common.nix                  # NixOS common settings
│       ├── sops.nix                    # Secrets management via sops-nix
│       ├── tailscale.nix               # Tailscale VPN configuration
│       ├── wsl.nix                     # WSL2-specific configuration
│       ├── wsl-docker.nix              # WSL2 Docker integration
│       ├── wsl-gpu.nix                 # WSL2 GPU passthrough (NVIDIA)
│       │
│       ├── apps/                       # App modules for NixOS
│       │   ├── desktop.nix             # Desktop environment packages
│       │   └── development/            # Development tools
│       │       ├── default.nix
│       │       └── docker.nix
│       │
│       └── greeters/                   # Login screen alternatives
│           ├── regreet.nix             # Greeter for Wayland
│           └── tuigreet.nix            # TUI login for headless/SSH
│
├── users/                              # Per-user home-manager configurations
│   └── michael/                        # Primary user account
│       ├── default.nix                 # User account definition + home-manager entry point
│       ├── common/                     # Shared across all platforms/hosts
│       │   ├── home.nix                # Home-manager base (stateVersion, programs)
│       │   ├── core/                   # Core user tools
│       │   │   ├── default.nix
│       │   │   └── git/                # Git configuration
│       │   │       └── default.nix
│       │   │
│       │   ├── shells/                 # Shell configurations
│       │   │   ├── default.nix
│       │   │   └── zsh/                # Zsh shell config
│       │   │       └── default.nix
│       │   │
│       │   ├── tui/                    # Terminal UI applications
│       │   │   ├── default.nix
│       │   │   ├── gitui.nix           # Git UI client
│       │   │   ├── mosaic.nix          # Custom mosaic terminal app
│       │   │   ├── zellij/             # Terminal multiplexer
│       │   │   │   └── default.nix
│       │   │   └── lesspipe/           # Less file preview
│       │   │       └── default.nix
│       │   │
│       │   ├── desktop/                # Desktop environment (GUI)
│       │   │   ├── default.nix
│       │   │   ├── terminals/          # Terminal emulators
│       │   │   │   └── default.nix     # Kitty terminal
│       │   │   │
│       │   │   ├── development/        # GUI development tools
│       │   │   │   ├── default.nix
│       │   │   │   └── nvim.nix        # NeoVim (from Mosaic custom package)
│       │   │   │
│       │   │   └── creative/           # Creative GUI apps
│       │   │       └── default.nix
│       │   │
│       │   ├── dev/                    # Developer utilities
│       │   │   ├── default.nix
│       │   │   └── kubeconfig.nix      # Kubernetes configuration
│       │   │
│       │   ├── tui-server/             # Server-specific TUI tools
│       │   │   └── default.nix
│       │   │
│       │   └── ai-tools/               # AI/LLM integration tools
│       │       └── claude-code/        # Claude AI integration
│       │           └── default.nix
│       │
│       ├── darwin/                     # macOS-specific user configs
│       │   └── default.nix             # Darwin home-manager options
│       │
│       ├── linux/                      # Linux-specific user configs
│       │   ├── default.nix
│       │   ├── apps/                   # Linux GUI applications
│       │   │   └── default.nix
│       │   ├── hyprland/               # Hyprland wayland compositor config
│       │   │   └── default.nix
│       │   ├── hyprlock/               # Hyprland screen lock
│       │   │   └── default.nix
│       │   ├── hypridle/               # Hyprland idle manager
│       │   │   └── default.nix
│       │   ├── waybar/                 # Wayland status bar
│       │   │   └── default.nix
│       │   ├── swaync/                 # Wayland notification center
│       │   │   └── default.nix
│       │   └── walker/                 # Wayland app launcher
│       │       └── default.nix
│       │
│       └── hosts/                      # Host-specific user configurations
│           ├── bowser.nix              # macOS: imports darwin + common configs
│           ├── ganon.nix               # NixOS gaming: imports linux + desktop configs
│           ├── glados.nix              # NixOS server: imports linux + desktop configs
│           ├── sephiroth.nix           # RK1 dev node: imports minimal + dev configs
│           ├── mantis.nix              # WSL GPU secondary: imports linux + dev configs
│           ├── ocelot.nix              # WSL GPU primary: imports linux + dev configs
│           ├── zenith-1.nix            # K3s control plane: imports minimal + server configs
│           ├── zenith-2.nix            # K3s agent: imports minimal + server configs
│           └── zenith-3.nix            # K3s agent: imports minimal + server configs
│
├── resources/                          # Shared utilities and variables
│   ├── libs.nix                        # Custom library functions (relativeToRoot, scanPaths)
│   ├── vars.nix                        # Centralized variables (user info, emails)
│   └── lib/                            # Resource library modules
│       └── dock.nix                    # macOS dock configuration template
│
├── overlays/                           # Package overrides and customizations
│   └── default.nix                     # Custom packages (Mosaic) and package modifications
│
├── image-builder/                      # Tools for building custom images
│   └── (future: image building scripts)
│
├── docs/                               # Documentation
│   └── (place for technical documentation)
│
├── .devenv/                            # Development environment build artifacts
│   └── (generated by devenv)
│
├── .direnv/                            # direnv cache
│   └── (direnv helper scripts)
│
├── .specify/                           # Spec workflow configuration (if using spec-workflow)
│   └── (specification files)
│
├── specs/                              # Project specifications and requirements
│   ├── 001-nixos-hosts/
│   │   └── checklists/                 # Implementation checklists
│   └── 002-zenith-security/            # Security specifications for cluster
│
├── .planning/                          # GSD workflow planning documents
│   └── codebase/                       # Codebase analysis documents
│       ├── ARCHITECTURE.md             # This generation's output
│       └── STRUCTURE.md                # This file
│
└── .claude/                            # Claude AI integration and workflow configuration
    ├── settings.json                   # Claude workspace settings
    ├── package.json                    # Packages for agents/commands
    ├── agents/                         # Custom agent implementations
    ├── commands/gsd/                   # GSD command implementations
    ├── get-shit-done/                  # GSD workflow framework
    └── hooks/                          # Git hooks and lifecycle scripts
```

## Directory Purposes

**`hosts/` - System Configurations:**
- Purpose: Host-specific entry points that compose system configurations
- Contains: Host-specific NixOS/Darwin configuration files, hardware definitions, disk layouts
- Key files: `default.nix` (entry point), `configuration.nix` (hardware-specific), `disks.nix` (partitioning)
- Organization: Platform folder (`nixos/`, `bowser/`) → host name folder → config files
- Pattern: Each host gets a `default.nix` that imports modules and sets `hostSpec` flags

**`modules/` - Reusable Modules:**
- Purpose: Shared configuration modules for OS-level settings
- Contains: Core tools, platform-specific configurations, application groups, system services
- Key files: `default.nix` in each directory (auto-imports using `scanPaths`)
- Organization: `common/` (cross-platform) → `{darwin,nixos}/` (platform-specific)
- Pattern: Modules are declarative, pure, and composable via imports

**`users/` - User Configurations:**
- Purpose: Home-manager managed user environment and application configurations
- Contains: User account definition, tool configurations, application settings
- Key files: `default.nix` (user definition + home-manager entry), `hosts/*.nix` (per-host user configs)
- Organization: `michael/` (user) → `{common,darwin,linux,hosts}/` (scope) → tools/categories
- Pattern: Category-based organization (core, tui, desktop, dev, ai-tools) allows optional feature composition

**`resources/` - Shared Utilities:**
- Purpose: Provide helper functions and centralized variables across all modules
- Contains: Custom library functions (`relativeToRoot`, `scanPaths`), user metadata variables, UI templates
- Key files: `libs.nix` (functions), `vars.nix` (variables), `lib/dock.nix` (templates)
- Pattern: Exported via `specialArgs` to all module contexts

**`overlays/` - Package Customization:**
- Purpose: Customize and extend nixpkgs packages
- Contains: Package additions (external flakes), package modifications (version/patch overrides)
- Key files: `default.nix` with `additions` and `modifications` attributes
- Pattern: Applied automatically to nixpkgs instance via flake outputs

**`.planning/codebase/` - Analysis Documents:**
- Purpose: Store GSD workflow analysis and implementation guidance
- Contains: Architecture, structure, conventions, testing patterns, technical concerns
- Generated by: `/gsd:map-codebase` command with different focus areas
- Used by: `/gsd:plan-phase` and `/gsd:execute-phase` commands for context

**`.claude/` - AI Integration:**
- Purpose: Configure Claude AI workflow tools and agents
- Contains: Settings, custom agents, GSD workflow implementation, git hooks
- Organization: `agents/` (custom agents), `commands/` (command implementations), `hooks/` (lifecycle scripts)
- Pattern: Enables sophisticated AI-driven development workflows

## Key File Locations

**Entry Points:**
- `flake.nix`: Root flake with inputs, outputs, and system definitions (lines 1-217)
- `hosts/{PLATFORM}/{HOSTNAME}/default.nix`: System configuration entry point
- `users/michael/default.nix`: User account and home-manager entry point
- `users/michael/hosts/{HOSTNAME}.nix`: Per-host user configuration selector

**Configuration:**
- `flake.lock`: Locked dependency versions
- `devenv.nix`: Development environment packages and settings
- `.envrc`: direnv loader configuration
- `resources/vars.nix`: Centralized user and system variables
- `resources/libs.nix`: Custom library functions

**Core Logic:**
- `modules/common/core.nix`: Base system tools and security settings
- `modules/common/host-spec.nix`: Host capability option definitions
- `modules/{darwin,nixos}/default.nix`: Platform module aggregation
- `users/michael/common/home.nix`: Home-manager base settings
- `overlays/default.nix`: Package customizations

**Testing & Quality:**
- `specs/`: Project specifications and implementation checklists
- `.specify/`: Spec workflow configuration
- `TODO.md`: Outstanding tasks and roadmap
- `Nix-Configuration-Architecture-Overview.md`: Architecture documentation

## Naming Conventions

**Files:**
- `.nix` extension for all Nix configuration files
- `default.nix` as module aggregator (auto-imports all files in directory via `scanPaths`)
- `{name}.nix` for single-purpose modules (e.g., `git/default.nix`, `zellij/default.nix`)
- `disks.nix` for disk partitioning declarations (disko format)
- `configuration.nix` for hardware-specific settings

**Directories:**
- Lowercase with hyphens for compound names (`ai-tools`, `creative-light`, `tui-server`)
- Hostname names use gaming/anime theme: `bowser` (macOS), `ganon`/`glados` (gaming), `zenith-*` (cluster), `ocelot`/`mantis` (WSL)
- Platform folders: `darwin/`, `nixos/`, `common/` (three-level organization)
- Category folders in `users/michael/common/`: `core`, `tui`, `desktop`, `dev`, `ai-tools`, `shells`, `tui-server`

**Variables:**
- PascalCase for flake attribute names (`nixosConfigurations`, `darwinConfigurations`)
- camelCase for Nix variables and function names (`specialArgs`, `relativeToRoot`, `scanPaths`)
- UPPERCASE for environment variables and kernel parameters

**Module Options:**
- Defined with `lib.mkOption` in modules (see `modules/common/host-spec.nix`)
- Accessed via `config.{optionPath}` in modules (e.g., `config.hostSpec.isGaming`)
- Set via `{ optionPath = value; }` in consuming modules

## Where to Add New Code

**New Host Configuration:**
1. Create directory: `hosts/nixos/{HOSTNAME}/` or `hosts/{HOSTNAME}/` for Darwin
2. Create `default.nix` with imports (see `hosts/nixos/ganon/default.nix` as template):
   - Import disko for NixOS or nix-homebrew for Darwin
   - Import common modules: `modules/nixos/common.nix` or `modules/darwin/default.nix`
   - Import platform app modules as needed
   - Import user: `users/michael`
   - Set `hostSpec` flags to enable conditional logic
   - Configure hardware/boot specific settings
3. Add disk layout: `disks.nix` using disko format
4. Add hardware config: `configuration.nix` for system-specific settings
5. Add host-specific user config: `users/michael/hosts/{HOSTNAME}.nix`
   - Import `../darwin` or `../linux` + `../common/*` categories as needed

**New System Module:**
1. Create file: `modules/{darwin,nixos}/{functionality}.nix` or create category directory with `default.nix`
2. Accept `specialArgs` parameters to use shared context (see lines 1-5 of any module)
3. Use `myLibs.relativeToRoot` for absolute imports within module
4. Place in appropriate tier:
   - Common tools/config → `modules/common/{name}.nix`
   - Darwin-specific → `modules/darwin/{name}.nix`
   - NixOS-specific → `modules/nixos/{name}.nix`
5. Export via automatic `scanPaths` (no manual registration needed if using `default.nix`)

**New User Configuration:**
1. Create directory: `users/michael/{scope}/{category}/` where scope is `common`, `darwin`, or `linux`
2. Create `default.nix` with home-manager program/services configuration
3. If category is new, add to appropriate `default.nix` import list:
   - Platform-common categories → `users/michael/hosts/{HOSTNAME}.nix`
   - Darwin-specific → `users/michael/darwin/default.nix`
   - Linux-specific → `users/michael/linux/default.nix`
4. For host-specific user configs: create `users/michael/hosts/{HOSTNAME}.nix` if missing, follow pattern of `bowser.nix`

**New Application Configuration:**
1. Determine scope:
   - Cross-platform + all hosts → `users/michael/common/{category}/{app}/default.nix`
   - Platform-specific → `users/michael/{darwin,linux}/{category}/` or create app-specific directory
   - Single host → `users/michael/hosts/{HOSTNAME}.nix` inline config
2. Use home-manager programs.{APP} or services.{APP} for configuration
3. Register in category's `default.nix` via imports or add new category folder

**New Host Capability Flag:**
1. Add option to `modules/common/host-spec.nix` (follow pattern lines 20-56)
2. Set flag in host's `default.nix` (see `hostSpec.isGaming = true` in ganon config)
3. Use in conditional logic: `lib.mkIf config.hostSpec.{flagName} { ... }`

**New Shared Variable:**
1. Add to `resources/vars.nix` structure
2. Access in modules via `specialArgs.myVars.{path}`
3. Example: `specialArgs.myVars.users.michael` (current user variables)

**New Custom Library Function:**
1. Add to `resources/libs.nix`
2. Export via `myLibs` in specialArgs
3. Use in modules as `myLibs.{functionName}`

## Special Directories

**`.planning/codebase/`:**
- Purpose: Store architecture and pattern analysis documents
- Generated: By `/gsd:map-codebase` command
- Contents: ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, TESTING.md, CONCERNS.md
- Committed: Yes, part of repository for team context
- Updated: Periodically when architecture changes significantly

**`specs/`:**
- Purpose: Store project specifications and implementation requirements
- Generated: By team/planning process
- Contents: Numbered spec directories (001-nixos-hosts, 002-zenith-security)
- Committed: Yes, source of truth for requirements
- Pattern: Each spec has checklists/ subdirectory for tracking completion

**`.specify/`:**
- Purpose: Workflow framework configuration for spec-based development
- Generated: By `/install-workflow` command if enabled
- Contents: Specification and workflow metadata
- Committed: Yes, if framework is in use
- Updated: During workflow execution

**`.devenv/`:**
- Purpose: Development environment build artifacts
- Generated: By devenv tool (automatic)
- Contents: Built environment, dependencies, caches
- Committed: No (in .gitignore)
- Cleaned: Via `devenv prune`

---

*Structure analysis: 2026-03-08*
