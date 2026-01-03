{
  pkgs,
  lib,
  specialArgs,
  config,
  ...
}:
let
  inherit (specialArgs.myVars.users) michael;
  inherit (pkgs.stdenv) isDarwin;
in
{
  # Define the user account for michael.
  users.users."${michael.username}" = {
    home = if isDarwin then "/Users/${michael.username}" else "/home/${michael.username}";
    description = michael.userFullName;
  }
  // lib.optionalAttrs (!isDarwin) {
    isNormalUser = true;
    shell = pkgs.zsh;
    group = michael.username;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    initialPassword = "changeme"; # Change with: passwd
  };

  # Create the user's group on NixOS
  users.groups.${michael.username} = lib.mkIf (!isDarwin) { };

  # Import Michael's home manager configuration for the current host.
  home-manager.users.${michael.username} = import (
    specialArgs.myLibs.relativeToRoot "users/${michael.username}/hosts/${config.networking.hostName}.nix"
  );
}
