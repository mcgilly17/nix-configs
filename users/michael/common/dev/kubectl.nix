# Kubernetes configuration with multi-cluster support
#
# Kubeconfigs are stored as separate sops-encrypted files in nix-secrets.
# Sops decrypts to read-only files, so an activation script copies them
# to ~/.kube/configs/ with write access (kubectx needs to modify current-context).
# KUBECONFIG env var merges them at runtime, kubectx switches between contexts.
#
# To add a new cluster:
# 1. Add kubeconfig-<name>.yaml to nix-secrets, encrypt with sops
# 2. Add sops.secrets entry below
# 3. Add copy command to activation script
# 4. Add path to sessionVariables.KUBECONFIG
{
  inputs,
  config,
  pkgs,
  ...
}:
let
  secretsDirectory = builtins.toString inputs.nix-secrets;
  inherit (config.home) homeDirectory;
  kubeconfigDir = "${homeDirectory}/.kube/configs";
  sopsKubeconfigDir = "${homeDirectory}/.kube/sops-configs";
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  home = {
    packages = with pkgs; [
      kubectx # Fast context switching (kubectx) and namespace switching (kubens)
    ];

    # Copy sops-decrypted configs to writable location (kubectx needs write access)
    activation.kubeconfig = config.lib.dag.entryAfter [ "sopsNix" ] ''
      mkdir -p "${kubeconfigDir}"
      for f in "${sopsKubeconfigDir}"/*.yaml; do
        [ -f "$f" ] && cp -fL "$f" "${kubeconfigDir}/$(basename "$f")" && chmod 0600 "${kubeconfigDir}/$(basename "$f")"
      done
    '';

    sessionVariables = {
      KUBECONFIG = "${kubeconfigDir}/zenith.yaml";
      # Add more clusters with colon separator:
      # KUBECONFIG = "${kubeconfigDir}/zenith.yaml:${kubeconfigDir}/work.yaml";
    };
  };

  sops = {
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    secrets.kubeconfig-zenith = {
      sopsFile = "${secretsDirectory}/kubeconfig.yaml";
      format = "yaml";
      key = ""; # Empty key means the entire file
      path = "${sopsKubeconfigDir}/zenith.yaml";
    };
  };
}
