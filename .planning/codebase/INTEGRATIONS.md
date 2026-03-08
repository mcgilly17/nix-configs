# External Integrations

**Analysis Date:** 2026-03-08

## APIs & External Services

**VPN/Network:**
- Tailscale VPN - Mesh networking across all hosts
  - SDK: tailscale CLI/service
  - Auth: Tailscale login via web portal
  - Integration: `modules/nixos/tailscale.nix`
  - Feature: Mullvad exit node integration enabled for privacy

**Git Hosting:**
- GitHub - Primary git hosting and automation
  - SDK: GitHub CLI (gh) with 1Password integration
  - Auth: SSH key + 1Password shell plugin
  - Configuration: `users/michael/common/core/git/default.nix`
  - Git protocol: SSH (configured for all github.com access)

- GitLab - Secondary git hosting support
  - Auth: SSH key (configured as fallback)
  - Configuration: SSH URL transformation in git config

- Bitbucket - Tertiary git hosting
  - Auth: SSH key (configured as fallback)

**Workflow/DevOps:**
- GitHub Actions - CI/CD (not directly configured in dotfiles, but used)
- Flux CD - GitOps for K3s cluster (`users/michael/common/tui-server/default.nix` has fluxcd)

## Data Storage

**Databases:**
- Supabase (PostgreSQL) - Local development via Docker
  - Connection: `npx supabase start` (via Docker compose)
  - Location: Mentioned in `modules/nixos/apps/development/docker.nix`
  - Client: Docker-based (managed by Supabase CLI)

**Shell History:**
- Atuin - SQLite-based command history replacement
  - Storage: SQLite database
  - Sync: Cloud sync available (not configured)
  - Location: User home-manager config

**File Storage:**
- Local filesystem only - No cloud storage configured in dotfiles

**Caching:**
- None detected in core configuration

## Authentication & Identity

**Auth Provider:**
- Custom SSH Key-based authentication
  - Implementation: EdDSA SSH keys (ed25519)
  - SSH key location: `~/.ssh/id_ed25519` (provisioned via SOPS)
  - Used for: Git (GitHub, GitLab, Bitbucket), SSH server access

- 1Password - Password manager and credential provider
  - Implementation: 1Password GUI (enabled on non-WSL NixOS systems)
  - Location: `modules/nixos/apps/desktop.nix`, `modules/nixos/common.nix`
  - Integration: 1Password shell plugins for `op plugin run -- gh`
  - Policy: Requires Polkit authorization

- Age encryption - Secrets encryption
  - Implementation: Age symmetric encryption with SSH key derivation
  - Key derivation: SSH public key → age key via ssh-to-age
  - System key: Generated from `/etc/ssh/ssh_host_ed25519_key`
  - User key: Derived from user's SSH key and stored at `~/.config/sops/age/keys.txt`

**SSH Access:**
- SSH server enabled on all NixOS hosts (`services.openssh`)
- SSH key authentication only (PasswordAuthentication = false)
- Root login enabled by default for nixos-anywhere deployments (can be overridden per-host)

## Monitoring & Observability

**Error Tracking:**
- None detected

**Logs:**
- Systemd journal (default NixOS logging)
- Temperature monitoring via Industrial I/O sensors on RK1 nodes (`hardware.sensor.iio.enable`)
- Container logs via k9s on cluster nodes

**System Monitoring:**
- k9s - Kubernetes cluster monitoring and debugging
- htop - Process monitoring on all nodes
- btop - Advanced resource monitoring
- lm_sensors - Hardware temperature on x86_64 systems
- Health checks: udev rules for hardware monitoring (liquidctl, OpenRGB)

## CI/CD & Deployment

**Hosting/Deployment:**
- NixOS bare metal - Deployed via nixos-anywhere
- macOS (nix-darwin) - Manual/automated setup via flake
- Kubernetes (K3s) - 3-node ARM64 cluster on RK1 devices (zenith-1/2/3)
- WSL2 - Windows Subsystem for Linux 2 on Windows machines (ocelot, mantis)

**Deployment Tools:**
- nixos-anywhere - Remote NixOS installation (`inputs.nixos-anywhere` in flake.nix)
- Nix flakes - Reproducible system configurations
- Disko - Declarative disk partitioning during deployment (`inputs.disko`)

**K3s/Kubernetes:**
- K3s server (control plane) on zenith-1
- K3s agents on zenith-2, zenith-3
- Token-based cluster authentication via SOPS (`sops.secrets."zenith/k3s_token"`)
- Traefik disabled (custom deployment planned)
- ServiceLB disabled (MetalLB or alternative planned)
- Flannel networking with host-gw backend

**Cluster Storage:**
- iSCSI support via openiscsi (`services.openiscsi` on RK1 nodes)
- Longhorn block storage compatible (nsenter support with /usr/local/bin symlink)

## Environment Configuration

**Required environment variables:**
- No application-level env vars detected (configuration-driven via Nix)
- System-level vars for Wayland (set in `modules/nixos/ganon/configuration.nix`):
  - `WLR_NO_HARDWARE_CURSORS` - NVIDIA Wayland workaround
  - `GBM_BACKEND=nvidia-drm` - NVIDIA GBM backend
  - `__GLX_VENDOR_LIBRARY_NAME=nvidia` - NVIDIA driver selection
  - `NIXOS_OZONE_WL=1` - Electron Wayland support
  - `QT_QPA_PLATFORM=wayland` - Qt Wayland
  - `MOZ_ENABLE_WAYLAND=1` - Firefox Wayland

**Secrets location:**
- Private repository: `git+https://github.com/mcgilly17/nix-secrets.git`
- SOPS secrets file: `inputs.nix-secrets + "/secrets.yaml"`
- System secrets decrypted to: `/run/secrets/` (ephemeral)
- SSH private key: `/run/secrets/private_keys/michael` (provisioned via SOPS)
- Age key location: `~/.config/sops/age/keys.txt` (user, derived from SSH key)

## Webhooks & Callbacks

**Incoming:**
- K3s cluster uses tokens for authentication (no webhook integrations detected)
- Git hooks enabled: `git-hooks.hooks` in devenv.nix (nixfmt, statix, deadnix)

**Outgoing:**
- None detected in configuration
- Tailscale may have outbound connectivity to Tailscale coordination servers
- GitHub API calls via `gh` CLI tool

## External Flake Inputs

**Infrastructure/System:**
- `nixpkgs/nixos-unstable` - Latest nixpkgs packages
- `nixpkgs-stable/release-23.11` - Stable package source (fallback)
- `nix-hardware` - Hardware configurations and quirks
- `home-manager/master` - User configuration management
- `nix-darwin` - macOS system management
- `nix-homebrew` - Homebrew integration for macOS
- `nixos-wsl` - NixOS on Windows Subsystem for Linux
- `nixos-anywhere` - Remote NixOS installation
- `disko` - Disk partitioning

**Secrets & Security:**
- `sops-nix` - SOPS secrets integration with age encryption
- `_1password-shell-plugins` - 1Password CLI integration

**UI/Theming:**
- `catppuccin/nix` - Catppuccin color theme (applied system-wide and in applications)
- `walker` - Wayland application launcher (v2)

**Cluster:**
- K3s (via NixOS module) - Lightweight Kubernetes
- Flannel (default K3s CNI) - Pod network

---

*Integration audit: 2026-03-08*
