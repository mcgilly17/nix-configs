# Tailscale VPN with Mullvad integration for NixOS
#
# Setup steps:
# 1. Run: sudo tailscale up
# 2. Link Mullvad in Tailscale admin: https://login.tailscale.com/admin/settings/integrations
# 3. Use Mullvad exit node: tailscale set --exit-node=<mullvad-node>
#
# Useful commands:
# - tailscale status                    # Show connection status
# - tailscale exit-node list            # List available exit nodes (including Mullvad)
# - tailscale set --exit-node=          # Disconnect from exit node
# - tailscale set --exit-node=us-nyc-wg-001.mullvad.ts.net  # Connect to Mullvad NYC
{ pkgs, ... }:
{
  # Enable Tailscale service
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # Allow using exit nodes
    extraSetFlags = [ "--exit-node-allow-lan-access" ]; # Allow LAN access while using exit node
  };

  # Open firewall for Tailscale
  networking.firewall = {
    # Always allow traffic from Tailscale network
    trustedInterfaces = [ "tailscale0" ];
    # Allow Tailscale UDP port
    allowedUDPPorts = [ 41641 ];
  };

  # Tailscale CLI and GUI
  environment.systemPackages = with pkgs; [
    tailscale
  ];
}
