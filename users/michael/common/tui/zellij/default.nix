{ osConfig, ... }:
let
  shellAliases = {
    "zj" = "zellij";
  };

  hostname = osConfig.networking.hostName;
  hostLayout = ./layouts/${hostname}.kdl;
  layoutFile = if builtins.pathExists hostLayout then hostLayout else ./layouts/default.kdl;
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
  xdg.configFile."zellij/layouts/default.kdl".source = layoutFile;

  home.shellAliases = shellAliases;
}
