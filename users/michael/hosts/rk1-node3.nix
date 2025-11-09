{
  pkgs,
  specialArgs,
  ...
}:
{
  imports = [
    # Minimal server configuration
    ../common/home.nix
    ../common/core
    ../common/tui
    ../common/shells
  ];
}
