{
  pkgs,
  specialArgs,
  ...
}:
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
  ];
}
