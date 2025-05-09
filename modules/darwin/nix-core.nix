{
  pkgs,
  lib,
  outputs,
  nixpkgs,
  ...
}: {
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

  # Disable auto-optimise-store because of this issue:
  #   https://github.com/NixOS/nix/issues/7273
  # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
  nix.settings.auto-optimise-store = false;
  nix.settings.download-buffer-size = 524288000;

  # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
  nix.registry.nixpkgs.flake = nixpkgs;

  environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
  # make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
  # discard all the default paths, and only use the one from this flake.
  nix.nixPath = lib.mkForce ["/etc/nix/inputs"];
}
