# Mosh - roaming SSH replacement that survives suspend and network changes
#
# Installed everywhere because every host is both ends of a connection: the
# client needs `mosh`, the host being reached needs `mosh-server`.
#
# No firewall rules needed for the way these machines are reached. Mosh
# wants UDP 60000-61000 inbound, and the NixOS hosts already trust
# tailscale0 wholesale (modules/nixos/tailscale.nix); open
# networking.firewall.allowedUDPPortRanges only if reaching one off-tailnet.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mosh
  ];
}
