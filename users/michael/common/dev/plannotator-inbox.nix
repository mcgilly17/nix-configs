# Plannotator Inbox kept running as a launchd user agent and published on the
# tailnet, so phones and other machines can reach it before any agent has
# started it. Opt-in per host, so not in ./default.nix; import it from the host
# file. The binary and Claude plugin come from ../tui/plannotator.nix.
#
# Tailscale: `tailscale serve` over HTTPS on a free port from Plannotator's own
# range (it never replaces another mapping), open only to the Tailscale account
# that owns this machine. Agents and MCP stay on 127.0.0.1.
#
# Address: `plannotator inbox status`. Restart:
# `launchctl kickstart -k gui/$UID/org.nix-community.home.plannotator-inbox`.
# Logs: ~/Library/Logs/plannotator-inbox.log.
{ config, ... }:
let
  log = "${config.home.homeDirectory}/Library/Logs/plannotator-inbox.log";
in
{
  launchd.agents.plannotator-inbox = {
    enable = true;
    config = {
      ProgramArguments = [
        "${config.home.profileDirectory}/bin/plannotator"
        "inbox"
        "--no-open"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      # Throttle a crash loop (say, an Inbox an agent already started) to one
      # try a minute.
      ThrottleInterval = 60;
      EnvironmentVariables = {
        PLANNOTATOR_INBOX_TAILSCALE = "1";
        # Its first start adds itself to Codex and the Claude app with a
        # /nix/store path that breaks on the next bump; those entries point at
        # the profile's plannotator instead, so don't let it rewrite them.
        PLANNOTATOR_INBOX_CONNECT = "0";
        # /usr/local/bin holds the Tailscale CLI.
        PATH = "${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      StandardOutPath = log;
      StandardErrorPath = log;
    };
  };
}
