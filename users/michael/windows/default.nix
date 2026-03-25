# Windows Config Sync Module
# Declares windows.configFiles and windows.registryFiles options for sub-modules,
# and installs home.activation hooks to sync them to the Windows filesystem.
#
# Guard: all config is wrapped in lib.mkIf isWSL — non-WSL hosts evaluate the
# option types but no activation hooks or side-effects are applied.
#
# Usage: Sub-modules set windows.configFiles."rel/path" = /nix/store/...
# Keys are relative to the Windows home directory (e.g. ".config/komorebi/komorebi.json").
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
  # Each entry: key = relative path under $windowsHomePath/
  #             value = Nix store path (file or directory)
  syncCommands = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      relPath: srcPath:
      let
        destPath = "${windowsHomePath}/${relPath}";
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

  # Generate reg.exe import commands for each registered .reg file.
  regCommands = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: srcPath:
      let
        destPath = "${windowsHomePath}/.config/registry/${name}.reg";
      in
      ''
        _reg_dest="${destPath}"
        _reg_src="${srcPath}"
        $DRY_RUN_CMD mkdir -p "$(dirname "$_reg_dest")"
        $DRY_RUN_CMD cp "$_reg_src" "$_reg_dest"
        $DRY_RUN_CMD chmod 644 "$_reg_dest"
        _win_path="$(/mnt/c/Windows/System32/wslpath.exe -w "$_reg_dest" 2>/dev/null || echo "")"
        if [ -n "$_win_path" ]; then
          if /mnt/c/Windows/System32/reg.exe import "$_win_path" > /dev/null 2>&1; then
            echo "[windows-registry] ${name} -> imported"
          else
            echo "[windows-registry] WARNING: ${name} -> import failed (may need elevation)"
          fi
        else
          echo "[windows-registry] WARNING: ${name} -> could not convert path"
        fi
      ''
    ) cfg.registryFiles
  );
in
{
  imports = [
    ./komorebi
    ./whkd
    ./yasb
    ./portproxy
    ./powershell
    ./windows-terminal
    ./wslconfig
    ./startup
    ./winget
    ./registry
  ];

  # Options declared unconditionally so non-WSL hosts can still evaluate the types.
  options.windows = {
    configFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = ''
        Attribute set of files to sync to the Windows filesystem on activation.
        Keys are paths relative to the Windows home directory (e.g. ".config/komorebi/komorebi.json").
        Values are Nix store paths — files or directories.
        Only applied on WSL hosts (isWSL guard).
      '';
    };

    registryFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = ''
        Attribute set of .reg files to import via reg.exe on activation.
        Keys are descriptive names (e.g. "dark-mode").
        Values are Nix store paths to .reg files.
        HKLM keys require elevation — failures are logged as warnings.
      '';
    };
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
        echo "[windows-sync] All configs synced to ${windowsHomePath}/"
      fi
    '';

    home.activation.importWindowsRegistry = lib.hm.dag.entryAfter [ "syncWindowsConfigs" ] ''
      if [ ! -d "${windowsHomePath}" ]; then
        exit 0
      fi

      ${regCommands}
    '';
  };
}
