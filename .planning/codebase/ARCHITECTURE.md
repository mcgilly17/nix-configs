# Architecture

**Analysis Date:** 2026-03-08

## Pattern Overview

**Overall:** Layered module-based declarative system configuration using NixOS flakes with platform abstraction.

**Key Characteristics:**
- Flake-based dependency and output management across multiple systems (Darwin, NixOS, WSL)
- Modular organization separating OS-level modules from user-level home-manager configurations
- Host-specific entry points that compose shared modules based on host capabilities
- Custom library functions (`specialArgs`) injected into all module contexts for shared configuration access
- Platform abstraction using conditional logic (`isDarwin`, `hasGPU`, `isClusterNode`, etc.) to maintain single-source-of-truth for multi-OS deployments
- Home-manager driven per-user configurations that layer across common (shared), OS-specific, and host-specific contexts

## Layers

**Flake Inputs Layer:**
- Purpose: Manage external dependencies and configuration sources
- Location: `/home/michael/Projects/dots/flake.nix` (lines 4-94)
- Contains: Official nixpkgs sources, hardware control, home-manager, darwin configuration framework, secrets management (sops-nix), Catppuccin theming, utilities (disko, nixos-anywhere, 1password), private flake inputs (nix-secrets, Mosaic)
- Depends on: Nothing (root dependency layer)
- Used by: Flake outputs (all system configurations)

**Shared Resources Layer:**
- Purpose: Provide common variables, custom libraries, and utilities accessible across all modules
- Location: `/home/michael/Projects/dots/resources/`
- Contains: Custom library functions (`relativeToRoot`, `scanPaths`), user variables (username, email, git config), dock configuration template
- Depends on: NixLib (Nix standard library)
- Used by: All downstream modules through `specialArgs` injection

**OS-Level Modules Layer (Common):**
- Purpose: Host-agnostic, OS-agnostic core configurations
- Location: `/home/michael/Projects/dots/modules/common/`
- Contains: Base system tools (git, archives, text processing, coreutils), security configuration (sudo), Nix settings (flakes, garbage collection, network tuning)
- Depends on: Nixpkgs, resources layer
- Used by: Both Darwin and NixOS host configurations

**OS-Level Modules Layer (Platform-Specific):**
- Purpose: OS-specific system configurations and package management
- Location: `/home/michael/Projects/dots/modules/darwin/` and `/home/michael/Projects/dots/modules/nixos/`
- Contains:
  - Darwin: Homebrew setup, nix-homebrew integration, window manager (yabai/skhd), system defaults, dock configuration, app categories (desktop, creative, development)
  - NixOS: GPU drivers (NVIDIA), desktop environments (Hyprland), security (sops, tailscale), greeters (regreet, tuigreet), boot configurations, networking
- Depends on: Flake inputs, common modules, shared resources
- Used by: Host-specific configurations to provide OS capabilities

**Overlays Layer:**
- Purpose: Customize and override upstream nixpkgs packages
- Location: `/home/michael/Projects/dots/overlays/default.nix`
- Contains: Package additions (Mosaic custom package), package modifications (templates for version overrides and patches)
- Depends on: Flake inputs
- Used by: All configurations via nixpkgs instance with overlays applied

**Host Configuration Layer (Entry Points):**
- Purpose: Compose and specialize system configurations for specific hardware
- Location: `/home/michael/Projects/dots/hosts/{bowser,nixos/ganon,nixos/glados,nixos/rk1/*,nixos/wsl/*}/`
- Contains: Hardware specifications, disk partitioning, host-specific security settings, network configuration, service configuration
- Depends on: Modules layer, resources layer, user configurations
- Used by: Flake outputs to generate NixOS/Darwin systems

**User Configuration Layer (Home-Manager):**
- Purpose: Manage per-user environment and application configurations
- Location: `/home/michael/Projects/dots/users/michael/`
- Contains:
  - `common/`: Shared across all platforms (core tools, git, shells/zsh, TUI apps, AI tools, development utilities)
  - `darwin/`: macOS-specific home-manager configs
  - `linux/`: Linux-specific home-manager configs (Hyprland, Waybar, Hypridle, Hyprlock, swaync, walker, apps)
  - `hosts/`: Per-host user configurations (bowser, ganon, glados, sephiroth, zenith-1/2/3, mantis, ocelot)
- Depends on: Home-manager framework, modules layer
- Used by: Host configurations to manage user environments

