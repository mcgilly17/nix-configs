# Ocelot - NixOS WSL Host
# Named after Revolver Ocelot (Metal Gear Solid)
# Primary Windows development machine with GPU
{ ... }:

{
  imports = [
    # Shared WSL configuration
    ../common
  ];

  # Host specification
  hostSpec = {
    hostName = "ocelot";
    hasGPU = true;
  };

  networking.hostName = "ocelot";
}
