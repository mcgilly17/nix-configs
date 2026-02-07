# Mantis - NixOS WSL Host
# Named after Psycho Mantis (Metal Gear Solid)
# Secondary Windows development machine with GPU
{ ... }:

{
  imports = [
    # Shared WSL configuration
    ../common
  ];

  # Host specification
  hostSpec = {
    hostName = "mantis";
    hasGPU = true;
  };

  networking.hostName = "mantis";
}
