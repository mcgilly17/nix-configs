{ pkgs, ... }:
let
  shellAliases = {
    "zj" = "zellij";
  };
in
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    # Reuse existing sessions instead of creating new ones (prevents PTY exhaustion)
    attachExistingSession = true;
    exitShellOnExit = true;
  };

  xdg.configFile."zellij/config.kdl".source = ./config.kdl;
  xdg.configFile."zellij/layouts/default.kdl".source = ./layouts/default.kdl;

  home.shellAliases = shellAliases;
}
