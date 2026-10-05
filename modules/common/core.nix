{ pkgs, myLibs, ... }:
{
  imports = [
    (myLibs.relativeToRoot "modules/common/host-spec.nix")
  ];

  # No matter what environment we are in we want these tools for root, and the user(s)
  environment = {
    systemPackages = with pkgs; [
      git # used by nix flakes

      # archives
      zip
      p7zip
      unrar # extract RAR archives
      xz # extract XZ archives

      # Text Processing
      # Docs: https://github.com/learnbyexample/Command-line-text-processing
      gnugrep # GNU grep, provides `grep`/`egrep`/`fgrep`
      gnused # GNU sed, very powerful(mainly for replacing text in files)
      wget
      curl # Will also install with brew on MacOS
      coreutils
      nix-prefetch

      sops
      ssh-to-age
      age

      # Better Nix tooling (configured via programs.nh in system/home-manager)
      nh
    ];
  };

  # Enhanced sudo configuration (cross-platform)
  security.sudo.extraConfig = ''
    Defaults lecture = never            # No sudo lectures after reboot
    Defaults pwfeedback                 # Show asterisks when typing password
    Defaults timestamp_timeout=120      # Only ask for password every 2 hours
    Defaults env_keep+=SSH_AUTH_SOCK    # Keep SSH agent forwarding working
  '';

  nix = {
    settings = {
      # enable flakes globally
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # devenv is pinned to its flake input (see overlays/default.nix), and
      # those outputs only exist in devenv's own cache -- without this every
      # rebuild compiles devenv and its ~900 Rust crates from source.
      substituters = [
        "https://cache.nixos.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];

      # @admin for macOS, @wheel for NixOS
      trusted-users = [
        "root"
        "@admin"
        "@wheel"
      ];

      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB
      warn-dirty = false;
    };

    # Disable old garbage collection since nh handles it now
    # gc = {
    #   automatic = true;
    #   options = "--delete-older-than 10d";
    # };
  };
}
