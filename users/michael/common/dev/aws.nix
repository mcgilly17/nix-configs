# AWS CLI v2 (aws)
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
  ];
}
