# Runbook: Adding a New Device

How to onboard a new machine into this flake. Two flows: **Darwin (macOS)** and
**NixOS**. Repo-side steps can be done before the machine arrives; machine-side
steps happen on first boot.

Related docs:

- [Remote NixOS Deployment Guide](./Remote-NixOS-Deployment-Guide.md) — remote deploys with nixos-anywhere / deploy-rs
- Secrets live in the private [nix-secrets](https://github.com/mcgilly17/nix-secrets) repo, pulled in as a flake input and decrypted with sops-nix + age.

## Naming

Hosts are named after game villains/AIs: bowser, ganon, glados, shodan,
sephiroth, ocelot, mantis, zenith-N. Pick a name not already in `flake.nix`
(`darwinConfigurations` + `nixosConfigurations` + `deploy.nodes`). The hostname
is load-bearing: `users/michael/default.nix` resolves the home-manager config
from `users/michael/hosts/${config.networking.hostName}.nix`.

---

## Darwin (macOS)

### 1. Repo-side (before the machine arrives)

1. **Host config** — copy an existing darwin host and adjust:

   ```bash
   cp -r hosts/bowser hosts/<name>
   ```

   In `hosts/<name>/default.nix`:
   - Update the header comment and `hostname` let-binding.
   - Pick the app profiles to import (`modules/darwin/apps/desktop.nix`,
     `creative.nix` / `creative-light.nix`, `development.nix`).
   - Intel machines: `nix-homebrew.enableRosetta` must stay `false`
     (it's an Apple Silicon-only option); Homebrew lands in `/usr/local`
     automatically.

2. **Flake entry** — add to `darwinConfigurations` in `flake.nix`:

   ```nix
   <name> = darwin.lib.darwinSystem {
     system = "aarch64-darwin"; # or "x86_64-darwin" for Intel
     inherit specialArgs;
     modules = [ ./hosts/<name> ];
   };
   ```

3. **User host file** — create `users/michael/hosts/<name>.nix` (copy
   `bowser.nix`) and pick the home-manager module set for this machine.

4. **Verify it evaluates** (from any machine):

   ```bash
   nix build .#darwinConfigurations.<name>.system --dry-run
   ```

### 2. Secrets — nothing to re-key 🎉

Darwin secrets are **user-level** (sops-nix home-manager module,
`users/michael/darwin/sops.nix`). All Darwin machines share michael's age key,
whose public key is already a recipient in nix-secrets' `.sops.yaml`
(`&michael`). Adding a Darwin host requires **no changes to nix-secrets**.

The age key is the one bootstrap secret — it must be placed manually
(step 3.4 below). Everything else (SSH key, API keys, vault creds) is
decrypted from it on activation.

### 3. Machine-side bootstrap

1. **macOS setup** — create the `michael` user (Darwin's primary user is fixed
   at OS setup), then install Command Line Tools:

   ```bash
   xcode-select --install
   ```

2. **Install Nix** (with flakes enabled), e.g. the Determinate installer:

   ```bash
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```

   **Intel Macs**: Determinate no longer ships x86_64-darwin installers.
   Use the official installer and enable flakes manually (nix-darwin
   manages this after the first switch):

   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   echo "extra-experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
   sudo launchctl kickstart -k system/org.nixos.nix-daemon
   ```

3. **GitHub auth** — nix-secrets is a private repo fetched over https, so git
   needs credentials before the first build:

   ```bash
   nix shell nixpkgs#gh -c gh auth login   # choose HTTPS + configure git
   ```

4. **Place the age key** (the bootstrap secret):

   ```bash
   mkdir -p ~/.config/sops/age
   # Option A: copy keys.txt from 1Password / an existing machine
   # Option B: derive it from the SSH private key if you have that instead:
   #   nix shell nixpkgs#ssh-to-age -c ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   ```

5. **Clone and build**:

   ```bash
   git clone https://github.com/mcgilly17/dots.git ~/Projects/dots
   cd ~/Projects/dots
   sudo nix run nix-darwin -- switch --flake .#<name>
   ```

   First activation will likely abort with "Unexpected files in /etc" —
   installer/macOS-created files nix-darwin wants to manage. Rename them
   as instructed and re-run:

   ```bash
   sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
   sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
   sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
   ```

   Subsequent rebuilds: `sudo darwin-rebuild switch --flake .#<name>` (or `nh`).

6. **Verify secrets**:

   ```bash
   ls ~/.config/sops-nix/secrets/   # decrypted secrets present
   ls -l ~/.ssh/id_ed25519          # SSH key installed by activation script
   ```

### Intel Macs (x86_64-darwin)

nixpkgs unstable (26.11) **dropped x86_64-darwin**; 26.05 is the last branch
that supports it (security fixes until end of 2026, frozen after that). Intel
hosts therefore build from a pinned stable stack instead of the flake's
default unstable inputs — see glados in `flake.nix`:

- `nixpkgs-x86-darwin` → `nixpkgs-26.05-darwin` branch
- `darwin-x86` → `nix-darwin-26.05` branch
- `home-manager-x86` → home-manager `release-26.05` branch

The host entry uses `inputs.darwin-x86.lib.darwinSystem` and overrides
`specialArgs.nixpkgs`; the host file imports
`inputs.home-manager-x86.darwinModules.home-manager`.

Knock-on effects to be aware of (all hit while onboarding glados):

- **Flake inputs computing their systems from unstable** lose Intel darwin
  (`lib.systems.flakeExposed` dropped it). Fix: make the input's nixpkgs
  follow `nixpkgs-x86-darwin` (done for catppuccin and Mosaic).
- **`nix-systems/default`** (used by many flakes as a `systems` input)
  removed x86_64-darwin in late 2025. Fix: pin the old rev
  `da67096a...` that lists all four systems (done inside Mosaic for nixvim).
- **Inputs that simply don't build for Intel** (e.g. devenv): fall back to
  the nixpkgs package in `overlays/default.nix` with
  `inputs.X.packages.${system} or _prev`.
- **home-manager option drift**: shared user config runs against both HM
  master and HM 26.05, so newer options need an `options ? name` guard
  (see `users/michael/common/core/fzf.nix`).

Expect an occasional new shim when unstable renames options faster than
26.05. If the shims pile up, revisit whether the machine should run NixOS
instead.

First-switch quirks specific to Intel:

- Homebrew's prefix is `/usr/local` (not `/opt/homebrew`), which ships
  root-owned dirs. If casks fail with "directories are not writable":
  `sudo chown -R <user> /usr/local/share/man` (or whichever dir brew
  names), then re-run the switch.
- Ad-hoc `nix shell`/`nix run` need an explicit branch ref
  (`github:nixos/nixpkgs/nixpkgs-26.05-darwin#git`) until the first
  switch pins the registry — bare `nixpkgs#` resolves to unstable and
  throws.

---

## NixOS

### 1. Repo-side

1. **Host config** — create `hosts/nixos/<name>/` (copy a similar host:
   `ganon` for bare metal, `rk1/*` for RK1 boards, `wsl/*` for WSL). Set
   `networking.hostName`, hardware/disko config, and `system.stateVersion`.

2. **Flake entry** — add to `nixosConfigurations` in `flake.nix` with the
   right `system`. For remote-deployed machines also add a `deploy.nodes`
   entry.

3. **User host file** — create `users/michael/hosts/<name>.nix` (copy
   `ganon.nix` for a desktop, `zenith-1.nix` for a headless node).

### 2. Secrets — per-host key required

NixOS hosts decrypt secrets with a **host** age key derived from the host's
SSH ed25519 key, so nix-secrets must be re-keyed:

1. Get the host's SSH public key (after install, or generate ahead of time):

   ```bash
   ssh-keyscan <host> 2>/dev/null | grep ed25519 | ssh-to-age
   # or on the host: ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
   ```

2. In **nix-secrets** `.sops.yaml`: add the age public key under the `&hosts`
   anchor list and add it as a recipient in the relevant `creation_rules`.

3. Re-encrypt and push:

   ```bash
   sops updatekeys secrets.yaml
   git commit -am "chore: add <name> host key" && git push
   ```

4. In **dots**, pull the new secrets revision:

   ```bash
   nix flake update nix-secrets
   ```

### 3. Deploy

See the [Remote NixOS Deployment Guide](./Remote-NixOS-Deployment-Guide.md).
Short version: fresh hardware → `nixos-anywhere`; existing NixOS →
`nixos-rebuild switch --flake .#<name> --target-host <host>` or
`deploy .#<name>` for deploy-rs nodes.

---

## Checklist

- [ ] Name chosen, no collision in `flake.nix`
- [ ] `hosts/<name>/` created (or `hosts/nixos/<name>/`)
- [ ] `flake.nix` entry with correct `system`
- [ ] `users/michael/hosts/<name>.nix` created
- [ ] Eval passes: `nix build .#<darwin|nixos>Configurations.<name>.system --dry-run`
- [ ] Secrets: Darwin → age key placed on machine; NixOS → `.sops.yaml` re-keyed + `nix flake update nix-secrets`
- [ ] First build succeeds on the machine
- [ ] Secrets decrypt (`~/.config/sops-nix/secrets/` populated)
- [ ] Committed with conventional commit, e.g. `feat(hosts): add <name> (<machine>)`
