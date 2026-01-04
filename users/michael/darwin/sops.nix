# User level sops configuration for Darwin
#
# Darwin Bootstrap Flow (Pattern A - age key is bootstrap):
# 1. Manually place age key at ~/.config/sops/age/keys.txt (bootstrap secret)
# 2. sops-nix uses age key to decrypt secrets (including SSH key)
# 3. Activation script copies SSH key to ~/.ssh/id_ed25519
#
# This mirrors the NixOS pattern where the host key bootstraps user secrets.
# On NixOS: host SSH key → host age key → decrypt user SSH key
# On Darwin: age key (manual) → decrypt user SSH key
#
# To bootstrap a new Darwin machine:
#   1. Copy age key to ~/.config/sops/age/keys.txt
#      (derive from SSH key: ssh-to-age -private-key -i ~/.ssh/id_ed25519)
#   2. Run darwin-rebuild switch
#   3. SSH key is automatically extracted from sops and placed at ~/.ssh/
{
  inputs,
  config,
  lib,
  ...
}:
let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  secretsFile = "${secretsDirectory}/secrets.yaml";
  inherit (config.home) homeDirectory;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age = {
      # Age key must be manually placed (bootstrap secret)
      keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
    };

    defaultSopsFile = "${secretsFile}";
    validateSopsFiles = false;

    secrets = {
      openAIKey = { };
      # SSH private key - will be copied to ~/.ssh/ by activation script
      "private_keys/michael" = { };
    };
  };

  # Copy SSH key from sops secret to ~/.ssh/ after secrets are decrypted
  home.activation.setupSshKey = lib.hm.dag.entryAfter [ "setupSecrets" ] ''
    SECRET_PATH="${homeDirectory}/.config/sops-nix/secrets/private_keys/michael"
    if [ -f "$SECRET_PATH" ]; then
      $DRY_RUN_CMD mkdir -p "${homeDirectory}/.ssh"
      $DRY_RUN_CMD chmod 700 "${homeDirectory}/.ssh"
      $DRY_RUN_CMD cp "$SECRET_PATH" "${homeDirectory}/.ssh/id_ed25519"
      $DRY_RUN_CMD chmod 600 "${homeDirectory}/.ssh/id_ed25519"
      echo "SSH key installed to ~/.ssh/id_ed25519"
    else
      echo "Warning: SSH key secret not found at $SECRET_PATH"
      echo "Ensure sops secrets are properly configured"
    fi
  '';
}
