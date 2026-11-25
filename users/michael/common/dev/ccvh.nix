# CC+VH workbook app (~/Projects/ccvh), kept running as a launchd user agent
# like muse-tools: it needs the desktop session, and its Postgres is a user
# agent too (hosts/glados/ccvh.nix). Opt-in per host, so not in ./default.nix;
# import it from the host file.
#
# Its port and database live in the checkout's gitignored .env (see its
# .env.example), not here. It listens on 127.0.0.1 only; the tailnet reaches it
# at https://<glados>:8443 through `tailscale serve`, set on every start.
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
  checkout = "${home}/Projects/ccvh";
  # The Homebrew Tailscale app's CLI (modules/darwin/tailscale.nix).
  tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
in
{
  launchd.agents.ccvh = {
    enable = true;
    config = {
      # Everything after the checkout, so a rebuild is the whole setup: the
      # database (nix-darwin has no ensureDatabases) and the starter data only
      # when that database is new, and the tailnet address. The server applies
      # its own migrations.
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          set -e
          cd ${checkout} || { echo "clone the app to ${checkout} (see its deploy/README.md)"; exit 1; }
          until pg_isready -q; do sleep 2; done
          fresh=; createdb ccvh 2>/dev/null && fresh=1
          npm ci --no-audit --no-fund && npm run build
          # A failed seed drops the new, empty database so the next start retries it.
          [ -z "$fresh" ] || node --env-file=.env dist/server/seed.js || { dropdb ccvh; exit 1; }
          # 443 on glados is T3 Code's: never take or share it.
          ${tailscale} serve --bg --https=8443 http://127.0.0.1:4317 || echo "tailscale serve failed; app still starts"
          exec npm start
        ''
      ];
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
