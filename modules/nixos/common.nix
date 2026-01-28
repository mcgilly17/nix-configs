# Common NixOS configuration for all hosts
{
  lib,
  inputs,
  outputs,
  myLibs,
  specialArgs,
  ...
}:

{
  imports = [
    # Home Manager for NixOS
    inputs.home-manager.nixosModules.home-manager

    # Catppuccin theming (system-level for Plymouth, GRUB, console, etc.)
    inputs.catppuccin.nixosModules.catppuccin

    # Your existing cross-platform core
    (myLibs.relativeToRoot "modules/common/core.nix")

    # Tailscale VPN with Mullvad integration
    ./tailscale.nix
  ];

  # Home Manager configuration (matching your Darwin pattern)
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = specialArgs;
  };

  # Catppuccin system theming (applies only to enabled services)
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "sapphire";
    # Disable SDDM theming (we use greetd on desktops)
    sddm.enable = false;
  };

  # NixOS-specific services
  services = {
    # mDNS discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
    };

    # Keyboard remapping (Caps Lock → Escape on tap, Ctrl on hold)
    keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main = {
          capslock = "overload(control, esc)";
        };
      };
    };

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkDefault "yes"; # For nixos-anywhere, hosts can override
        PasswordAuthentication = false;
      };
    };
  };

  # Enable NetworkManager for network connectivity
  networking.networkmanager.enable = true;

  # Enable sudo without password for wheel group (for nixos-anywhere)
  security.sudo.wheelNeedsPassword = false;

  # Memory optimization with compressed RAM swap
  zramSwap.enable = true;

  # System programs
  programs = {
    # Enhanced system-level zsh (matches your Darwin setup)
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };

    # Better Nix tooling with nh (NixOS system-level)
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 20d --keep 20";
      flake = "/home/michael/Projects/dots";
    };

    # 1Password CLI (required for proper permissions and shell plugin integration)
    _1password.enable = true;
  };

  # Your timezone/locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # Allow unfree packages and apply overlays
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = builtins.attrValues outputs.overlays;

  system.stateVersion = "24.05";
}
