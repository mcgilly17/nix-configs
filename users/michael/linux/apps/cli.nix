# CLI tools for all Linux machines (servers and desktops)
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    _1password # 1Password CLI
  ];
}