**Disk Layout Layer:**
- Purpose: Declaratively define partitioning and filesystem configuration
- Location: `*/disks.nix` files in host directories
- Contains: Partition schemes, filesystem types, encryption settings
- Depends on: disko flake input
- Used by: Host configurations for automated disk provisioning

## Data Flow

**Host Bootstrap Flow:**

1. User runs `darwin-rebuild switch --flake .#bowser` (Darwin) or `nixos-rebuild switch --flake .#ganon` (NixOS)
2. Flake evaluates inputs (lines 4-94 of `flake.nix`) and creates `specialArgs` with shared context:
   - `inputs`: All flake inputs
   - `outputs`: Flake outputs (for circular references)
   - `myVars`: User variables from `resources/vars.nix` (line 114)
   - `myLibs`: Custom library functions from `resources/libs.nix` (line 115)
   - `nixpkgs`: Nixpkgs instance with overlays
3. Host configuration entry point (`hosts/{HOSTNAME}/default.nix`) is evaluated with `specialArgs`
4. Host imports statement triggers module composition:
   - Common OS modules loaded
   - Platform-specific modules loaded (Darwin or NixOS)
   - Platform-specific app modules loaded (development, desktop, creative)
   - User configurations loaded for current hostname
5. Home-manager hooks into host configuration (see `home-manager.users.${michael.username}` in `/home/michael/Projects/dots/users/michael/default.nix` lines 34-36)
6. Home-manager evaluates host-specific user config from `users/michael/hosts/{HOSTNAME}.nix`
7. Host-specific user config imports platform-agnostic user configs from `users/michael/common/`
8. All modules resolved with `specialArgs` injected at each level
9. Nix builds the system closure and activates configuration

**Configuration Composition Pattern:**

```
flake.nix (inputs + outputs)
  ↓
  specialArgs = {inputs, outputs, myVars, myLibs, nixpkgs}
  ↓
  hosts/{PLATFORM}/{HOSTNAME}/default.nix
  ↓
  imports = [
    modules/{PLATFORM}/{MODULE}.nix      # OS-specific functionality
    modules/common/core.nix              # Base tools
    users/michael                        # User config entry point
  ]
  ↓
  home-manager evaluation:
    users/michael/hosts/{HOSTNAME}.nix
      ↓
      imports = [
        ../common/home.nix
        ../common/core
        ../common/tui
        ../{PLATFORM}                    # OS-specific user configs
      ]
```

**State Management:**

- System state: Managed by NixOS/Darwin system generation (immutable derivations)
- User state: Managed by home-manager with `stateVersion = "24.11"` (line 14 of `users/michael/common/home.nix`)
- Secrets: Injected via sops-nix from private `nix-secrets` flake input, available through `config` in modules
- Variables: Centralized in `resources/vars.nix` with user context (`specialArgs.myVars.users.michael`)
- Host capabilities: Declared in `hostSpec` options (`modules/common/host-spec.nix` lines 8-58) enabling conditional module logic

## Key Abstractions

**Host Specification:**
- Purpose: Provides host capability flags for conditional configuration
- Examples: `hostSpec.isGaming`, `hostSpec.isClusterNode`, `hostSpec.hasGPU`, `hostSpec.isWSL`, `hostSpec.isServer`
- Files: `modules/common/host-spec.nix` (option definitions), host `default.nix` files (value assignment)
- Pattern: NixOS module options system with lib.mkOption for type safety and defaults

**Module Composition via scanPaths:**
- Purpose: Automatically import all `.nix` files in a directory
- Implementation: `myLibs.scanPaths` function in `resources/libs.nix` (lines 6-19)
- Pattern: Uses `builtins.readDir` + filtering to collect all `.nix` files and directories, avoiding `default.nix` duplication
- Usage: Enables directory-based plugin architecture (e.g., `modules/darwin/default.nix` line 3)

**Path Abstraction via relativeToRoot:**
- Purpose: Convert relative paths to absolute project-rooted paths
- Implementation: `myLibs.relativeToRoot` function in `resources/libs.nix` (line 5)
- Pattern: Uses `lib.path.append` to resolve paths relative to flake root
- Usage: Makes imports work regardless of import context (e.g., line 4 of `modules/common/core.nix`)

**Special Arguments Injection:**
- Purpose: Make shared context available in all module evaluations without explicit parameter threading
- Implementation: NixOS `specialArgs` pattern (lines 119-127 of `flake.nix`)
- Contents: `inputs`, `outputs`, `myVars`, `myLibs`, `nixpkgs`
- Pattern: Passed to `darwinSystem` and `nixosSystem` builders, then inherited in every module via function parameters

