# WSL port proxy setup script
# Syncs a PowerShell script to set up netsh port forwarding from WSL to Windows localhost.
# Useful for reaching Windows-only services (e.g. Figma MCP) from WSL in NAT mode.
#
# Run from elevated PowerShell:
#   .\setup-wsl-portproxy.ps1              — forward default Figma MCP port (3845)
#   .\setup-wsl-portproxy.ps1 -Port 8080   — forward a custom port
#   .\setup-wsl-portproxy.ps1 -Remove      — remove the forward and firewall rule
{ pkgs, ... }:
let
  script = ''
    #Requires -RunAsAdministrator
    param(
        [int]$Port = 3845,
        [switch]$Remove
    )

    $ruleName = "WSL Port Forward - $Port"

    if ($Remove) {
        Write-Host "Removing port proxy for port $Port..." -ForegroundColor Yellow
        netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=$Port 2>$null
        Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        Write-Host "Done." -ForegroundColor Green
        return
    }

    # Remove existing rule to make this idempotent
    netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=$Port 2>$null

    Write-Host "Adding port proxy: 0.0.0.0:$Port -> 127.0.0.1:$Port" -ForegroundColor Cyan
    netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=$Port connectaddress=127.0.0.1 connectport=$Port

    # Firewall rule (idempotent)
    Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort $Port -Protocol TCP -Action Allow | Out-Null
    Write-Host "Firewall rule added: $ruleName" -ForegroundColor Cyan

    # Verify
    Write-Host "`nActive port proxies:" -ForegroundColor Green
    netsh interface portproxy show v4tov4

    Write-Host "`nFrom WSL, connect to port $Port via the Windows host IP:" -ForegroundColor Green
    Write-Host "  grep nameserver /etc/resolv.conf | awk '{print `$2}'" -ForegroundColor Gray
  '';
in
{
  windows.configFiles.".config/scripts/setup-wsl-portproxy.ps1" =
    pkgs.writeText "setup-wsl-portproxy.ps1" script;
}
