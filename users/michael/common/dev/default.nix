# Development machine specific configuration
# Import this in host configs for dev machines (sephiroth, ganon, etc.)
# NOT for cluster nodes (zenith-1/2/3) or other non-dev machines
{ ... }:
{
  imports = [
    ./kubectl.nix
  ];
}
