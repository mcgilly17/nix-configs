# Zenith-1 - K3s Control Plane
# Includes TUI tools for cluster debugging
_: {
  imports = [
    ../common/home.nix
    ../common/core
    ../common/tui
    ../common/shells
  ];
}
