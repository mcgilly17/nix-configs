# Windows Config Sync Module
# Declares the windows.configFiles option for sub-modules to register files,
# and installs a home.activation hook to copy them to the Windows filesystem.
#
# Guard: all config is wrapped in lib.mkIf isWSL — non-WSL hosts evaluate the
# option type but no activation hooks or side-effects are applied.
#
# Usage: Sub-modules (e.g. komorebi, whkd) set windows.configFiles."rel/path" = /nix/store/...
# and this hook copies them under /mnt/c/Users/michael/.config/ on activation.
{
  lib,
  osConfig ? { },
  config,
  ...
}:
let
  isWSL = osConfig.hostSpec.isWSL or false;
  cfg = config.windows;
  windowsHomePath = "/mnt/c/Users/michael";

  # Generate one copy command per registered file at Nix eval time.
  # Each entry: key = relative path under $windowsHomePath/.config/
  #             value = Nix store path (file or directory)
  syncCommands = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      relPath: srcPath:
      let
        destPath = "${windowsHomePath}/.config/${relPath}";
      in
      ''
        _dest="${destPath}"
        _src="${srcPath}"
        _parent="$(dirname "$_dest")"
        if [ -d "$_src" ]; then
          $DRY_RUN_CMD mkdir -p "$_dest"
          $DRY_RUN_CMD cp -rT "$_src" "$_dest"
          echo "[windows-sync] ${relPath} -> synced (directory)"
        elif [ -f "$_src" ]; then
          $DRY_RUN_CMD mkdir -p "$_parent"
          $DRY_RUN_CMD cp "$_src" "$_dest"
          $DRY_RUN_CMD chmod 644 "$_dest"
          echo "[windows-sync] ${relPath} -> synced"
        else
          echo "[windows-sync] WARNING: source not found for ${relPath}: $_src"
          _failed=$((_failed + 1))
        fi
      ''
    ) cfg.configFiles
  );
in
{
  # Option declared unconditionally so non-WSL hosts can still evaluate the type
  # (sub-modules may reference it regardless of isWSL).
  options.windows.configFiles = lib.mkOption {
    type = lib.types.attrsOf lib.types.path;
    default = { };
    description = ''
      Attribute set of files to sync to the Windows filesystem on activation.
      Keys are relative paths under $windowsHomePath/.config/ (e.g. "komorebi/komorebi.json").
      Values are Nix store paths — files or directories.
      Only applied on WSL hosts (isWSL guard). Leave empty until Phase 2 sub-modules register entries.
    '';
  };

  # All config is guarded — non-WSL hosts get no activation hooks.
  config = lib.mkIf isWSL {
    home.activation.syncWindowsConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Mount guard: abort gracefully if the Windows filesystem is not accessible.
      if [ ! -d "${windowsHomePath}" ]; then
        echo "[windows-sync] /mnt/c/Users/michael not accessible — skipping Windows config sync"
        exit 0
      fi

      _failed=0

      ${syncCommands}

      if [ "$_failed" -gt 0 ]; then
        echo "[windows-sync] WARNING: $_failed file(s) failed to sync — check sources above"
      else
        echo "[windows-sync] All configs synced to ${windowsHomePath}/.config/"
      fi
    '';
  };
}
