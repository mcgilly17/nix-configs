# WSL2 GPU/CUDA Configuration Module
# Enables GPU passthrough and CUDA development in WSL2
{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.hostSpec.hasGPU {
  # CUDA toolkit and development tools
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
  ];

  # CUDA environment variables
  environment.sessionVariables = {
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    LD_LIBRARY_PATH = lib.mkForce "/usr/lib/wsl/lib:${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudnn}/lib";
  };

  # WSL2 uses the Windows NVIDIA driver via /usr/lib/wsl/lib
  # No need to install nvidia drivers in NixOS - they're provided by Windows
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # Mesa for OpenGL fallback
      mesa
    ];
  };

  # Allow unfree packages (required for CUDA)
  nixpkgs.config.cudaSupport = true;
}
