{ ... }:
{
  imports = [
    # Common home manager configs
    ../common/home.nix
    ../common/core
    ../common/ai-tools
    ../common/tui
    ../common/shells
    ../common/dev # Dev machine specific (kubeconfig, etc.)
  ];
}
