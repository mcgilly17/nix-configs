# Postgres for the CC+VH workbook app, and its nightly backup, on glados only.
# The app itself runs from its checkout like muse-tools, as a home-manager
# agent: users/michael/common/dev/ccvh.nix. Both run as launchd user agents:
# glados stays logged in to michael's desktop session, which they need to start
# after a reboot.
#
# Logs: ~/Library/Logs/{postgresql,ccvh-backup}.log.
# Backups: nightly `pg_dump -Fc` to ~/Backups/ccvh, newest 14 kept.
{ config, pkgs, ... }:
let
  inherit (config.users.users.michael) home;
  postgresql = config.services.postgresql.package;

  backupDir = "${home}/Backups/ccvh";
  backupsKept = 14;
in
{
  # Listens on localhost and the /tmp socket only (enableTCPIP stays false);
  # peer auth on the socket, md5 on loopback TCP.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    # Under michael's home: the module's /var/lib default is root-owned, and
    # this agent runs as michael. Suffixed with the major version so an
    # upgrade gets a fresh dir to pg_upgrade into.
    dataDir = "${home}/.local/share/postgresql/${postgresql.psqlSchema}";
    initdbArgs = [
      # The module hard-codes `initdb -U postgres`; a later -U wins, so the
      # superuser is michael and peer auth matches his login with no map.
      "--username=michael"
      # launchd gives agents no LANG, which would leave initdb on SQL_ASCII.
      "--encoding=UTF8"
      "--locale-provider=builtin"
      "--builtin-locale=C.UTF-8"
    ];
  };

  # The module sends Postgres's log to stderr but gives the agent nowhere to
  # write it.
  launchd.user.agents.postgresql.serviceConfig.StandardErrorPath =
    "${home}/Library/Logs/postgresql.log";

  # Nightly custom-format dump, written to a temp name first so a failed dump
  # never rotates out a good one. Dated names sort by age, so pruning keeps the
  # newest N. launchd runs a missed slot on wake.
  launchd.user.agents.ccvh-backup = {
    path = [
      postgresql
      pkgs.coreutils
      pkgs.findutils
    ];
    script = ''
      set -eu
      umask 077
      mkdir -p ${backupDir}
      out=${backupDir}/ccvh-$(date +%F).dump
      pg_dump -Fc -f "$out.tmp" ccvh
      mv "$out.tmp" "$out"
      ls -1 ${backupDir}/ccvh-*.dump | sort -r | tail -n +${toString (backupsKept + 1)} | xargs rm -f
    '';
    serviceConfig = {
      StartCalendarInterval = [
        {
          Hour = 3;
          Minute = 30;
        }
      ];
      StandardOutPath = "${home}/Library/Logs/ccvh-backup.log";
      StandardErrorPath = "${home}/Library/Logs/ccvh-backup.log";
    };
  };
}
