#############################################################
#
#  Bowser - MacBook Pro 16" M1 Max
#  MacOS
#
###############################################################
{
  inputs,
  specialArgs,
  myLibs,
  ...
}:
let
  hostname = "bowser";
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ]
  ++ (map myLibs.relativeToRoot [
    #Common Darwin Modules
    "modules/darwin"

    # Deskotop Brew Apps
    "modules/darwin/apps/desktop.nix"
    "modules/darwin/apps/creative.nix"
    "modules/darwin/apps/development.nix"

    #User configs for Michael
    "users/michael"
  ]);

  #################### Host specific Darwin Configs ####################

  networking = {
    hostName = hostname;
    computerName = hostname;
  };

  system = {
    defaults.smb.NetBIOSName = hostname;

    # Workaround for nix-darwin#1817: darwin-manual-html fails because
    # nix-darwin still passes --toc-depth to nixos-render-docs, which now
    # requires --sidebar-depth. darwin-uninstaller runs its own eval that
    # also builds the manual, so it must be disabled too. Re-enable once
    # #1818 or #1819 lands.
    tools.darwin-uninstaller.enable = false;

    # as per https://daiderd.com/nix-darwin/manual/index.html#opt-system.stateVersion
    stateVersion = 5; # Did you read the comment?
  };

  documentation.doc.enable = false;

  #################### Home Manager Configs ####################

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
  };

  #################### Homebrew Configs ####################

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = false;

    # User owning the Homebrew prefix
    user = "michael";

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.

    mutableTaps = false;
  };
}
