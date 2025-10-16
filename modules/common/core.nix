{pkgs, myLibs, ...}: {
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
    ];
  };

  # Better Nix tooling with nh (cross-platform)
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 20d --keep 20";
    flake = builtins.getEnv "HOME" + "/Projects/dots";  # Path to your flake
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
      experimental-features = ["nix-command" "flakes"];

      trusted-users = ["root" "@admin"];

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
