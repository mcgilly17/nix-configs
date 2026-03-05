# Zenith-3 - K3s Agent
# Includes TUI tools for cluster debugging
_: {
  imports = [
    ../common/home.nix
    ../common/core
    ../common/tui-server
    ../common/shells
  ];
}
