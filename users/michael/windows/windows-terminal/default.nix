# Windows Terminal settings.json
# Full declarative config with Catppuccin Mocha colors, JetBrainsMono Nerd Font,
# and profiles for PowerShell 7, Windows PowerShell, and WSL.
{ pkgs, ... }:
let
  terminalSettings = {
    "$help" = "https://aka.ms/terminal-documentation";
    "$schema" = "https://aka.ms/terminal-profiles-schema";

    defaultProfile = "{574e775e-4f2a-5b96-ac1e-a2962a402336}"; # PowerShell 7

    # Catppuccin Mocha color scheme
    schemes = [
      {
        name = "Catppuccin Mocha";
        background = "#1E1E2E";
        foreground = "#CDD6F4";
        cursorColor = "#F5E0DC";
        selectionBackground = "#585B70";
        black = "#45475A";
        red = "#F38BA8";
        green = "#A6E3A1";
        yellow = "#F9E2AF";
        blue = "#89B4FA";
        purple = "#F5C2E7";
        cyan = "#94E2D5";
        white = "#BAC2DE";
        brightBlack = "#585B70";
        brightRed = "#F38BA8";
        brightGreen = "#A6E3A1";
        brightYellow = "#F9E2AF";
        brightBlue = "#89B4FA";
        brightPurple = "#F5C2E7";
        brightCyan = "#94E2D5";
        brightWhite = "#A6ADC8";
      }
    ];

    profiles = {
      defaults = {
        colorScheme = "Catppuccin Mocha";
        font = {
          face = "JetBrainsMono Nerd Font";
          size = 11;
        };
        opacity = 90;
        useAcrylic = true;
        padding = "8";
        cursorShape = "bar";
        scrollbarState = "hidden";
      };

      list = [
        {
          name = "PowerShell";
          guid = "{574e775e-4f2a-5b96-ac1e-a2962a402336}";
          source = "Windows.Terminal.PowershellCore";
          commandline = "pwsh.exe -NoLogo";
          icon = "ms-appx:///ProfileIcons/pwsh.png";
          startingDirectory = "%USERPROFILE%";
        }
        {
          name = "Windows PowerShell";
          guid = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}";
          commandline = "powershell.exe -NoLogo";
          hidden = false;
        }
        {
          name = "WSL";
          guid = "{2c4de342-38b7-51cf-b940-2309a097f518}";
          source = "Windows.Terminal.Wsl";
        }
      ];
    };

    theme = "dark";
    copyOnSelect = false;
    copyFormatting = false;
    trimBlockSelection = true;

    actions = [
      {
        command = {
          action = "copy";
          singleLine = false;
        };
        keys = "ctrl+c";
      }
      {
        command = "paste";
        keys = "ctrl+v";
      }
      {
        command = "find";
        keys = "ctrl+shift+f";
      }
      {
        command = {
          action = "splitPane";
          split = "auto";
          splitMode = "duplicate";
        };
        keys = "alt+shift+d";
      }
      {
        command = {
          action = "newTab";
        };
        keys = "ctrl+shift+t";
      }
      {
        command = "closePane";
        keys = "ctrl+shift+w";
      }
      {
        command = {
          action = "nextTab";
        };
        keys = "ctrl+tab";
      }
      {
        command = {
          action = "prevTab";
        };
        keys = "ctrl+shift+tab";
      }
      {
        command = {
          action = "adjustFontSize";
          delta = 1;
        };
        keys = "ctrl+=";
      }
      {
        command = {
          action = "adjustFontSize";
          delta = -1;
        };
        keys = "ctrl+-";
      }
      {
        command = "resetFontSize";
        keys = "ctrl+0";
      }
      {
        command = "toggleFullscreen";
        keys = "alt+enter";
      }
    ];
  };
in
{
  windows.configFiles."AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" =
    pkgs.writeText "windows-terminal-settings.json" (builtins.toJSON terminalSettings);
}
