# whkd hotkey daemon configuration
# Generates .whkdrc with keybindings for komorebi window management.
#
# No isWSL guard needed — parent aggregator handles it.
#
# Windows-side prerequisite: whkd must be installed and running.
# Start with: komorebic start --whkd
{ pkgs, ... }:
let
  # Workspace count per monitor (must match komorebi config)
  # Monitor 0: I-V (5 workspaces), Monitor 1: 1-3 (3 workspaces)
  whkdConfig = ''
    .shell pwsh

    # Reload
    alt + o                 : taskkill /f /im whkd.exe && start /b whkd
    alt + shift + o         : komorebic reload-configuration

    # Window management
    alt + q                 : komorebic close
    alt + m                 : komorebic minimize

    # Focus direction (WHKD-02)
    alt + h                 : komorebic focus left
    alt + j                 : komorebic focus down
    alt + k                 : komorebic focus up
    alt + l                 : komorebic focus right
    alt + shift + oem_4     : komorebic cycle-focus previous
    alt + shift + oem_6     : komorebic cycle-focus next

    # Move windows (WHKD-02)
    alt + shift + h         : komorebic move left
    alt + shift + j         : komorebic move down
    alt + shift + k         : komorebic move up
    alt + shift + l         : komorebic move right
    alt + shift + return    : komorebic promote

    # Stack management
    alt + left              : komorebic stack left
    alt + down              : komorebic stack down
    alt + up                : komorebic stack up
    alt + right             : komorebic stack right
    alt + oem_1             : komorebic unstack
    alt + oem_4             : komorebic cycle-stack previous
    alt + oem_6             : komorebic cycle-stack next

    # Resize
    alt + oem_plus          : komorebic resize-axis horizontal increase
    alt + oem_minus         : komorebic resize-axis horizontal decrease
    alt + shift + oem_plus  : komorebic resize-axis vertical increase
    alt + shift + oem_minus : komorebic resize-axis vertical decrease

    # Toggle window states
    alt + t                 : komorebic toggle-float
    alt + shift + f         : komorebic toggle-monocle
    alt + shift + r         : komorebic retile
    alt + p                 : komorebic toggle-pause

    # Layout cycling (WHKD-03)
    alt + x                 : komorebic flip-layout horizontal
    alt + y                 : komorebic flip-layout vertical

    # Workspace switching — monitor 0 (WHKD-01)
    alt + 1                 : komorebic focus-workspace 0
    alt + 2                 : komorebic focus-workspace 1
    alt + 3                 : komorebic focus-workspace 2
    alt + 4                 : komorebic focus-workspace 3
    alt + 5                 : komorebic focus-workspace 4

    # Move windows to workspace (WHKD-01)
    alt + shift + 1         : komorebic move-to-workspace 0
    alt + shift + 2         : komorebic move-to-workspace 1
    alt + shift + 3         : komorebic move-to-workspace 2
    alt + shift + 4         : komorebic move-to-workspace 3
    alt + shift + 5         : komorebic move-to-workspace 4

    # Monitor focus
    alt + shift + oem_comma  : komorebic cycle-monitor previous
    alt + shift + oem_period : komorebic cycle-monitor next
  '';
in
{
  windows.configFiles."whkd/whkdrc" = pkgs.writeText "whkdrc" whkdConfig;
}
