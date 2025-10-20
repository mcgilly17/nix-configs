# Nix Configuration Architecture Overview

A comprehensive guide to understanding McGilly17's sophisticated Nix configuration system, covering repository structure, secrets management, host configuration patterns, and key technologies.

## Table of Contents

- [System Architecture](#system-architecture)
- [Repository Structure](#repository-structure)
- [Secrets Management](#secrets-management)
- [Host Configuration Patterns](#host-configuration-patterns)
- [Key Technologies](#key-technologies)
- [Configuration Flow](#configuration-flow)
- [Design Decisions](#design-decisions)
- [Deployment Strategies](#deployment-strategies)
- [Security Model](#security-model)

## System Architecture

This Nix configuration system is designed as a modular, multi-host, multi-user setup supporting both Darwin (macOS) and NixOS (Linux) environments. The architecture separates concerns between system-level configurations, user-level configurations, and secrets management.

### High-Level Design Principles

1. **Modularity**: Configurations are broken into reusable modules that can be composed for different hosts and users
2. **Separation of Concerns**: System configs, user configs, and secrets are managed independently
3. **Platform Abstraction**: Common configurations are shared between Darwin and NixOS where possible
4. **Security by Design**: Secrets are encrypted and access is controlled through host-specific keys
5. **Reproducibility**: All configurations are declarative and version-controlled

## Repository Structure

The system consists of two primary repositories working in tandem:

### Main Configuration Repository (`~/Projects/dots`)

```
dots/
├── flake.nix              # Main flake entry point, inputs, and outputs
├── flake.lock             # Pinned dependency versions
├── hosts/                 # Host-specific configurations
│   ├── bowser/            # MacBook Pro 16" M1 Max
│   └── sephiroth/         # MacBook Air M1 2021
├── modules/               # Shared system-level modules
│   ├── common/            # OS-agnostic configurations
│   ├── darwin/            # macOS-specific modules
│   │   ├── apps/          # Application installations
│   │   └── wm/            # Window management (Yabai/skhd)
│   └── nixos/             # Linux-specific modules
├── users/                 # User-specific configurations
│   └── michael/           # User-specific configs
│       ├── common/        # Cross-platform user configs
│       ├── darwin/        # macOS-specific user configs
│       ├── hosts/         # Host-specific user configs
│       └── linux/         # Linux-specific user configs
├── resources/             # Shared resources and utilities
│   ├── lib/               # Custom Nix functions
│   └── vars.nix           # Global variables
└── overlays/              # Package modifications
```

### Secrets Repository (`~/Projects/secrets`)

```
secrets/
├── flake.nix              # Exports user data (name, email)
├── .sops.yaml             # SOPS configuration for encryption
└── secrets.yaml           # Encrypted secrets file
```

### Repository Integration

The two repositories work together through Nix flakes:

```nix
# In dots/flake.nix
inputs = {
  nix-secrets = {
    url = "git+ssh://git@github.com/mcgilly17/nix-secrets.git?ref=main&shallow=1";
    inputs = {};
  };
  # ... other inputs
};
```

This allows the main configuration to access:
- User metadata (name, email) from `inputs.nix-secrets`
- Encrypted secrets through SOPS integration
- Host-specific decryption keys

## Secrets Management

The secrets management system uses SOPS (Secrets OPerationS) with age encryption, providing a robust and secure approach to handling sensitive data.

### Encryption Architecture

**Age Encryption Keys:**
```yaml
# .sops.yaml
keys:
  - &users:
    - &michael age1ucvns7uw3lh6x6lpe2uf0mrzflpfteanvtnhdf964avqhveswgvqu43zxj
  - &hosts:
    - &sephiroth age1e23vnw3ytplh2l59unqsm573g2dmrq83exyceaa7nz5nnl67dfyscz6sfa
    - &bowser age1phef0a4aeqdzatjevln3asptphkkqnx644t9raryehqa59ts036sqe6xy7
```

### Security Model

**User vs Host Keys:**
- **User Keys**: Personal keys for manual secret access during development/maintenance
- **Host Keys**: Derived from SSH host keys (`/etc/ssh/ssh_host_ed25519_key`), enabling automatic decryption

**Key Derivation Process:**
1. Each host generates an SSH host key during initial setup
2. SOPS-nix derives an age key from the SSH host key
3. This age key is used to decrypt secrets specific to that host
4. No manual key distribution required for new hosts

### SOPS Integration

```nix
# modules/darwin/sops.nix
{
  sops = {
    defaultSopsFile = "${secretsDirectory}/secrets.yaml";
    validateSopsFiles = false;
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    secrets = {
      michaelEmail = {};
    };
  };
}
```

### Why Public Secrets Repository is Secure

Making the secrets repository public is safe because:

1. **Everything is Encrypted**: All sensitive data is encrypted with age before being committed
2. **Key-based Access**: Only hosts with the corresponding private keys can decrypt secrets
3. **No Key Leakage**: Private keys never leave their respective hosts
4. **SSH Chicken-and-Egg Solution**: Public access eliminates the need for SSH access to clone secrets during initial host provisioning

**Example Encrypted Secret:**
```yaml
michaelEmail: ENC[AES256_GCM,data:JVh/HpKIRIZuwVCacH4HSsWpjlAOPw==,iv:7zrnlfOpWhTXknWPO0E1bilCRzfMq4AvN0mXvsW6CeM=,tag:N7KTV4AJ7TKV9OgDXytJEw==,type:str]
```

## Host Configuration Patterns

The system supports multiple host types with shared and specialized configurations.

### Darwin (macOS) Configuration

**Structure:**
```nix
# hosts/bowser/default.nix
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ] ++ (map myLibs.relativeToRoot [
    "modules/darwin"                    # Darwin system modules
    "modules/darwin/apps/desktop.nix"   # Desktop applications
    "modules/darwin/apps/development.nix" # Development tools
    "users/michael"                     # User configuration
  ]);
}
```

**Key Features:**
- **nix-darwin**: System-level macOS configuration
- **Homebrew Integration**: Declarative Homebrew management for apps not in nixpkgs
- **Window Management**: Yabai and skhd for tiling window management
- **App Management**: Mix of Nix packages, Homebrew, and Mac App Store

### NixOS Configuration

**Structure** (prepared for future use):
```nix
# modules/nixos/default.nix
{
  imports = [
    # Hardware-specific modules
    # Desktop environment modules
    # System services
  ];
}
```

**Planned Features:**
- **Hardware Detection**: Automatic hardware configuration
- **Desktop Environment**: Standardized desktop setup
- **Service Management**: systemd service configurations

### Home Manager Integration

**User Configuration Flow:**
```nix
# users/michael/default.nix
{
  users.users."${michael.username}" = {
    home = "/Users/${michael.username}";
    description = "${michael.userFullName}";
  };

  # Host-specific user configuration
  home-manager.users.${michael.username} = import (
    specialArgs.myLibs.relativeToRoot
    "users/${michael.username}/hosts/${config.networking.hostName}.nix"
  );
}
```

**Host-Specific User Config:**
```nix
# users/michael/hosts/bowser.nix
{
  imports = [
    ../darwin          # Darwin-specific user configs
    ../common/home.nix  # Base home-manager config
    ../common/core      # Core CLI tools
    ../common/tui       # Terminal applications
    ../common/desktop   # GUI applications
    ../common/shells    # Shell configurations
  ];
}
```

### Shared vs Specialized Modules

**Common Modules** (`modules/common/`):
- Core Nix configuration
- Universal system settings
- Cross-platform utilities

**Platform-Specific Modules:**
- `modules/darwin/`: macOS system configuration, Homebrew, window management
- `modules/nixos/`: Linux system configuration, systemd services, hardware

**User Configurations:**
- `users/michael/common/`: Cross-platform user tools and configurations
- `users/michael/darwin/`: macOS-specific user settings
- `users/michael/linux/`: Linux-specific user settings

## Key Technologies

### Nix Flakes

**Purpose**: Reproducible, composable configuration management
**Benefits**:
- Pinned dependencies via `flake.lock`
- Clear input/output specification
- Improved reproducibility and caching

**Structure:**
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager/master";
    sops-nix.url = "github:mic92/sops-nix";
    # ... other inputs
  };

  outputs = { self, nixpkgs, darwin, home-manager, ... } @ inputs: {
    darwinConfigurations = {
      bowser = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./hosts/bowser ];
      };
    };
  };
}
```

### nix-darwin

**Purpose**: System-level macOS configuration management
**Capabilities**:
- System preferences and settings
- Service management (via launchd)
- User account management
- Homebrew integration

### Home Manager

**Purpose**: User-level configuration management
**Manages**:
- Dotfiles and configurations
- User-specific packages
- Shell environments
- Application settings

### SOPS-nix

**Purpose**: Secure secrets management in Nix
**Features**:
- Integration with existing Nix configurations
- Automatic secret decryption at runtime
- Multiple encryption backend support (age, GPG, cloud KMS)
- File and string secret types

### Age Encryption

**Purpose**: Modern file encryption
**Advantages**:
- Simple key management
- SSH key integration
- Cross-platform compatibility
- Small, focused tool

## Configuration Flow

### Build Process

1. **Flake Evaluation**: Nix evaluates the flake and resolves all inputs
2. **Host Selection**: Specific host configuration is selected (e.g., `bowser`)
3. **Module Composition**: Host imports system and user modules
4. **Secret Decryption**: SOPS-nix decrypts secrets using host keys
5. **System Generation**: Complete system configuration is built
6. **Activation**: Configuration is applied to the system

### Variable and Library System

**Global Variables** (`resources/vars.nix`):
```nix
{
  users = {
    michael = {
      username = "michael";
      handle = "McGilly17";
      gitEmail = "4136843+mcgilly17@users.noreply.github.com";
      userFullName = inputs.nix-secrets.userFullName;  # From secrets repo
      email = inputs.nix-secrets.email.user;          # From secrets repo
    };
  };
}
```

**Custom Libraries** (`resources/libs.nix`):
```nix
{
  # Convert relative paths to absolute paths from repo root
  relativeToRoot = path: /. + "/path/to/repo" + "/${path}";

  # Scan directory for Nix files
  scanPaths = path:
    builtins.filter
      (name: builtins.pathExists (path + "/${name}"))
      (builtins.attrNames (builtins.readDir path));
}
```

## Design Decisions

### Modular Architecture

**Decision**: Separate configurations into composable modules
**Rationale**:
- Enables code reuse across hosts
- Simplifies maintenance and updates
- Allows gradual migration and testing
- Supports different user/host combinations

### Dual Repository Approach

**Decision**: Separate public configs from private secrets
**Rationale**:
- Enables public sharing of configuration patterns
- Simplifies secrets management and key distribution
- Allows selective access to different parts of the system
- Solves SSH chicken-and-egg problem for new hosts

### Home Manager Integration

**Decision**: Use Home Manager for user-specific configurations
**Rationale**:
- Provides declarative user environment management
- Integrates well with system-level Nix configurations
- Supports both Darwin and NixOS consistently
- Enables user-specific package and configuration management

### SOPS + Age for Secrets

**Decision**: Use SOPS with age encryption instead of alternatives
**Rationale**:
- Age provides modern, simple encryption
- SOPS offers good Nix integration
- SSH key integration eliminates manual key management
- Supports multiple recipients for shared access

## Deployment Strategies

### Current Hosts

**Existing Deployments:**
- `sephiroth`: MacBook Air M1 2021
- `bowser`: MacBook Pro 16" M1 Max

**Deployment Command:**
```bash
darwin-rebuild switch --flake .#bowser
```

### Planned Expansions

**Cloud Deployments** (AWS/GCP):
```nix
# Future: hosts/aws-web-01/default.nix
{
  imports = [
    ../../modules/nixos
    ../../modules/common
  ];

  # Cloud-specific configurations
  networking.hostName = "aws-web-01";
  services.nginx.enable = true;
}
```

**RK1 Compute Modules:**
```nix
# Future: hosts/rk1-cluster-01/default.nix
{
  imports = [
    inputs.nix-hardware.nixosModules.rockchip-rk3588
    ../../modules/nixos
  ];

  # ARM64 specific configurations
  networking.hostName = "rk1-cluster-01";
}
```

### Remote Deployment Process

1. **Initial Provisioning**:
   - Generate SSH host keys
   - Add host public key to `.sops.yaml`
   - Re-encrypt secrets for new host
   - Deploy via nixos-rebuild or darwin-rebuild

2. **Ongoing Management**:
   - Push configuration changes to git
   - Pull and rebuild on target hosts
   - Automated deployment via CI/CD (planned)

## Security Model

### Access Control

**Host-Based Access**:
- Each host can only decrypt its own secrets
- Host keys derived from SSH host keys
- No shared secrets between hosts

**User-Based Access**:
- User keys for manual secret management
- Development-time access to encrypted files
- Emergency access scenarios

### Key Rotation

**Host Key Rotation**:
1. Generate new SSH host key
2. Derive new age key
3. Update `.sops.yaml` with new key
4. Re-encrypt all secrets
5. Deploy updated configuration

**User Key Rotation**:
1. Generate new age key
2. Update `.sops.yaml`
3. Re-encrypt secrets
4. Update personal key storage

### Threat Model

**Protected Against**:
- Repository compromise (secrets remain encrypted)
- Host compromise (only that host's secrets exposed)
- Network interception (encrypted in transit)
- Unauthorized access (key-based authentication)

**Considerations**:
- Host key compromise exposes that host's secrets
- User key compromise exposes ability to decrypt secrets
- Physical access to unlocked hosts may expose decrypted secrets

### Best Practices

1. **Regular Key Rotation**: Rotate keys periodically
2. **Minimal Secrets**: Only store truly sensitive data in secrets
3. **Host Isolation**: Each host has unique keys
4. **Backup Strategy**: Secure backup of master keys
5. **Audit Trail**: Track secret access and modifications

---

This architecture provides a robust, scalable foundation for managing complex multi-host, multi-user Nix configurations while maintaining security and simplicity. The modular design enables easy expansion to new platforms and deployment scenarios while keeping configurations maintainable and secure.