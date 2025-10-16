# System-level SOPS configuration for NixOS hosts
{ config, lib, inputs, ... }:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  # System-level SOPS configuration
  sops = {
    defaultSopsFile = inputs.nix-secrets + "/secrets.yaml";
    validateSopsFiles = false;

    age = {
      # Use SSH host key for system-level decryption
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    # Extract user age key for Home Manager
    # This allows the system to decrypt the user's personal age key
    # and place it where Home Manager can access it
    secrets."user-age-keys/michael-${config.networking.hostName}" = {
      path = "/run/secrets/user-age-key";
      mode = "0400";
      owner = config.users.users.michael.name;
    };
  };

  # System activation script to place user age key for Home Manager
  system.activationScripts.userAgeKey = ''
    # Create sops directory for user
    mkdir -p /home/michael/.config/sops/age

    # Copy the decrypted user age key to where Home Manager expects it
    if [ -f /run/secrets/user-age-key ]; then
      cp /run/secrets/user-age-key /home/michael/.config/sops/age/keys.txt
      chown -R michael:users /home/michael/.config/sops
      chmod 600 /home/michael/.config/sops/age/keys.txt
    fi
  '';
}