{ pkgs, ... }:
{
  # Install pfetch package
  home.packages = with pkgs; [
    pfetch
    neofetch
  ];
  # Set session variables for pfetch configuration
  home.sessionVariables.PF_INFO = "ascii title os kernel uptime shell term desktop scheme palette"; # "ascii title os host kernel uptime pkgs memory de shell editor palette";
}
