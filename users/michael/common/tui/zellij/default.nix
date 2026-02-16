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

  # Custom shell integration to handle multi-session SSH gracefully
  # Home-manager's default uses `zellij attach -c` which shows a picker
  # when multiple sessions exist, causing SSH to exit prematurely
  zellijAutoStart = ''
    if [[ -z "$ZELLIJ" ]]; then
      ${
        if isServer then
          ''
            # Servers: always attach to/create session named "main"
            # Avoids session picker on SSH reconnection with multiple sessions
            zellij attach -c main
          ''
        else
          ''
            # Non-servers: fresh session each terminal
            zellij
          ''
      }
      if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
        exit
      fi
    fi
  '';
in
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = false; # Use custom integration below
    exitShellOnExit = true;
  };

  programs.zsh.initExtra = zellijAutoStart;

  xdg.configFile."zellij/config.kdl".text = configContent;
  xdg.configFile."zellij/layouts/default.kdl".source = layoutFile;

  home.shellAliases = shellAliases;
}
