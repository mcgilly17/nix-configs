# Better Nix tooling with nh (home-manager level for Darwin)
{ config, ... }:
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 20d --keep 20";
    # NOTE: builtins.getEnv returns "" in pure flake eval - use the
    # home-manager home directory instead
    flake = "${config.home.homeDirectory}/Projects/dots";
  };
}
