# Development machine specific configuration
# Import this in host configs for dev machines (ganon, etc.)
# NOT for cluster nodes (zenith-0/1/2/3) or other non-dev machines
{ ... }:
{
  imports = [
    ./gcloud.nix
    ./kubectl.nix
  ];
}
