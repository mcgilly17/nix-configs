# Muse internal tools (~/Projects/muse/internal-tools), kept running as a launchd
# user agent: it needs the gh login and the desktop session. Opt-in per host, so
# not in ./default.nix; import it from the host file.
#
# Where it is served from and who may reach it live in the checkout's gitignored
# .env (see its .env.example), not here.
#
# Upgrade: pull the checkout, then
# `launchctl kickstart -k gui/$UID/org.nix-community.home.muse-tools`, which
# reinstalls dependencies and restarts it. Logs: ~/Library/Logs/muse-tools.log.
{ config, ... }:
let
  home = config.home.homeDirectory;
  log = "${home}/Library/Logs/muse-tools.log";
in
{
  launchd.agents.muse-tools = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "npm install --no-audit --no-fund && exec npm start"
      ];
      WorkingDirectory = "${home}/Projects/muse/internal-tools";
      RunAtLoad = true;
      KeepAlive = true;
      # Throttle a crash loop (say, the port already taken) to one try a minute.
      ThrottleInterval = 60;
      EnvironmentVariables.PATH = "${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      StandardOutPath = log;
      StandardErrorPath = log;
    };
  };
}
