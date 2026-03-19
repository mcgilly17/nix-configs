# Komorebi tiling window manager configuration
# Generates komorebi.json via builtins.toJSON and registers it with the
# windows.configFiles sync pipeline from Phase 1.
#
# No isWSL guard needed here — the parent aggregator (windows/default.nix)
# wraps the config block in lib.mkIf isWSL. This module sets
# windows.configFiles unconditionally, which is correct: the option is
# declared unconditionally and sub-modules may reference it freely.
#
# KOMOREBI_CONFIG_HOME is set automatically by the PowerShell profile module
# (windows/powershell) to point at %USERPROFILE%\.config\komorebi.
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
    border = false;
    border_width = 0;
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
      # File Explorer
      {
        kind = "Class";
        id = "CabinetWClass";
        matching_strategy = "Equals";
      }
      # Calculator
      {
        kind = "Exe";
        id = "CalculatorApp.exe";
        matching_strategy = "Equals";
      }
      # 1Password
      {
        kind = "Exe";
        id = "1Password.exe";
        matching_strategy = "Equals";
      }
    ];

    # Workspace rules — pin apps to specific workspaces
    initial_workspace_rules = [
      {
        kind = "Exe";
        id = "WhatsApp.exe";
        matching_strategy = "Equals";
        monitor_index = 0;
        workspace_name = "III";
      }
      {
        kind = "Exe";
        id = "Discord.exe";
        matching_strategy = "Equals";
        monitor_index = 0;
        workspace_name = "III";
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
            layout = "BSP";
          }
          {
            name = "III";
            layout = "BSP";
          }
          {
            name = "IV";
            layout = "BSP";
          }
          {
            name = "V";
            layout = "BSP";
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
            layout = "BSP";
          }
          {
            name = "3";
            layout = "BSP";
          }
        ];
      }
    ];
  };
in
{
  windows.configFiles.".config/komorebi/komorebi.json" = pkgs.writeText "komorebi.json" (
    builtins.toJSON komorebiConfig
  );
}
