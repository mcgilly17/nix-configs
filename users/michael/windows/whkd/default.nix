# whkd hotkey daemon configuration
# Generates .whkdrc with keybindings for komorebi window management.
#
# Modifier scheme: ctrl+alt as base (avoids zellij alt+hjkl conflict)
#   ctrl+alt+hjkl        = focus
#   ctrl+alt+shift+hjkl  = move/swap
#   ctrl+alt+1-5         = switch workspace
#   ctrl+shift+1-5       = move window to workspace
#
# No isWSL guard needed — parent aggregator handles it.
{ pkgs, ... }:
let
  whkdConfig = ''
    .shell powershell

    # Reload
    ctrl + alt + o                 : taskkill /f /im whkd.exe && start /b whkd
    ctrl + alt + shift + o         : komorebic reload-configuration

    # Window management
    ctrl + alt + q                 : komorebic close
    ctrl + alt + m                 : komorebic minimize

    # Focus direction (hjkl and arrows)
    ctrl + alt + h                 : komorebic focus left
    ctrl + alt + j                 : komorebic focus down
    ctrl + alt + k                 : komorebic focus up
    ctrl + alt + l                 : komorebic focus right
    ctrl + alt + left              : komorebic focus left
    ctrl + alt + down              : komorebic focus down
    ctrl + alt + up                : komorebic focus up
    ctrl + alt + right             : komorebic focus right
    ctrl + alt + oem_comma          : komorebic cycle-focus previous
    ctrl + alt + oem_period         : komorebic cycle-focus next

    # Move/swap windows
    ctrl + alt + shift + h         : komorebic move left
    ctrl + alt + shift + j         : komorebic move down
    ctrl + alt + shift + k         : komorebic move up
    ctrl + alt + shift + l         : komorebic move right
    ctrl + alt + shift + return    : komorebic promote

    # Resize
    ctrl + alt + oem_plus          : komorebic resize-axis horizontal increase
    ctrl + alt + oem_minus         : komorebic resize-axis horizontal decrease
    ctrl + alt + shift + oem_plus  : komorebic resize-axis vertical increase
    ctrl + alt + shift + oem_minus : komorebic resize-axis vertical decrease

    # Toggle window states
    ctrl + alt + t                 : komorebic toggle-float
    ctrl + alt + shift + f         : komorebic toggle-monocle
    ctrl + alt + shift + r         : komorebic retile
    ctrl + alt + p                 : komorebic toggle-pause

    # Layout
    ctrl + alt + x                 : komorebic flip-layout horizontal
    ctrl + alt + y                 : komorebic flip-layout vertical

    # Workspace switching
    ctrl + alt + 1                 : komorebic focus-workspace 0
    ctrl + alt + 2                 : komorebic focus-workspace 1
    ctrl + alt + 3                 : komorebic focus-workspace 2
    ctrl + alt + 4                 : komorebic focus-workspace 3
    ctrl + alt + 5                 : komorebic focus-workspace 4
    ctrl + left                    : komorebic cycle-workspace previous
    ctrl + right                   : komorebic cycle-workspace next

    # Move window to workspace
    ctrl + shift + 1               : komorebic move-to-workspace 0
    ctrl + shift + 2               : komorebic move-to-workspace 1
    ctrl + shift + 3               : komorebic move-to-workspace 2
    ctrl + shift + 4               : komorebic move-to-workspace 3
    ctrl + shift + 5               : komorebic move-to-workspace 4

    # Monitor focus
    ctrl + alt + oem_4             : komorebic cycle-monitor previous
    ctrl + alt + oem_6             : komorebic cycle-monitor next

    # Move window to monitor
    ctrl + shift + left            : komorebic move-to-monitor 0
    ctrl + shift + right           : komorebic move-to-monitor 1
  '';
in
{
  windows.configFiles.".config/whkdrc" = pkgs.writeText "whkdrc" whkdConfig;
}
