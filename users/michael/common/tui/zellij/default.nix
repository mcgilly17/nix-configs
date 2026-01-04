_:
let
  shellAliases = {
    "zj" = "zellij";
  };
in
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    # Each terminal gets its own session
    attachExistingSession = false;
    # Close shell when zellij exits
    exitShellOnExit = true;
  };

  xdg.configFile."zellij/config.kdl".source = ./config.kdl;
  xdg.configFile."zellij/layouts/default.kdl".source = ./layouts/default.kdl;

  home.shellAliases = shellAliases;
}
