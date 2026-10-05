#############################################################
#
#  GLaDOS - Mac Pro 2019 (Intel)
#  MacOS - x86_64-darwin
#
###############################################################
{
  inputs,
  pkgs,
  specialArgs,
  myLibs,
  ...
}:
let
  hostname = "glados";
in
{
  imports = [
    # Stable-branch home-manager to match the pinned x86_64-darwin nixpkgs
    inputs.home-manager-x86.darwinModules.home-manager
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

  # Reached over ssh and mosh, so zellij must survive a dropped connection:
  # this flips on_force_close to "detach" instead of "quit" and makes logins
  # reattach to a named session (users/michael/common/tui/zellij/default.nix).
  hostSpec.isServer = true;

  # Eternal Terminal server, reachable over tailscale only: --bindip pins the
  # listener to glados's tailnet address, so it never accepts connections on
  # the LAN or any other interface. KeepAlive retries the bind until tailscale
  # has brought that address up after boot.
  launchd.daemons.etserver.serviceConfig = {
    ProgramArguments = [
      "${pkgs.eternal-terminal}/bin/etserver"
      "--port"
      "2022"
      "--bindip"
      "100.108.239.86"
      "--logtostdout"
    ];
    RunAtLoad = true;
    KeepAlive = true;
    StandardOutPath = "/var/log/etserver.log";
    StandardErrorPath = "/var/log/etserver.err.log";
  };

  # Desktop workstation used over ssh - never sleep (display may still)
  power.sleep.computer = "never";

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
    # Install Homebrew under the default prefix (/usr/local on Intel)
    enable = true;

    # Apple Silicon Only option - this is an Intel machine
    enableRosetta = false;

    # User owning the Homebrew prefix
    user = "michael";

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "max-sixty/homebrew-worktrunk" = inputs.homebrew-worktrunk;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.

    mutableTaps = false;
  };
}
