_: {
  imports = [
    # Minimal server configuration
    ../common/home.nix
    ../common/core
    ../common/tui
    ../common/shells

    # Linux CLI tools (1password, etc.)
    ../linux/apps/cli.nix
  ];
}
