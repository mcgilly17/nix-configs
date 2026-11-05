# Development tools - system-level
{ pkgs, specialArgs, ... }:
{
  imports = specialArgs.myLibs.scanPaths ./.;

  environment.systemPackages = with pkgs; [
    docker-compose
    t3code # T3 Code, open-source GUI for coding agents
  ];
}
