{pkgs, ...}: {
  imports = [
  ];

  home.packages = with pkgs; [
    # Just install these with no config
    slack
    claude-code
  ];
}
