# Komorebi tiling window manager configuration
# Generates komorebi.json via builtins.toJSON and registers it with the
# windows.configFiles sync pipeline from Phase 1.
#
# No isWSL guard needed here — the parent aggregator (windows/default.nix)
# wraps the config block in lib.mkIf isWSL. This module sets
# windows.configFiles unconditionally, which is correct: the option is
# declared unconditionally and sub-modules may reference it freely.
#
# Windows-side prerequisite (one-time manual step, outside Nix):
#   Set KOMOREBI_CONFIG_HOME in PowerShell profile:
#   $Env:KOMOREBI_CONFIG_HOME = "$Env:USERPROFILE\.config\komorebi"
#   This tells komorebi to look in .config/komorebi/ where Phase 1 deposits files.
{
  pkgs,
  ...
}:
let
  komorebiConfig = {
    # Schema and meta (KOMO-01)
    "$schema" = "https://raw.githubusercontent.com/LGUG2Z/komorebi/v0.1.40/schema.json";
    app_specific_configuration_path = "$Env:KOMOREBI_CONFIG_HOME/applications.json";

    # Window behaviour (KOMO-01)
    # Cloak = Windows 11-specific API for clean hide of unfocused windows
    window_hiding_behaviour = "Cloak";
    cross_monitor_move_behaviour = "Insert";

    # Layout and spacing (KOMO-01)
    default_workspace_padding = 10;
    default_container_padding = 10;
    border = true;
    border_width = 8;
    border_offset = -1;

    # Catppuccin Mocha theme — native palette support, no hex values needed (KOMO-03)
    theme = {
      palette = "Catppuccin";
      name = "Mocha";
      bar_accent = "Sapphire";
      single_border = "Sapphire";
      stack_border = "Green";
      floating_border = "Yellow";
      monocle_border = "Mauve";
      unfocused_border = "Surface1";
    };

    # Float rules — defined here in komorebi.json, NOT in applications.json.
    # applications.json is managed by komorebic fetch-asc and would overwrite
    # any custom rules placed there. (KOMO-02)
    floating_applications = [
      # Windows Settings
      {
        kind = "Exe";
        id = "SystemSettings.exe";
        matching_strategy = "Equals";
      }
      # Task Manager
      {
        kind = "Class";
        id = "TaskManagerWindow";
        matching_strategy = "Legacy";
      }
      # Windows Explorer file operation dialogs
      {
        kind = "Class";
        id = "OperationStatusWindow";
        matching_strategy = "Legacy";
      }
      # Control Panel
      {
        kind = "Title";
        id = "Control Panel";
        matching_strategy = "Equals";
      }
    ];

    # Per-monitor workspace configuration (KOMO-04)
    # monitors[0] = primary, monitors[1] = secondary.
    # komorebi silently ignores extra entries when fewer monitors are connected.
    monitors = [
      {
        workspaces = [
          {
            name = "I";
            layout = "BSP";
          }
          {
            name = "II";
            layout = "VerticalStack";
          }
          {
            name = "III";
            layout = "HorizontalStack";
          }
          {
            name = "IV";
            layout = "Grid";
          }
          {
            name = "V";
            layout = "Monocle";
          }
        ];
      }
      {
        workspaces = [
          {
            name = "1";
            layout = "BSP";
          }
          {
            name = "2";
            layout = "VerticalStack";
          }
          {
            name = "3";
            layout = "HorizontalStack";
          }
        ];
      }
    ];
  };
in
{
  windows.configFiles."komorebi/komorebi.json" = pkgs.writeText "komorebi.json" (
    builtins.toJSON komorebiConfig
  );
}
