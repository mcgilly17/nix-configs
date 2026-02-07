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
    # Auto-prune to save disk space
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # NVIDIA Container Toolkit for GPU containers
  # WSL provides drivers from Windows via /usr/lib/wsl/lib
  hardware.nvidia-container-toolkit = lib.mkIf config.hostSpec.hasGPU {
    enable = true;
    mount-nvidia-executables = false;
    # Suppress assertion - WSL provides drivers from Windows
    suppressNvidiaDriverAssertion = true;
  };

  # Add michael to docker group
  users.users.michael.extraGroups = [ "docker" ];

  # Docker tooling
  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];
}
