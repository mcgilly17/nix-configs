# Worktrunk - git worktree manager for parallel agent workflows
#
# Linux only: the macs install it as the `wt` brew from the upstream tap
# (modules/darwin/apps/development.nix). nixpkgs lags several dozen
# releases behind, and homebrew-core has no x86_64-darwin bottle, so the
# tap's prebuilt binary is the only current-and-not-compiled option there.
{ lib, pkgs, ... }:
{
  home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.worktrunk ];

  # Shell hook so `wt` can change the current directory. Equivalent to
  # `wt config shell install zsh`, which appends this same line to .zshrc.
  programs.zsh.initContent = ''
    eval "$(wt config shell init zsh)"
  '';
}
