# User level sops configuration for Darwin
#
# Darwin Bootstrap Flow (Pattern B - derive age key from SSH key):
# 1. Manually place SSH key at ~/.ssh/id_ed25519 (bootstrap secret)
# 2. Home Manager activation derives age key via ssh-to-age
# 3. Age key placed at ~/.config/sops/age/keys.txt
# 4. sops-nix uses age key to decrypt secrets
#
# This mirrors the NixOS pattern where you bootstrap with an SSH key.
# On NixOS: host SSH key → host age key → decrypt user SSH key → user age key
# On Darwin: user SSH key → user age key (simpler, no host-level)
#
# To bootstrap a new Darwin machine:
#   1. Copy ~/.ssh/id_ed25519 to the new machine
#   2. Run darwin-rebuild switch
#   3. The activation script derives the age key automatically
{
  inputs,
  config,
  lib,
  pkgs,
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

  # Derive age key from SSH key during Home Manager activation
  home.activation.deriveAgeKey = lib.hm.dag.entryBefore [ "setupSecrets" ] ''
    if [ -f "${homeDirectory}/.ssh/id_ed25519" ]; then
      $DRY_RUN_CMD mkdir -p "${homeDirectory}/.config/sops/age"
      $DRY_RUN_CMD ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key \
        -i "${homeDirectory}/.ssh/id_ed25519" \
        -o "${homeDirectory}/.config/sops/age/keys.txt"
      $DRY_RUN_CMD chmod 600 "${homeDirectory}/.config/sops/age/keys.txt"
    else
      echo "Warning: SSH key not found at ${homeDirectory}/.ssh/id_ed25519"
      echo "Age key cannot be derived. Place your SSH key first."
    fi
  '';

  sops = {
    age = {
      # Age key derived from SSH key by activation script above
      keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
    };

    defaultSopsFile = "${secretsFile}";
    validateSopsFiles = false;

    secrets = {
      openAIKey = { };
    };
  };
}