**Multi-Host Output Pattern:**
- Purpose: Generate multiple system configurations from single flake
- Implementation: `nixosConfigurations` attribute with multiple systems (lines 145-216 of `flake.nix`)
- Pattern: Each host maps to separate `nixpkgs.lib.nixosSystem` call with same `specialArgs` but different modules path
- Enables: `nix flake show` lists all outputs, `--flake .#hostname` targets specific system

## Entry Points

**Darwin System Entry Point:**
- Location: `hosts/bowser/default.nix`
- Triggers: `darwin-rebuild switch --flake .#bowser`
- Responsibilities:
  - Set hostname and computer name (lines 38-43)
  - Import home-manager Darwin module (line 20)
  - Import nix-homebrew module (line 21)
  - Compose common and Darwin-specific modules (lines 23-33)
  - Configure home-manager integration with global packages (lines 47-52)
  - Configure nix-homebrew for declarative package management (lines 56-78)

**NixOS System Entry Points:**
- Location: `hosts/nixos/{ganon,glados}/default.nix` and `hosts/nixos/{wsl,rk1}/{HOSTNAME}/default.nix`
- Triggers: `sudo nixos-rebuild switch --flake .#hostname`
- Responsibilities:
  - Import hardware configuration and disko disk layout
  - Import platform modules (sops, tailscale, etc.)
  - Import app-specific modules (desktop, development)
  - Set host specification flags
  - Configure hardware-specific features (GPU, gaming, clustering)
  - Set networking hostname
  - Configure boot loader and kernel parameters

**User Configuration Entry Point:**
- Location: `users/michael/default.nix`
- Triggers: Host configuration evaluation (automatic via home-manager.users.*)
- Responsibilities:
  - Create user account with platform-specific settings (lines 14-31)
  - Create user group on NixOS (line 31)
  - Import host-specific home-manager config from `users/michael/hosts/{HOSTNAME}.nix` (lines 34-36)
  - Pass specialArgs to home-manager evaluation

**Home-Manager Configuration Entry Points:**
- Location: `users/michael/hosts/{HOSTNAME}.nix`
- Triggers: Home-manager evaluation during host build
- Responsibilities:
  - Import common home-manager base configuration (`common/home.nix`)
  - Import all category-specific configurations (core, tui, desktop, ai-tools, dev, shells)
  - Conditionally import platform-specific configs (darwin vs linux)

## Error Handling

**Strategy:** Declarative validation through NixOS module system with type checking

**Patterns:**
- Module option types defined in `host-spec.nix` with default values (lines 9-57)
- Conditional imports using `lib.optionalAttrs` for platform-specific logic (see `users/michael/default.nix` line 18)
- Secrets validation through sops-nix assertions (configured in `modules/nixos/sops.nix`)
- Boot failure shell fallback via `boot.shell_on_fail` kernel parameter (ganon configuration line 77)
- Type validation via `lib.types.submodule` for structured configuration (host-spec.nix line 11)

## Cross-Cutting Concerns

**Logging:**
- System-level: NixOS journal via systemd (default)
- Nix operations: Controlled via `nix.settings.log-lines` (core.nix line 61, set to 25)

**Validation:**
- Boot validation: GRUB EFI variables check (ganon config line 50)
- Disk validation: disko-nix declarative validation during disk layout
- User validation: NixOS extraGroups validation for permissions (users/michael/default.nix lines 22-26)

**Authentication:**
- System: Sudo enhanced with SSH agent forwarding and password timeout (core.nix lines 37-42)
- SSH: Agent forwarding via `Defaults env_keep+=SSH_AUTH_SOCK` (core.nix line 40)
- Secrets: sops-nix GPG/SSH key based decryption from nix-secrets input

**Secrets Management:**
- Mechanism: sops-nix framework with Age encryption
- Source: Private `nix-secrets` flake input (flake.nix lines 87-90)
- Distribution: Injected into modules via `config.sops` after decryption
- Tools: `sops`, `ssh-to-age`, `age` in system packages (core.nix lines 27-29)

**Theme/UI Consistency:**
- Framework: Catppuccin nix flake input (flake.nix lines 38-41)
- Scope: Darwin dock configuration, desktop environments, terminal emulators
- Application: Custom dock config in `resources/lib/dock.nix`, imported by Darwin modules

---

*Architecture analysis: 2026-03-08*
