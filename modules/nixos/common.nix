# Common NixOS configuration for all hosts
{ inputs, myLibs, specialArgs, ... }:

{
  imports = [
    # Home Manager for NixOS
    inputs.home-manager.nixosModules.home-manager

    # Your existing cross-platform core
    (myLibs.relativeToRoot "modules/common/core.nix")

  ] ++ (map myLibs.relativeToRoot [
    "users/michael"  # Your existing user setup
  ]);

  # Home Manager configuration (matching your Darwin pattern)
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
  };

  # NixOS-specific settings
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes"; # For nixos-anywhere
      PasswordAuthentication = false;
    };
  };

  # Enable NetworkManager for network connectivity
  networking.networkmanager.enable = true;

  # Enable sudo without password for wheel group (for nixos-anywhere)
  security.sudo.wheelNeedsPassword = false;

  # Memory optimization with compressed RAM swap
  zramSwap.enable = true;

  # Enhanced system-level zsh (matches your Darwin setup)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Your timezone/locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05";
}