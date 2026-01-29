# System-level SOPS configuration for NixOS hosts
#
# Pattern B: Derive user age key from SSH key
#
# Decryption chain:
# 1. Host SSH key (/etc/ssh/ssh_host_ed25519_key) → sops-nix derives host age key
# 2. Host age key decrypts system secrets including private_keys/michael
# 3. Activation script runs ssh-to-age on michael's SSH key → user age key
# 4. User age key placed at ~/.config/sops/age/keys.txt for Home Manager
#
# This means &michael in .sops.yaml must be the age public key derived from
# michael's SSH public key (via: cat id_ed25519.pub | ssh-to-age)
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  # ssh-to-age needed for deriving user age key from SSH key
  environment.systemPackages = [ pkgs.ssh-to-age ];

  # System-level SOPS configuration
  sops = {
    defaultSopsFile = inputs.nix-secrets + "/secrets.yaml";
    validateSopsFiles = false;

    age = {
      # Host age key derived from SSH host key (standard sops-nix pattern)
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    # Extract michael's SSH private key from secrets
    # Only on non-cluster nodes (dev servers) - cluster nodes don't need personal SSH key
    secrets."private_keys/michael" = lib.mkIf (!config.hostSpec.isClusterNode) {
      mode = "0400";
      owner = config.users.users.michael.name;
    };
  };

  # Set up user SSH key and derive age key after secrets are decrypted
  # Only on non-cluster nodes - cluster nodes don't need personal SSH key
  system.activationScripts.userAgeKey = lib.mkIf (!config.hostSpec.isClusterNode) {
    # Run after sops-nix has decrypted secrets
    deps = [ "setupSecrets" ];
    text = ''
      if [ -f /run/secrets/private_keys/michael ]; then
        # Ensure home directory exists with correct ownership
        mkdir -p /home/michael
        chown michael:michael /home/michael

        # Copy SSH key to ~/.ssh/ (canonical location)
        mkdir -p /home/michael/.ssh
        cp /run/secrets/private_keys/michael /home/michael/.ssh/id_ed25519
        chown michael:michael /home/michael/.ssh
        chown michael:michael /home/michael/.ssh/id_ed25519
        chmod 700 /home/michael/.ssh
        chmod 600 /home/michael/.ssh/id_ed25519
        echo "SSH key installed to ~/.ssh/id_ed25519"

        # Generate public key and add to authorized_keys for SSH access
        ${pkgs.openssh}/bin/ssh-keygen -y -f /home/michael/.ssh/id_ed25519 > /home/michael/.ssh/id_ed25519.pub
        cp /home/michael/.ssh/id_ed25519.pub /home/michael/.ssh/authorized_keys
        chown michael:michael /home/michael/.ssh/id_ed25519.pub /home/michael/.ssh/authorized_keys
        chmod 644 /home/michael/.ssh/id_ed25519.pub
        chmod 600 /home/michael/.ssh/authorized_keys
        echo "Public key added to authorized_keys"

        # Derive age key from SSH key for Home Manager sops
        mkdir -p /home/michael/.config/sops/age
        chown michael:michael /home/michael/.config
        chown michael:michael /home/michael/.config/sops
        chown michael:michael /home/michael/.config/sops/age
        ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key \
          -i /home/michael/.ssh/id_ed25519 \
          -o /home/michael/.config/sops/age/keys.txt
        chown michael:michael /home/michael/.config/sops/age/keys.txt
        chmod 600 /home/michael/.config/sops/age/keys.txt
        echo "User age key derived from SSH key"
      else
        echo "Warning: SSH key not found at /run/secrets/private_keys/michael"
        echo "SSH key and age key not set up - git and Home Manager secrets may fail"
      fi
    '';
  };
}
