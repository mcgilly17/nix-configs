{
  pkgs,
  lib,
  osConfig ? { },
  ...
}:
let
  # Check if we're on WSL - use Windows 1Password integration instead
  isWSL = osConfig.hostSpec.isWSL or false;
in
{
  # https://developer.1password.com/docs/cli/shell-plugins/nix/
  programs._1password-shell-plugins = lib.mkIf (!isWSL) {
    # enable 1Password shell plugins for bash, zsh, and fish shell
    enable = true;
    # the specified packages as well as 1Password CLI will be
    # automatically installed and configured to use shell plugins
    plugins = with pkgs; [
      gh
      cachix
    ];
  };
}
