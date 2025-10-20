{
  description = "RK1 Cluster Image Builder - Extends nixos-rk1-imagebuilder with full Nix configuration";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    # Base NixOS packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Hardware-specific RK1 image builder
    nixos-rk1-imagebuilder = {
      url = "github:mcgilly17/nixos-rk1-imagebuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Your full Nix configuration
    nix-configs = {
      url = "github:mcgilly17/nix-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    nix-secrets = {
      url = "github:mcgilly17/nix-secrets";
      inputs = {};
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-rk1-imagebuilder, nix-configs, nix-secrets, sops-nix, ... }@inputs:
  let
    # Support building from multiple host systems (especially Darwin)
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    # Target system for RK1 images
    targetSystem = "aarch64-linux";

    # Your configuration's specialArgs
    specialArgs = {
      inherit inputs;
      inherit (nix-configs.outputs) myVars myLibs;
    };

    # Create RK1 configuration with your full setup
    mkRK1Config = hostName: nixpkgs.lib.nixosSystem {
      system = targetSystem;
      inherit specialArgs;
      modules = [
        # Base RK1 hardware configuration
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

        # SOPS secrets support
        sops-nix.nixosModules.sops

        # Use the proven RK1 hardware configuration from your existing builder
        # but override the basic config with your full setup
        nixos-rk1-imagebuilder.nixosConfigurations.rk1.config._module.args.configuration

        # Your configuration modules
        (nix-configs.outputs.myLibs.relativeToRoot "modules/nixos")
        (nix-configs.outputs.myLibs.relativeToRoot "modules/common")

        # Host-specific configuration
        {
          # Set the hostname for SOPS integration
          networking.hostName = hostName;

          # SOPS configuration for this specific host
          sops = {
            defaultSopsFile = "${inputs.nix-secrets}/secrets.yaml";
            validateSopsFiles = false;
            age = {
              # Use SSH host key for decryption (will be generated on first boot)
              sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
              keyFile = "/var/lib/sops-nix/key.txt";
              generateKey = true;
            };
          };

          # RK1 image settings with bootloader injection
          sdImage = {
            image.baseName = "nixos-${hostName}";
            expandOnBoot = true;

            # Inject RK1 bootloader (reference the bootloader from the hardware builder)
            postBuildCommands = ''
              echo "Installing RK1 bootloader to ${hostName} image..."

              # Get the bootloader file from the nixos-rk1-imagebuilder
              # Note: This path might need adjustment based on how the bootloader is exposed
              bootloader=${nixos-rk1-imagebuilder.packages.${nixpkgs.system}.bootloader or "${nixos-rk1-imagebuilder}/rk1-bootloader-minimal.bin"}

              # Copy the RK1 bootloader to sectors 64+
              dd if=$bootloader of=$img conv=notrunc seek=64 bs=512

              echo "RK1 bootloader installation complete for ${hostName}"

              # Verify the Rockchip bootloader signature
              echo "Verifying RKNS signature..."
              if hexdump -C -s 32768 -n 16 $img | grep -q "52 4b 4e 53"; then
                echo "✅ RKNS signature found at sector 64"
              else
                echo "❌ RKNS signature NOT found - bootloader installation failed"
                exit 1
              fi

              echo "Ready for flashing ${hostName} to RK1 eMMC storage"
            '';
          };
        }
      ];
    };

  in
  {
    # RK1 cluster configurations with hostnames baked in
    nixosConfigurations = {
      rk1-node1 = mkRK1Config "rk1-node1";
      rk1-node2 = mkRK1Config "rk1-node2";
      rk1-node3 = mkRK1Config "rk1-node3";
      rk1-node4 = mkRK1Config "rk1-node4";
    };

    # Build packages for all supported systems
    packages = nixpkgs.lib.genAttrs supportedSystems (system: {
      # Individual node images
      rk1-node1-image = self.nixosConfigurations.rk1-node1.config.system.build.sdImage;
      rk1-node2-image = self.nixosConfigurations.rk1-node2.config.system.build.sdImage;
      rk1-node3-image = self.nixosConfigurations.rk1-node3.config.system.build.sdImage;
      rk1-node4-image = self.nixosConfigurations.rk1-node4.config.system.build.sdImage;

      # Default to node1
      default = self.packages.${system}.rk1-node1-image;

      # Convenience: build all at once
      all-rk1-images = nixpkgs.legacyPackages.${system}.runCommand "all-rk1-images" {} ''
        mkdir -p $out
        ln -s ${self.packages.${system}.rk1-node1-image}/*.img $out/rk1-node1.img
        ln -s ${self.packages.${system}.rk1-node2-image}/*.img $out/rk1-node2.img
        ln -s ${self.packages.${system}.rk1-node3-image}/*.img $out/rk1-node3.img
        ln -s ${self.packages.${system}.rk1-node4-image}/*.img $out/rk1-node4.img
      '';
    });

    # Development shell
    devShells = nixpkgs.lib.genAttrs supportedSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          nixos-rebuild
        ];

        shellHook = ''
          echo "RK1 Cluster Image Builder"
          echo "Build individual images:"
          echo "  nix build .#rk1-node1-image"
          echo "  nix build .#rk1-node2-image"
          echo "  nix build .#rk1-node3-image"
          echo "  nix build .#rk1-node4-image"
          echo ""
          echo "Build all images:"
          echo "  nix build .#all-rk1-images"
        '';
      };
    });
  };
}