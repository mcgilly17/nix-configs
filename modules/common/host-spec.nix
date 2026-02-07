# Host Specification Module
# Defines configuration flags for differentiating hosts
{
  config,
  lib,
  ...
}:
{
  options.hostSpec = lib.mkOption {
    type = lib.types.submodule {
      options = {
        # Host identification
        hostName = lib.mkOption {
          type = lib.types.str;
          description = "The hostname of the host";
          default = config.networking.hostName or "";
        };

        # Configuration flags
        isMinimal = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Indicate a minimal host (cluster nodes, containers, etc.)";
        };

        isServer = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Indicate a server host";
        };

        isGaming = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Indicate a host with gaming capabilities";
        };

        isClusterNode = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Indicate a host that is part of a cluster";
        };

        isWSL = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Indicate a WSL2 host";
        };

        hasGPU = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Indicate a host with dedicated GPU for CUDA";
        };
      };
    };
  };
}
