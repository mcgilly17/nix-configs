{ pkgs, ... }:
{
  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  #
  # UI apps on MacOS will get installed to /Applications/Nix Apps
  environment = {
    systemPackages = with pkgs; [
      gnugrep # replacee macos's grep
      gnutar # replacee macos's tar

      # macOS only apps
      # TODO: decide if these should be moved to /users/michael/darwin/default.nix
      utm # virtual machines
      vscode
      dockutil
    ];

    variables = {
      # Fix https://github.com/LnL7/nix-darwin/wiki/Terminfo-issues
      # TERMINFO_DIRS = map (path: path + "/share/terminfo") config.environment.profiles ++ [ "/usr/share/terminfo" ];
      EDITOR = "nvim";
    };

    shells = [
      pkgs.bash
      pkgs.zsh
    ];

    pathsToLink = [ "/share/zsh" ];
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;

  # https://github.com/LnL7/nix-darwin/blob/master/modules/homebrew.nix
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    global = {
      brewfile = true;
      autoUpdate = true;
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      Things3 = 904280696;
    };

    taps = [
    ];

    # `brew install`
    brews = [
      "m-cli"
    ];

    # `brew install --cask`
    casks = [
      # Utilities
      "raycast" # Better Spotlight
      "karabiner-elements" # keyboard management
      "superhuman" # email client
      "appcleaner" # app remover
      "yubico-authenticator"
      ## Internet Apps
      "discord" # Internet Chat"
      "google-chrome"
      "reader"
      "obsidian"

      # Entertainment
      "vlc" # VLC is a free and open source cross-platform multimedia player and framework that plays most multimedia files as well as DVDs, Audio CDs, VCDs, etc. https://www.videolan.org/vlc/index.en-GB.html
      "spotify" # Music player.

      ## Security
      "1password" # Password manager "

      ## Utilities
      "betterzip" # BetterZip: the most advanced zip and rar archiver for file compression, encryption. BetterZip makes it easy to work with zip, rar, 7-zip, tar, and xz https://macitbetter.com/"
      # "brooklyn" #Lovelyscreensaver"
      "notion" # Organise life"
      "fantastical" # the worlds best calendar"
      "transmit" # FTP Client transmit"
      "calibre" # unclear"

      ## Messaging and Communication
      "whatsapp" # Desktop Whatsapp client"
      "moonlight" # Game streaming client (for Sunshine)

      "qlcolorcode" # Preview source code files with syntax highlighting https://github.com/anthonygelibert/QLColorCode"

      # "launchrocket" #LaunchRocket. A Mac PreferencePane for managing services with launchd https://github.com/jimbojsb/launchrocket"
      # "suspicious-package" #An Application for Inspecting macOS Installer Packages https://www.mothersruin.com/software/SuspiciousPackage/"
      # "gpg-suite" #Everything you need to get started with secure communication and encrypting files in one simple package"

      ## Entertainment
      # "vlc" #VLC is a free and open source cross-platform multimedia player and framework that plays most multimedia files as well as DVDs, Audio CDs, VCDs, etc. https://www.videolan.org/vlc/index.en-GB.html"
      # "steam" #Steam is a digital distribution platform for video games developed by Valve Corporation, which offers digital rights management, multiplayer servers, video streaming, and social networking services https://store.steampowered.com/"
      # "plex-media-player" #Plex media player"
      # "deluge" #DELUGE"

      ## Productivity
      # "bitbar" #Put the output from any script or program in your Mac OS X Menu Bar https://getbitbar.com"

      # "skype" #Free online calls, messaging, affordable international calling to mobiles or landlines and Skype for Business for effective collaboration https://www.skype.com/en/"
      # "zoom" #Zoom Delivers the Best Experience for the Best Price. Sign Up Free Today! Mobile Screen Sharing. HD Screen Sharing. Video Collaboration. Unbeatable Price. Superior Audio Quality. Easy To Use https://zoom.us/"

      ## Office/Notes
      # "macdown" #MacDown is an open source Markdown editor for macOS https://macdown.uranusjr.com/"

      ## Menu and Sidebar applications
      # "menubar-stats" #MenuBar Stats 2 is composed of modules (CPU, Disk, Network,...). Each module can be seen in your menu bar https://www.seense.com/menubarstats/"

      # "ubersicht" #Übersicht lets you run system commands and display their output on your desktop in little containers http://tracesof.net/uebersicht/"
      # "syntax-highlight" #unclear"
      # "numi" #unclear"
      # "via" #unclear"
      # "suspicious-package" #unclear"

      ## QuickLook plugins
      # "qlimagesize" #Display image size and resolution https://github.com/Nyx0uf/qlImageSize"
      # "qlvideo" #Preview most types of video files, as well as their thumbnails, cover art and metadata https://github.com/Marginal/QLVideo"
      # "provisionql" #Preview iOS / macOS app and provision information https://github.com/ealeksandrov/ProvisionQL"
      # "qlmarkdown" #Preview Markdown files https://github.com/toland/qlmarkdown"
      # "qlstephen" #Preview plain text files without or with unknown file extension. Example: README, CHANGELOG, index.styl, etc. https://github.com/whomwah/qlstephen"
      # "quicklook-json" #Preview JSON files http://www.sagtau.com/quicklookjson.html"
      # "quicklook-csv" #A QuickLook plugin for CSV files https://github.com/p2/quicklook-csv"
      # "qlmobi" #Quick Look plugin for Kindle ebook formats https://github.com/bfabiszewski/QLMobi"
    ];
  };
}
