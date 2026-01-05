{ pkgs, ... }:
{
  # https://developer.1password.com/docs/cli/shell-plugins/nix/
  programs._1password-shell-plugins = {
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
