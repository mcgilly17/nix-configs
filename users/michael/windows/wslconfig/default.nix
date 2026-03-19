# .wslconfig — WSL2 tuning
# Synced to %USERPROFILE%\.wslconfig (home root).
# Changes take effect after `wsl --shutdown` + restart.
{ pkgs, ... }:
let
  wslconfigContent = ''
    [wsl2]
    memory=16GB
    swap=4GB
    localhostForwarding=true
    nestedVirtualization=true

    [experimental]
    autoMemoryReclaim=gradual
    sparseVhd=true
  '';
in
{
  windows.configFiles.".wslconfig" = pkgs.writeText "wslconfig" wslconfigContent;
}
