# Development tools - system-level
{ pkgs, specialArgs, ... }:
{
  imports = specialArgs.myLibs.scanPaths ./.;

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
