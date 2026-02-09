{ osConfig, ... }:
let
  shellAliases = {
    "zj" = "zellij";
  };

  hostname = osConfig.networking.hostName;
  hostLayout = ./layouts/${hostname}.kdl;
  layoutFile = if builtins.pathExists hostLayout then hostLayout else ./layouts/default.kdl;

  # Servers: persist sessions for SSH reconnection
  # Non-servers: fresh sessions, no accumulation
  isServer = osConfig.hostSpec.isServer or false;

  # Swap on_force_close behavior based on host type
  configContent =
    builtins.replaceStrings
      [ ''on_force_close "quit"'' ]
      [ (if isServer then ''on_force_close "detach"'' else ''on_force_close "quit"'') ]
      (builtins.readFile ./config.kdl);
in
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    # Servers: reconnect to existing session (for SSH reconnection)
    # Non-servers: each terminal gets its own session
    attachExistingSession = isServer;
    exitShellOnExit = true;
  };

  xdg.configFile."zellij/config.kdl".text = configContent;
  xdg.configFile."zellij/layouts/default.kdl".source = layoutFile;

  home.shellAliases = shellAliases;
}
