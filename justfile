# MAC addresses for Wake-on-LAN
bowser_mac := "82:24:ce:a6:cc:90"
wol_relay  := "michael@sephiroth"

# default recipe to display help information
default:
  @just --list

# ========== Building ==========

# Rebuild the current host (auto-detects darwin vs nixos)
[group("build")]
rebuild:
  #!/usr/bin/env bash
  if [[ "$(uname)" == "Darwin" ]]; then
    sudo darwin-rebuild switch --flake .#bowser
  else
    sudo nixos-rebuild switch --flake .#"$(hostname)"
  fi

# Rebuild with full trace output for debugging
[group("build")]
rebuild-trace:
  #!/usr/bin/env bash
  if [[ "$(uname)" == "Darwin" ]]; then
    sudo darwin-rebuild switch --flake .#bowser --show-trace
  else
    sudo nixos-rebuild switch --flake .#"$(hostname)" --show-trace
  fi

# Build without switching (dry run)
[group("build")]
build:
  #!/usr/bin/env bash
  if [[ "$(uname)" == "Darwin" ]]; then
    darwin-rebuild build --flake .#bowser
  else
    nixos-rebuild build --flake .#"$(hostname)"
  fi

# Deploy to a remote NixOS host via deploy-rs
[group("build")]
deploy HOST:
  deploy .#{{ HOST }}

# Deploy to all remote hosts
[group("build")]
deploy-all:
  deploy .

# ========== Update ==========

# Update all flake inputs
[group("update")]
update:
  nix flake update

# Update a specific flake input
[group("update")]
update-input INPUT:
  nix flake update {{ INPUT }}

# Update and then rebuild
[group("update")]
upgrade: update rebuild

# ========== Checks ==========

# Run flake check
[group("checks")]
check:
  nix flake check --no-build

# Format all nix files
[group("checks")]
fmt:
  nix fmt

# Show diff of all changes (excluding flake.lock noise)
[group("checks")]
diff:
  git diff ':!flake.lock'

# ========== Remote ==========

# Wake bowser via WoL relay through zenith-1, then SSH in
[group("remote")]
wake-bowser:
  #!/usr/bin/env bash
  echo "Sending WoL packet via {{ wol_relay }}..."
  ssh {{ wol_relay }} "wakeonlan {{ bowser_mac }}"
  echo "Waiting for bowser to come online..."
  until ssh -o ConnectTimeout=2 -o BatchMode=yes michael@bowser true 2>/dev/null; do
    sleep 2
  done
  echo "bowser is up!"
  ssh michael@bowser

# SSH into a host
[group("remote")]
ssh HOST:
  ssh michael@{{ HOST }}

# ========== Secrets ==========

# Generate a new age key
[group("secrets")]
age-key:
  nix-shell -p age --run "age-keygen"

# ========== Cleanup ==========

# Garbage collect old nix store paths
[group("cleanup")]
gc:
  nix-collect-garbage -d

# Garbage collect and optimize store
[group("cleanup")]
gc-full:
  nix-collect-garbage -d && nix-store --optimise
