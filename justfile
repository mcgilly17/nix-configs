# Wake-on-LAN configuration
wol_relay := "michael@sephiroth"

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

# Wake a host via WoL relay through sephiroth, then SSH in
[group("remote")]
wake HOST:
  #!/usr/bin/env bash
  set -euo pipefail
  declare -A macs=(
    [bowser]="82:24:ce:a6:cc:90"
    [ocelot]="b4:2e:99:34:c9:a7"
  )
  mac="${macs[{{ HOST }}]:-}"
  if [[ -z "$mac" ]]; then
    echo "Unknown host '{{ HOST }}'. Valid targets: ${!macs[*]}"
    exit 1
  fi
  echo "Sending WoL packet for {{ HOST }} ($mac) via {{ wol_relay }}..."
  ssh {{ wol_relay }} "wakeonlan $mac"
  echo "Waiting for {{ HOST }} to come online..."
  ssh {{ wol_relay }} "until ping -c1 -W2 {{ HOST }}.local >/dev/null 2>&1; do sleep 2; done"
  echo "{{ HOST }} is up!"
  ssh michael@{{ HOST }}

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
