{
  pkgs,
  specialArgs,
  ...
}:
{
  imports = [
    # Common home manager configs
    ../common/home.nix
    ../common/core
    ../common/ai-tools
    ../common/tui
    ../common/shells
  ];
}
