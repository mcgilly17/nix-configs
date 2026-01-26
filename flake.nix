{
  description = "Mcgilly17 nix configuration WIP - will support MacOS, Linux and WSL";

  inputs = {
    #################### Official Package Sources ####################

    # NixPkgs official github; Following unstable by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-23.11";

    # Hardware control
    nix-hardware.url = "github:nixos/nixos-hardware";

    # Home manager, for managing user configs etc
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Mac OS management through Darwin
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #################### Utilities / Extras ####################

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    # Secrets management
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Walker v2 launcher
    walker.url = "github:abenz1267/walker";

    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative partitioning and formatting
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Remote NixOS installation
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #################### Non Flakes ####################
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    #################### Personal Repositories ####################

    # Private secrets repo.
    # Authenticate via https and use shallow clone
    nix-secrets = {
      url = "git+https://github.com/mcgilly17/nix-secrets.git?ref=main&shallow=1";
      inputs = { };
    };
    mosaic = {
      url = "github:mcgilly17/Mosaic";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (self) outputs;

      forAllSystems = lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      myVars = import ./resources/vars.nix { inherit inputs lib; };
      myLibs = import ./resources/libs.nix { inherit lib; };

      # Add custom libs, vars, nixpkgs instance, and all the inputs to mySpecialArgs,
      # so they can be used in all downstream modules.
      specialArgs = {
        inherit
          inputs
          outputs
          myVars
          myLibs
          nixpkgs
          ;
      };
    in
    {
      overlays = import ./overlays { inherit inputs outputs; };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      darwinConfigurations = {
        bowser = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          inherit specialArgs;
          modules = [
            ./hosts/bowser
          ];
        };
      };

      # NixOS system configurations
      nixosConfigurations = {
        ganon = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/nixos/ganon
          ];
        };

        # RK1 Dev Node - Full development environment with Tailscale
        sephiroth = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/nixos/rk1/sephiroth
          ];
        };

        # Nova K3s Cluster - Control plane
        nova-1 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/nixos/rk1/nova-1
          ];
        };

        # Nova K3s Cluster - Agent
        nova-2 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/nixos/rk1/nova-2
          ];
        };

        # Nova K3s Cluster - Agent
        nova-3 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/nixos/rk1/nova-3
          ];
        };

        glados = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [
            ./hosts/nixos/glados
          ];
        };
      };
    };
}
