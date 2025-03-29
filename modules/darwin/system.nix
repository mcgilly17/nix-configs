{pkgs, ...}:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#  Incomplete list of macOS `defaults` commands :
#    https://github.com/yannbertrand/macos-defaults
#
###################################################################################
{
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      # customize macOS
      NSGlobalDomain = {
        # Disable swipe navigation features with mouse and trackpad
        AppleEnableMouseSwipeNavigateWithScrolls = false;
        AppleEnableSwipeNavigateWithScrolls = false;

        AppleICUForce24HourTime = true; # 24 Hour Clock

        AppleInterfaceStyle = "Dark"; # Dark Mode

        AppleScrollerPagingBehavior = true; # Jump to spot on scroll bar

        #Set key repeat to faster
        InitialKeyRepeat = 14;
        KeyRepeat = 2;

        #Disabling "smart" features as they often annoy me
        NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
        NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
        NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
        NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
        NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction
        NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
        NSNavPanelExpandedStateForSaveMode2 = true;

        #Set sidebar icons size.
        NSTableViewDefaultSizeMode = 1;

        "com.apple.sound.beep.feedback" = 0; # Turn off beep when changing volume
        "com.apple.swipescrolldirection" = false; # Change scroll direction to the sane version
        "com.apple.trackpad.scaling" = 2.0; # Set trackpad speed to be 2
      };

      loginwindow = {
        GuestEnabled = false; # disable guest user
        SHOWFULLNAME = true; # show full name in login window
      };

      finder = {
        FXDefaultSearchScope = "SCcf"; # Only search current folder
        FXEnableExtensionChangeWarning = false; # Don't warn on changing extension
        QuitMenuItem = true; # Allow quitting of finder
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true; # show full path in finder title
      };

      dock = {
        autohide = true;
        minimize-to-application = true; # save space in dock
        mru-spaces = false; # don't shuffle spaces
        show-recents = false; # don't show recents

        # Hot corners
        wvous-bl-corner = 14; # Quick note
        wvous-br-corner = 5; # Screen Saver Start (and lock screen)
        wvous-tl-corner = 1; # Desktop
        wvous-tr-corner = 4; # Notification Center
      };

      trackpad = {
        # TrackpadRightClick = true; # enable two finger right click
      };

      screencapture = {
        location = "~/Library/Mobile Documents/com~apple~CloudDocs/Screenshots/";
        type = "png";
        disable-shadow = true;
      };

      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      #
      # Customize settings that not supported by nix-darwin directly
      # Incomplete list of macOS `defaults` commands :
      #   https://github.com/yannbertrand/macos-defaults
      CustomUserPreferences = {
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true; # show mounted HDs on desktop
          ShowHardDrivesOnDesktop = true; # show hard drives on Desktop
          ShowMountedServersOnDesktop = true; # show mounted servers on desktop
          ShowRemovableMediaOnDesktop = true; # Show removeable media on desktop
          _FXSortFoldersFirst = true; # Keep folders at the top
          AppleShowAllExtensions = true; # Show all extensions
          AppleShowAllFiles = true; # Show all Files
          FXPreferredViewStyle = "clmv"; # Set column view as standard
        };

        # Brooklyn is broken on sonoma: https://github.com/pedrommcarrasco/Brooklyn/issues/123
        # "com.apple.screensaver" = {
        #   loginWindowModulePath = "$HOME/Library/Screen Savers/Brooklyn.saver";
        #   moduleName = "Brooklyn";
        # };

        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.spaces" = {
          "spans-displays" = 0; # Display have separate spaces
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;

        # Disable the app quaruntine
        "com.apple.LaunchServices".LSQuarantine = false;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      # dont remap caps here as we can use Karabiner to enable more complex functionality
      # remapCapsLockToControl = true;
      nonUS.remapTilde = true;
    };
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      # nerdfonts
      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg
    ];
  };
}
