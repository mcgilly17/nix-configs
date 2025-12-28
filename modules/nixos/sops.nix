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
    # This will be converted to an age key by the activation script
    secrets."private_keys/michael" = {
      mode = "0400";
      owner = config.users.users.michael.name;
    };
  };

  # Derive user age key from SSH key after secrets are decrypted
  system.activationScripts.userAgeKey = {
    # Run after sops-nix has decrypted secrets
    deps = [ "setupSecrets" ];
    text = ''
      # Create sops age directory for user
      mkdir -p /home/michael/.config/sops/age
      chown michael:users /home/michael/.config/sops
      chown michael:users /home/michael/.config/sops/age

      # Derive age key from SSH key using ssh-to-age
      if [ -f /run/secrets/private_keys/michael ]; then
        ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key \
          -i /run/secrets/private_keys/michael \
          -o /home/michael/.config/sops/age/keys.txt
        chown michael:users /home/michael/.config/sops/age/keys.txt
        chmod 600 /home/michael/.config/sops/age/keys.txt
        echo "User age key derived from SSH key"
      else
        echo "Warning: SSH key not found at /run/secrets/private_keys/michael"
        echo "User age key not derived - Home Manager secrets may fail"
      fi
    '';
  };
}
