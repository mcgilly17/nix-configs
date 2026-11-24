{ ... }:
{
  imports = [
    # import Darwin specific configs
    ../darwin

    # Common home manager configs for any envinroment
    ../common/home.nix
    ../common/core
    ../common/ai-tools
    ../common/tui
    ../common/shells
    ../common/desktop
    ../common/desktop/terminals
    # ../common/desktop/creative
    ../common/desktop/development
    ../common/dev # Dev machine specific (kubeconfig, etc.)
    ../common/dev/muse-tools.nix # Muse internal tools on the tailnet
    ../common/dev/ccvh.nix # CC+VH workbook app on the tailnet
  ];
}
