# WSL2 Docker Configuration Module
# Docker with NVIDIA runtime for GPU containers
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Docker daemon
  virtualisation.docker = {
    enable = true;
    # Enable NVIDIA runtime when GPU is available
    enableNvidia = config.hostSpec.hasGPU;
    # Auto-prune to save disk space
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Add michael to docker group
  users.users.michael.extraGroups = [ "docker" ];

  # Docker tooling
  environment.systemPackages =
    with pkgs;
    [
      docker-compose
      lazydocker
    ]
    ++ lib.optionals config.hostSpec.hasGPU [
      nvidia-container-toolkit
    ];
}
