# CC+VH workbook app (~/Projects/ccvh), kept running as a launchd user agent
# like muse-tools: it needs the desktop session, and its Postgres is a user
# agent too (hosts/glados/ccvh.nix). Opt-in per host, so not in ./default.nix;
# import it from the host file.
#
# Its port and database live in the checkout's gitignored .env (see its
# .env.example), not here. It listens on 127.0.0.1 only; the tailnet reaches it
# through a one-time `tailscale serve` (see the checkout's deploy/README.md).
# Never Funnel.
#
# Upgrade: pull the checkout, then
# `launchctl kickstart -k gui/$UID/org.nix-community.home.ccvh`, which
# reinstalls dependencies, rebuilds and restarts it. Logs: ~/Library/Logs/ccvh.log.
{ config, osConfig, ... }:
let
  home = config.home.homeDirectory;
  log = "${home}/Library/Logs/ccvh.log";
  postgresql = osConfig.services.postgresql.package;
in
{
  launchd.agents.ccvh = {
    enable = true;
    config = {
      # Waits for Postgres and creates the database on first run (nix-darwin
      # has no ensureDatabases); the server applies its own migrations.
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          until pg_isready -q; do sleep 2; done
          createdb ccvh 2>/dev/null || true
          npm ci --no-audit --no-fund && npm run build && exec npm start
        ''
      ];
      WorkingDirectory = "${home}/Projects/ccvh";
      RunAtLoad = true;
      KeepAlive = true;
      # Throttle a crash loop (say, the port already taken) to one try a minute.
      ThrottleInterval = 60;
      EnvironmentVariables = {
        PATH = "${postgresql}/bin:${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        # For pg_isready and createdb; the app's own DATABASE_URL names the port too.
        PGPORT = toString osConfig.services.postgresql.port;
      };
      StandardOutPath = log;
      StandardErrorPath = log;
    };
  };
}
