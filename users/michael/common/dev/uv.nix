# Python package/project manager
# Sourced from nixpkgs rather than Homebrew: homebrew-core no longer builds
# x86_64-darwin bottles, so `brew install uv` compiles rust from source on
# glados. nixpkgs still ships cached x86_64-darwin builds.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    uv
  ];
}
