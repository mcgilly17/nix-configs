# Remote NixOS Deployment Guide

This guide covers deploying NixOS configurations to remote machines using your dots repository with SOPS/age encrypted secrets management.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Deploying to Existing NixOS Systems](#deploying-to-existing-nixos-systems)
3. [Key Management Workflow](#key-management-workflow)
4. [Security Considerations](#security-considerations)
5. [Practical Examples](#practical-examples)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Assumptions
- Target machine is already running NixOS
- You have root or sudo access to the target machine
- Your local machine has the complete dots repository
- SOPS/age is configured for secrets management
- SSH access is available to the target machine

### Required Tools
```bash
# Ensure these are available locally
nix-shell -p nixos-rebuild sops age ssh-to-age
```

### Repository Structure
```
dots/
├── flake.nix
├── hosts/
│   ├── hostname/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
└── secrets/
    ├── .sops.yaml
    ├── secrets.yaml
    └── keys/
```

## Deploying to Existing NixOS Systems

### Step 1: Prepare the Target Host

1. **Generate Host SSH Key** (if not exists):
   ```bash
   # On target machine
   sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
   ```

2. **Get Host Public Key**:
   ```bash
   # On target machine
   sudo cat /etc/ssh/ssh_host_ed25519_key.pub
   ```

3. **Add to Known Hosts** (from local machine):
   ```bash
   ssh-keyscan -t ed25519 TARGET_HOST >> ~/.ssh/known_hosts
   ```

### Step 2: Key Management Setup

1. **Convert SSH Key to Age Key**:
   ```bash
   # From the host's public key
   echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..." | ssh-to-age
   ```

2. **Update SOPS Configuration**:
   ```yaml
   # secrets/.sops.yaml
   keys:
     - &admin_key age1234...  # Your admin key
     - &new_host_key age5678...  # New host key

   creation_rules:
     - path_regex: secrets\.yaml$
       key_groups:
       - age:
         - *admin_key
         - *new_host_key
   ```

3. **Re-encrypt Secrets**:
   ```bash
   cd secrets/
   sops updatekeys secrets.yaml
   ```

### Step 3: Deploy Configuration

1. **Basic Deployment**:
   ```bash
   # From dots repository root
   sudo nixos-rebuild switch --flake .#hostname --target-host root@TARGET_HOST
   ```

2. **Deployment with Build Locally**:
   ```bash
   # Build locally, copy to target
   sudo nixos-rebuild switch --flake .#hostname --target-host root@TARGET_HOST --build-host localhost
   ```

3. **Test Before Switch**:
   ```bash
   # Test configuration without switching
   sudo nixos-rebuild test --flake .#hostname --target-host root@TARGET_HOST
   ```

### Step 4: Verify Deployment

1. **Check System Status**:
   ```bash
   ssh root@TARGET_HOST systemctl status
   ```

2. **Verify Secrets Are Accessible**:
   ```bash
   ssh root@TARGET_HOST "sops -d /run/secrets/example-secret"
   ```

## Key Management Workflow

### For New Hosts

1. **Generate Keys on Target**:
   ```bash
   # On target machine
   sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
   sudo ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
   ```

2. **Extract Public Keys**:
   ```bash
   # Get all host keys
   sudo cat /etc/ssh/ssh_host_*.pub
   ```

3. **Convert to Age Format**:
   ```bash
   # Convert ed25519 key (preferred)
   sudo cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
   ```

4. **Update Secrets Repository**:
   ```bash
   cd secrets/
   # Add new key to .sops.yaml
   # Re-encrypt all secrets
   sops updatekeys secrets.yaml
   git add . && git commit -m "Add keys for new-hostname"
   ```

### Timing Considerations

- **Before First Deployment**: Host keys must be generated and added to SOPS configuration
- **Secrets Access**: Host won't be able to decrypt secrets until keys are properly configured
- **Chicken-and-Egg**: Consider using temporary SSH access or console access for initial setup

## Security Considerations

### SSH Access During Deployment

1. **Use SSH Agent Forwarding**:
   ```bash
   ssh -A root@TARGET_HOST
   ```

2. **Temporary SSH Keys**:
   ```bash
   # Add temporary key for deployment
   ssh-copy-id -i ~/.ssh/deployment_key root@TARGET_HOST
   ```

3. **Restrict SSH Access**:
   ```nix
   # In host configuration
   services.openssh = {
     enable = true;
     settings = {
       PermitRootLogin = "prohibit-password";
       PasswordAuthentication = false;
       PubkeyAuthentication = true;
     };
     authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
   };
   ```

### Secrets Handling

1. **Never Commit Unencrypted Secrets**:
   ```bash
   # Always verify encryption
   file secrets/secrets.yaml  # Should show "data"
   ```

2. **Rotate Keys Regularly**:
   ```bash
   # Generate new age key
   age-keygen -o new-key.txt
   # Update SOPS config and re-encrypt
   ```

3. **Backup Strategies**:
   - Keep encrypted secrets in git
   - Store age keys separately and securely
   - Document key recovery procedures

### Network Security

1. **Use VPN When Possible**:
   ```bash
   # Deploy through VPN tunnel
   ssh root@internal-ip
   ```

2. **Firewall Configuration**:
   ```nix
   networking.firewall = {
     enable = true;
     allowedTCPPorts = [ 22 ];  # SSH only initially
   };
   ```

## Practical Examples

### Deploying to RK1 Compute Module

```bash
# 1. Initial setup over USB/serial console
# Generate host keys, get IP address

# 2. From local machine
ssh-keyscan -t ed25519 192.168.1.100 >> ~/.ssh/known_hosts
ssh root@192.168.1.100 "cat /etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age

# 3. Update secrets and deploy
cd secrets/
# Edit .sops.yaml to add new key
sops updatekeys secrets.yaml
cd ..
sudo nixos-rebuild switch --flake .#rk1-01 --target-host root@192.168.1.100
```

### Deploying to Cloud Instance (AWS/GCP)

```bash
# 1. Launch instance with NixOS AMI
# 2. Get instance IP and add to known_hosts
ssh-keyscan -t ed25519 $INSTANCE_IP >> ~/.ssh/known_hosts

# 3. Initial access (using cloud SSH key)
ssh -i ~/.ssh/cloud-key.pem nixos@$INSTANCE_IP

# 4. Generate host keys and get age key
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
sudo cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age

# 5. Update secrets and deploy
# ... update SOPS config ...
sudo nixos-rebuild switch --flake .#cloud-server --target-host root@$INSTANCE_IP
```

### Deploying to Existing Big PC

```bash
# 1. Backup current configuration
ssh root@big-pc "nixos-rebuild switch --rollback"

# 2. Deploy with build locally (faster for large builds)
sudo nixos-rebuild switch --flake .#big-pc \
  --target-host root@big-pc \
  --build-host localhost

# 3. Test network services
ssh root@big-pc "systemctl status networking"
```

### Rollback Procedures

```bash
# 1. Quick rollback to previous generation
ssh root@TARGET_HOST "nixos-rebuild switch --rollback"

# 2. Rollback to specific generation
ssh root@TARGET_HOST "nixos-rebuild switch --switch-generation 42"

# 3. List available generations
ssh root@TARGET_HOST "nix-env -p /nix/var/nix/profiles/system --list-generations"
```

## Troubleshooting

### Common Issues

1. **SSH Connection Refused**:
   ```bash
   # Check if SSH service is running
   ssh root@TARGET_HOST "systemctl status sshd"

   # Try different SSH key
   ssh -i ~/.ssh/specific-key root@TARGET_HOST
   ```

2. **SOPS Decryption Errors**:
   ```bash
   # Verify host key is in SOPS config
   grep -A 10 creation_rules secrets/.sops.yaml

   # Test decryption manually
   ssh root@TARGET_HOST "sops -d /etc/secrets/secrets.yaml"
   ```

3. **Build Failures**:
   ```bash
   # Build locally first to catch errors
   nix build .#nixosConfigurations.hostname.config.system.build.toplevel

   # Check for missing inputs
   nix flake check
   ```

4. **Network Issues After Deployment**:
   ```bash
   # Access via console if available
   # Or use rescue boot mode

   # Rollback network configuration
   nixos-rebuild switch --rollback
   ```

### Debug Commands

```bash
# Check system configuration
ssh root@TARGET_HOST "readlink /run/current-system"

# View systemd logs
ssh root@TARGET_HOST "journalctl -u sops-nix -f"

# Check file permissions
ssh root@TARGET_HOST "ls -la /run/secrets/"

# Verify flake inputs
nix flake metadata .
```

### Recovery Strategies

1. **Lost SSH Access**:
   - Use cloud console/serial access
   - Boot from rescue media
   - Use out-of-band management (IPMI/iDRAC)

2. **Broken Configuration**:
   ```bash
   # Boot previous generation from GRUB
   # Or via rescue commands:
   sudo nixos-rebuild switch --rollback
   ```

3. **Lost Secrets Keys**:
   - Restore from backup
   - Re-generate and re-encrypt all secrets
   - Update all affected hosts

## Best Practices

1. **Always test configurations locally first**
2. **Keep deployment logs for troubleshooting**
3. **Use version control for all configuration changes**
4. **Maintain documentation of deployed systems**
5. **Regular backup of secrets and keys**
6. **Monitor deployed systems for issues**
7. **Plan rollback procedures before deployment**

---

*Last updated: $(date)*