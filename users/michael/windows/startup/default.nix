# Startup script for Windows desktop environment
# Places a .vbs script in the Windows Startup folder to silently launch yasb,
# which in turn starts komorebi+whkd via its komorebi.start_command config.
{ pkgs, ... }:
let
  # VBScript is more reliable than .ps1 for silent startup — no console flash.
  startupScript = ''
    Set WshShell = CreateObject("WScript.Shell")
    WshShell.Run "yasb", 0, False
  '';
in
{
  windows.configFiles."AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/start-desktop-env.vbs" =
    pkgs.writeText "start-desktop-env.vbs" startupScript;
}
