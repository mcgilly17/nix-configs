{
  lib,
  outputs,
  nixpkgs,
  ...
}:
{
  ###################################################################################
  #
  #  Core configuration for nix-darwin
  #
  #  All the configuration options are documented here:
  #    https://daiderd.com/nix-darwin/manual/index.html#sec-options
  #
  ###################################################################################

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = builtins.attrValues outputs.overlays;

  # Auto upgrade the nix-daemon service.
  # services.nix-daemon.enable = true;

  nix = {
    # Disable auto-optimise-store because of this issue:
    #   https://github.com/NixOS/nix/issues/7273
    # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
    settings = {
      auto-optimise-store = false;
      download-buffer-size = 524288000;
    };

    # Use sephiroth (RK1 dev server) as a remote builder for aarch64-linux
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "sephiroth";
        sshUser = "michael";
        system = "aarch64-linux";
        maxJobs = 4;
        supportedFeatures = [
          "nixos-test"
          "big-parallel"
        ];
      }
    ];

    # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
    registry.nixpkgs.flake = nixpkgs;

    # make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
    # discard all the default paths, and only use the one from this flake.
    nixPath = lib.mkForce [ "/etc/nix/inputs" ];
  };

  environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
}
