# Codebase Concerns

**Analysis Date:** 2026-03-08

## Tech Debt

### Darwin/macOS App Distribution Model
- Issue: macOS UI apps cannot be fully declaratively managed through Nix. Apps like Raycast, Superhuman, Discord, etc. are installed via homebrew-cask, not Nix packages. This creates a split between declarative (Nix) and imperative (Homebrew) package management.
- Files: `modules/darwin/apps/default.nix` (lines 41-144), `hosts/bowser/default.nix`
- Impact: Cannot guarantee reproducibility across macOS machines; brew package versions aren't locked; manual macOS App Store installs required (masApps depend on pre-purchased apps)
- Fix approach: Accept this as a Darwin limitation and document the hybrid model clearly. Consider using `nix-homebrew` more extensively for CLI tools to maximize Nix coverage.

### Darwin-specific SSH Key Management
- Issue: Darwin hosts don't have host-level SSH keys (`/etc/ssh/ssh_host_ed25519_key`), so they cannot follow the pattern used by NixOS hosts. Currently using user-level SSH key derivation (`&michael` in .sops.yaml) for Darwin secret decryption.
- Files: `modules/nixos/sops.nix` (lines 6-11, 32-36), `hosts/darwin/*/default.nix` (not explicitly shown but referenced in spec)
- Impact: Different secret decryption mechanism for Darwin vs. NixOS creates cognitive load; if user SSH key is compromised, both host types are affected
- Fix approach: Document this design decision clearly in architecture. Consider adding host-level SSH keys to Darwin if nix-darwin adds support, or use fixed user SSH key for all Darwin hosts.

### Unstable Channel Dependency
- Issue: Flake uses `nixos-unstable` for primary nixpkgs input and `home-manager/master` branch. Unstable channels can have breaking changes, package regressions, or temporary unfixable packages.
- Files: `flake.nix` (lines 8, 16)
- Impact: Rebuilds can fail unexpectedly if unstable channel breaks; reproducibility across time is compromised; RK1 cluster may face availability issues if critical ARM64 packages regress
- Fix approach: Pin to `nixos-stable` releases (e.g., `nixos-24.11`) and use `nixpkgs-stable` (currently line 9) as fallback. Test package availability on ARM64 before major rebuilds. Consider separate stable/unstable strategies per host (dev hosts on unstable, cluster on stable).

