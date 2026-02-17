# Kubernetes configuration with multi-cluster support
#
# Kubeconfigs are stored as separate sops-encrypted files in nix-secrets.
# KUBECONFIG env var merges them at runtime, kubectx switches between contexts.
#
# To add a new cluster:
# 1. Add kubeconfig-<name>.yaml to nix-secrets, encrypt with sops
# 2. Add sops.secrets entry below
# 3. Add path to sessionVariables.KUBECONFIG
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
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  home.packages = with pkgs; [
    kubectx # Fast context switching (kubectx) and namespace switching (kubens)
  ];

  sops = {
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    secrets."kubeconfig-zenith" = {
      sopsFile = "${secretsDirectory}/kubeconfig.yaml";
      path = "${kubeconfigDir}/zenith.yaml";
    };
  };

  home.sessionVariables = {
    KUBECONFIG = "${kubeconfigDir}/zenith.yaml";
    # Add more clusters with colon separator:
    # KUBECONFIG = "${kubeconfigDir}/zenith.yaml:${kubeconfigDir}/work.yaml";
  };
}
