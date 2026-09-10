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

    # No aarch64-linux remote builder currently. The RK1 dev server that filled
    # this role is now zenith-0, a cluster node, and building on the control
    # plane is a bad trade. deploy-rs sets remoteBuild = true for every zenith
    # node, so they build their own closures and don't need one.

    # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
    registry.nixpkgs.flake = nixpkgs;

    # make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
    # discard all the default paths, and only use the one from this flake.
    nixPath = lib.mkForce [ "/etc/nix/inputs" ];
  };

  environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
}