### nix-darwin auto-optimise-store Disabled
- Issue: `auto-optimise-store` is disabled due to a known nix issue (#7273) involving store links. This means the store won't be optimized, potentially wasting disk space through duplicate content.
- Files: `modules/darwin/nix-core.nix` (lines 25-31)
- Impact: Nix store grows larger than necessary; performance is slightly worse; disk usage higher on macOS machines
- Fix approach: Monitor nix issue #7273 for resolution. Test re-enabling on bowser periodically. If unresolved, document as permanent Darwin limitation and monitor store size.

## Known Bugs

### Missing 1Password CLI Wrapper Logic on Non-WSL
- Issue: `hosts/nixos/wsl/common/default.nix` defines `op-wsl` wrapper specifically for WSL. Non-WSL Linux hosts (Ganon, GLaDOS, RK1) may not have proper 1Password CLI integration since they use native Linux 1Password but the wrapper script only handles WSL redirection.
- Files: `hosts/nixos/wsl/common/default.nix` (lines 9-24)
- Impact: Non-WSL hosts might fail to use `op` CLI if they expect the WSL wrapper behavior; error message will reference Windows paths that don't exist on Linux
- Trigger: Running `op` command on Ganon, GLaDOS, or RK1 nodes after sops tries to use it
- Workaround: Use full path `/nix/store/.../bin/op` or ensure 1Password package is installed normally on non-WSL hosts
- Fix approach: Add conditional import in common NixOS module to load platform-appropriate 1Password setup. Non-WSL systems should use 1password package directly from nixpkgs.

### SOPS User Age Key Derivation Warning Path
- Issue: If SSH private key secret fails to decrypt or is missing, the activation script logs warning "SSH key not found" but doesn't fail the build. Home Manager will then fail silently when it tries to decrypt user secrets.
- Files: `modules/nixos/sops.nix` (lines 86-89)
- Impact: SSH key missing will cause Home Manager activation failures with cryptic age key errors; not caught until Home Manager tries to decrypt
- Trigger: Rebuild a host when nix-secrets is inaccessible or SSH key path is wrong
- Workaround: Check `/run/secrets/private_keys/michael` manually after activation; rebuild with valid nix-secrets access
- Fix approach: Add explicit activation script error (not warning) if SSH key is missing. Fail fast with clear message rather than defer to Home Manager.

## Security Considerations

### Tailscale Lateral Movement Risk (CRITICAL - Active Spec)
- Risk: Currently all devices on Tailscale can reach each other. If any single machine is compromised, attacker can pivot to other machines (laptops, phones, servers) via Tailscale network.
- Files: `modules/nixos/tailscale.nix`, `modules/darwin/tailscale.nix` (no explicit ACL configuration)
- Current mitigation: None - this is documented as open security gap in `specs/002-zenith-security/spec.md`
- Recommendations: Implement Tailscale ACLs immediately (P0):
  - Tag k3s cluster nodes with `tag:k3s` (can only reach each other on cluster ports)
  - Tag sephiroth with `tag:server` (restricted access)
  - Tag admin devices with `tag:admin` (unrestricted outbound)
  - Block SSH between servers entirely - only admin can SSH to servers
  - Test ACLs before deployment to avoid lockout

### K3s Cluster Join Token Static
- Risk: K3s cluster join token is stored in configuration but never rotated. If token is exposed, attacker can join rogue node to cluster.
- Files: `hosts/nixos/rk1/zenith-1/default.nix` (presumed - not fully visible)
- Current mitigation: Token stored in private nix-secrets repo
- Recommendations: Implement token rotation mechanism:
  - Generate short-lived join tokens via k3s API
  - Rotate every 90 days
  - Log all token usages
  - Consider external secrets operator for sensitive k3s values

### Pod Security Standards Not Enforced
- Risk: K3s cluster has no Pod Security Standards or NetworkPolicies. Containers can run with root privileges, mount host filesystems, and communicate freely between pods.
- Files: No hardening modules found in codebase
- Current mitigation: None
- Recommendations: Implement (from `specs/002-zenith-security/spec.md`):
  - Apply Pod Security Standards "restricted" policy to production namespaces
  - Default-deny NetworkPolicy requiring explicit allow
  - Audit mode initially, then enforce
  - Verify containers run as non-root, drop capabilities, set read-only root FS

### /run/secrets Permissions Weak
- Risk: `/run/secrets` created by sops-nix may have world-readable permissions allowing unprivileged users/containers to read secrets.
- Files: `modules/nixos/sops.nix` (lines 41-44) - file permissions set to 0400, but directory permissions not explicit
- Current mitigation: Individual files set to 0400 mode, but directory traversal may be possible
- Recommendations: Explicitly set `/run/secrets` directory to 0700 (root-only) and verify in tests

### allowUnfree Globally Enabled
- Risk: `allowUnfree = true` globally in nixpkgs config means unfree packages can be installed without review. Some unfree packages may have license restrictions or security implications.
- Files: `modules/nixos/common.nix` (line 29), `modules/darwin/nix-core.nix` (line 18), `.devenv.flake.nix`
- Current mitigation: Necessary for some packages (NVIDIA drivers, 1Password, etc.) but broad
- Recommendations: Add whitelist of known-necessary unfree packages instead of blanket allow. Document which packages require unfree and why.

### nix-secrets Repository Private Access
- Risk: If GitHub account is compromised or nix-secrets repo is exposed, all secrets (SSH keys, passwords, API tokens, host keys) are available to attacker.
- Files: `flake.nix` (lines 87-90) - shallow clone via HTTPS
- Current mitigation: Private repository, shallow clone to minimize history, SSH authentication via gh
- Recommendations:
  - Add additional layer: age encryption on top of repo-level access control
  - Consider HashiCorp Vault for highly sensitive values
  - Enable GitHub branch protection rules (require PR reviews)
  - Rotate nix-secrets deploy key regularly

### WSL 1Password CLI Integration Failure Handling
- Risk: If Windows 1Password CLI folder cannot be found (WinGet Packages path wrong, or 1Password not installed), the wrapper script returns cryptic error message without clear remediation.
- Files: `hosts/nixos/wsl/common/default.nix` (lines 16-19)
- Current mitigation: Error message printed to stderr, exit code 1
- Recommendations: Detect 1Password installation at activation time; provide clear setup instructions; fail during build if required for WSL config

## Performance Bottlenecks

### RK1 Cluster ARM64 Package Availability
- Problem: Some packages may not have pre-built ARM64 binaries in nixpkgs unstable. RK1 nodes will need to compile from source, which is slow on limited RK3588 hardware (4-8 cores, ~4GB RAM).
- Files: `hosts/nixos/rk1/common/default.nix`, `flake.nix` (nixos-unstable channel)
- Cause: ARM64 is secondary platform; maintainers prioritize x86_64; binary caches may lag
- Improvement path:
  - Monitor rebuild times for dev server (sephiroth) which can cross-compile for RK1
  - Use sephiroth as binary cache for RK1 nodes
  - Pin to stable channel for RK1 cluster to maximize binary availability
  - Pre-compile critical packages during development phase

### Nix Store Link Contention on macOS
- Problem: Despite `auto-optimise-store = false`, periodic manual store optimization is needed. Without it, disk space grows and rebuild times can degrade as store becomes larger.
- Files: `modules/darwin/nix-core.nix` (lines 25-31)
- Cause: nix issue #7273 prevents automatic optimization but manual `nix store optimize` is workaround
- Improvement path: Add periodic nix store cleanup via cron job or systemd timer on macOS

### Flake Lock File Size
- Problem: Flake.lock includes many inputs (nixpkgs, nixpkgs-stable, home-manager, darwin, sops-nix, disko, nixos-wsl, etc.). Frequent updates slow down git operations and increase clone time.
- Files: `flake.lock` (currently 19KB, visible in `git status`)
- Cause: Unavoidable when using many flake inputs
- Improvement path:
  - Consider bundling stable external modules into monorepo
  - Use flake2nix to simplify inputs
  - Document flake.lock update cadence (monthly vs. as-needed)

## Fragile Areas

### Host Specification Pattern (hostSpec)
- Files: `modules/common/host-spec.nix` (defines options), used throughout in `lib.mkIf` conditions
- Why fragile: The `hostSpec` pattern relies on correct attribute setting in each host config. If a host forgets to set `isWSL = true` or `isClusterNode = true`, features silently disable or enable incorrectly. No validation layer checks for required spec values.
- Safe modification:
  - Add strict validation in modules that depend on hostSpec values
  - Use assertions to fail fast if required specs are missing
  - Add documentation of required spec values per host type
  - Consider using `lib.mkOptionType` to create a schema-checked type
- Test coverage: Missing - no tests verify that hostSpec settings propagate correctly to module conditions

### sops-nix SSH Key Derivation Chain
- Files: `modules/nixos/sops.nix` (entire file, especially lines 49-91)
- Why fragile: Complex activation script logic with multiple file operations, permission changes, and key derivations. If any step fails (mkdir, chown, chmod, ssh-to-age), subsequent steps don't run but system still boots. Missing SSH key causes Home Manager to fail during next activation.
- Safe modification:
  - Add intermediate checkpoints with clear error messages
  - Use systemd-tmpfiles for directory creation (more robust than shell mkdir)
  - Add activation script dependencies to ensure order
  - Create integration test that verifies age key is correctly placed and readable
- Test coverage: No automated tests verify this flow end-to-end

### Docker GPU Support on WSL
- Files: `modules/nixos/wsl-docker.nix` (lines 23-27), particularly the `suppressNvidiaDriverAssertion = true` workaround
- Why fragile: NVIDIA container toolkit assertion is suppressed because WSL provides drivers from Windows. If assertion logic changes in nixpkgs or WSL driver behavior changes, the workaround may break silently or cause unexpected behavior.
- Safe modification:
  - Document the exact NVIDIA Container Toolkit version this workaround applies to
  - Monitor for assertion changes in nixpkgs
  - Add test that verifies GPU access works in a test container (e.g., `docker run --gpus all nvidia/cuda:12.0 nvidia-smi`)
  - Create fallback manual driver setup if assertion is re-enabled
- Test coverage: Missing - no automated GPU tests

### RK1 Kernel Module Dependencies
- Files: `hosts/nixos/rk1/common/default.nix` (lines 51-71 initrd.availableKernelModules, lines 63-71 kernelModules)
- Why fragile: Specific RK3588 kernel modules (`rockchipdrm`, `panfrost`, `fusb302`) are listed but not verified to exist or load correctly. If nixpkgs updates kernel and removes/renames a module, boot will fail. The FHS symlink workaround for Longhorn (line 130) is also fragile.
- Safe modification:
  - Add kernel module availability checks in activation script
  - Document the RK3588 kernel version this was tested with
  - Monitor kernel updates for RK3588 support changes
  - Test boot on actual hardware after kernel updates (or use CI emulation)
- Test coverage: No automated kernel module verification

### ARM64 Package Build Assumptions
- Files: `flake.nix` (supports aarch64-linux, aarch64-darwin), `hosts/nixos/rk1/common/default.nix`, `resources/vars.nix` (presumed)
- Why fragile: Assumption that all packages in nixpkgs-unstable have ARM64 builds available. Some packages may only be x86_64. If a package is required for RK1 and has no ARM64 build, the entire rebuild fails with cryptic error about missing binary.
- Safe modification:
  - Add pre-flight check in flake that lists packages missing ARM64 support
  - Use `pkgsCross` to cross-compile critical packages from sephiroth dev server
  - Fall back to stable channel for cluster nodes which have better ARM64 coverage
  - Document which packages are known to be x86_64-only and their workarounds
- Test coverage: No cross-compilation validation in CI

## Scaling Limits

### nix-secrets Repository Shallow Clone Efficiency
- Current capacity: Shallow clone with `?shallow=1` reduces initial clone from full history to single commit
- Limit: As secrets accumulate over time, even single-commit shallow clone grows. Very large encrypted files (backups, key material) in secrets.yaml can slow down flake evaluation.
- Scaling path:
  - Split secrets by environment (prod, staging, dev) into separate repos
  - Archive old secrets to separate history repo
  - Consider git LFS for large secret files
  - Monitor secrets.yaml file size and split if > 1MB

### Flake Inputs Lock File Maintenance
- Current capacity: 8+ external flake inputs (nixpkgs, home-manager, darwin, sops-nix, disko, nixos-wsl, nixos-anywhere, nix-secrets)
- Limit: Each input can have upstream breaking changes. Managing updates across all becomes O(n) work. If input is added every quarter, maintenance burden grows.
- Scaling path:
  - Document flake input update process (e.g., monthly batches)
  - Use renovatebot or dependabot for automated PR updates
  - Consider dropping rarely-used inputs (e.g., nixos-anywhere if not deploying to new hosts)
  - Create CI workflow that checks for security updates

### RK1 Cluster State Storage
- Current capacity: Local Longhorn storage using iSCSI on eMMC/NVMe (setup in `hosts/nixos/rk1/common/default.nix` line 70)
- Limit: Single Turing Pi 2 cluster with 4 nodes sharing same physical storage. If Longhorn becomes production workload with many pods, storage becomes bottleneck. Recovery from disk failure affects all 4 nodes.
- Scaling path:
  - Add external storage backend (NAS, cloud storage)
  - Implement incremental backups via restic or Velero
  - Add disk redundancy (RAID setup in storage configuration)
  - Monitor disk I/O and plan storage upgrade before 80% capacity

### Home-Manager Module Imports
- Current capacity: Multiple users (michael), multiple hosts (Darwin + NixOS), multiple user configs (common/darwin/linux/hosts specific)
- Limit: As user configs grow, home-manager activation time increases. If another user is added, imports multiply.
- Scaling path:
  - Profile home-manager activation time
  - Consider lazy-loading rarely-used configs
  - Split home-manager configs into optional modules that can be disabled per host
  - For multi-user support: test that user-specific configs don't interfere

## Dependencies at Risk

### nixpkgs-unstable Channel Stability
- Risk: Unstable channel is moving target. Package regressions, temporary broken packages, or removal of packages can happen at any time.
- Impact: Unexpected build failures on rebuilds; RK1 cluster availability at risk if critical ARM64 package regresses
- Current status: Using `nixos-unstable` as primary input (flake.nix line 8)
- Migration plan:
  - Switch to `nixos-24.11` stable release for cluster nodes
  - Keep dev hosts on unstable for latest tools
  - Use `nixpkgs-stable` as fallback for unavailable packages
  - Set up monitoring for package availability on ARM64

### home-manager master Branch
- Risk: home-manager is pinned to `master` branch, not a tagged release. Master can have breaking changes.
- Impact: Random activation failures when master is updated with incompatible changes
- Current status: `home-manager/master` in flake.nix line 16
- Migration plan:
  - Pin to latest stable release tag (e.g., `release-24.11`)
  - Test release upgrades before applying to all hosts
  - Keep CI workflow that tests against both master and stable

### nix-homebrew Maintenance
- Risk: `nix-homebrew` is community-maintained and may be abandoned. Also bridges Nix and Homebrew which can have version conflicts.
- Impact: macOS package management could break; Homebrew cask updates may not work through Nix
- Current status: Used for macOS app management (`modules/darwin/apps/default.nix`)
- Migration plan:
  - Monitor nix-homebrew repository for maintainer activity
  - Consider moving critical apps to native Nix packages or App Store
  - Test regular homebrew updates still work through Nix wrapper
  - Prepare fallback to pure homebrew if nix-homebrew becomes unmaintained

### sops-nix Project
- Risk: sops-nix is critical to entire secrets architecture. Project abandonment would require complete secrets redesign.
- Impact: Cannot decrypt existing secrets; all systems fail to activate
- Current status: Using `sops-nix` with custom activation scripts
- Migration plan:
  - Monitor sops-nix for activity and security issues
  - Document exact sops-nix version being used
  - Have backup secrets stored externally (outside sops-nix) for emergency recovery
  - Consider adding HashiCorp Vault as alternative secrets backend

## Missing Critical Features

### Pod Security Standards Not Deployed
- Problem: K3s cluster running without Pod Security Standards. Workloads can run with dangerous privileges.
- Blocks: Cannot run production-grade workloads; security audit will fail; cluster cannot meet compliance requirements
- Spec reference: `specs/002-zenith-security/spec.md` requirement R3
- Implementation: Create `kubernetes/security/pod-security-standards.yaml` with restricted policies

### Cluster Network Policies Missing
- Problem: No NetworkPolicies in k3s cluster means pods can communicate freely, increasing blast radius of compromised pod.
- Blocks: Cannot isolate workloads; HIPAA/PCI compliance impossible; lateral movement unrestricted
- Spec reference: `specs/002-zenith-security/spec.md` requirement R3
- Implementation: Create `kubernetes/security/network-policies.yaml` with default-deny ingress/egress

### Tailscale ACLs Not Configured
- Problem: All Tailscale devices can reach all other devices. Single compromised server endangers entire fleet.
- Blocks: Cannot deploy to production; fails security audit; violates principle of least privilege
- Spec reference: `specs/002-zenith-security/spec.md` requirement R1
- Implementation: Set ACL policy in Tailscale admin console (JSON policy provided in spec)
- Priority: CRITICAL - should be implemented immediately

### Audit Logging Not Enabled
- Problem: K3s cluster has no audit logging. Security events (API calls, authentication attempts) are not recorded.
- Blocks: Cannot investigate security incidents; cannot meet compliance logging requirements
- Spec reference: `specs/002-zenith-security/spec.md` requirement R3
- Implementation: Enable `--audit-log-maxage=30` and configure audit policy webhook

### GLaDOS Deployment Not Complete
- Problem: GLaDOS (ThinkPad X1 Carbon Gen 8) is still running Windows 11, not deployed to NixOS.
- Blocks: Cannot manage all Linux machines from same flake; manual configuration of GLaDOS required
- Spec reference: `specs/001-nixos-hosts/spec.md` user story 5
- Implementation: Deploy NixOS via USB with Btrfs+LUKS, configure host in flake, add SSH host key to nix-secrets

### Ganon Bootloader Migration
- Problem: Ganon currently uses GRUB bootloader (acknowledged as "ugly" in spec), should use systemd-boot.
- Blocks: Less maintainable dual-boot setup; user dissatisfaction
- Spec reference: `specs/001-nixos-hosts/spec.md` requirement FR-021
- Implementation: Test systemd-boot in VM first, then deploy to Ganon with NVIDIA drivers verification

## Test Coverage Gaps

### Secrets Management End-to-End
- What's not tested: Full flow of secret decryption on actual host hardware
- Files: `modules/nixos/sops.nix`, activation scripts
- Risk: SSH key derivation, age key placement, Home Manager decryption all happen at activation time. Silent failures are possible.
- Priority: HIGH - secrets failure affects entire host

### Cross-Compilation ARM64
- What's not tested: Whether all packages build correctly for ARM64 across unstable channel
- Files: All references to `aarch64-linux` in flake.nix
- Risk: RK1 cluster rebuild could fail if nixpkgs updates break ARM64 support for a critical package
- Priority: HIGH - affects cluster availability

### Host Specification Propagation
- What's not tested: Whether hostSpec values correctly propagate to all module conditions
- Files: `modules/common/host-spec.nix`, all modules using `lib.mkIf config.hostSpec.*`
- Risk: Features could silently enable/disable if hostSpec is set incorrectly
- Priority: MEDIUM - mostly setup-once but error-prone

### NVIDIA Docker GPU Access (WSL)
- What's not tested: Whether GPU containers actually work in WSL with the `suppressNvidiaDriverAssertion` workaround
- Files: `modules/nixos/wsl-docker.nix`
- Risk: GPU support could silently fail if NVIDIA Container Toolkit assertion logic changes
- Priority: MEDIUM - only affects WSL hosts with GPU

### Nix Flake Evaluation
- What's not tested: Whether `nix flake check` passes on all configurations
- Files: All flake.nix outputs for nixosConfigurations and darwinConfigurations
- Risk: Evaluation errors not caught until deployment
- Priority: MEDIUM - should be CI gate

### Darwin Homebrew Cask Updates
- What's not tested: Whether homebrew casks still install correctly after nixpkgs/homebrew updates
- Files: `modules/darwin/apps/default.nix` casks list
- Risk: Cask installation could fail silently during rebuild
- Priority: LOW - detected on first rebuild attempt

---

*Concerns audit: 2026-03-08*
