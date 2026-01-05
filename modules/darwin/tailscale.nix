# Tailscale VPN with Mullvad integration for Darwin
#
# Setup steps:
# 1. Open Tailscale app from Applications
# 2. Sign in to your Tailscale account
# 3. Link Mullvad in Tailscale admin: https://login.tailscale.com/admin/settings/integrations
# 4. Use Mullvad exit node from the Tailscale menu bar app
#
# CLI commands (if using CLI):
# - tailscale status                    # Show connection status
# - tailscale exit-node list            # List available exit nodes (including Mullvad)
# - tailscale set --exit-node=          # Disconnect from exit node
# - tailscale set --exit-node=us-nyc-wg-001.mullvad.ts.net  # Connect to Mullvad NYC
_: {
  # Install Tailscale via Homebrew (macOS app with menu bar integration)
  homebrew = {
    casks = [
      "tailscale"
    ];
  };
}
