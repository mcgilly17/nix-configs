# Better Nix tooling with nh (home-manager level for Darwin)
{ pkgs, ... }:
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 20d --keep 20";
    flake = "${builtins.getEnv "HOME"}/Projects/dots";
  };
}
