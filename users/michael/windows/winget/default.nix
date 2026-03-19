# Winget package manifest
# Generates a winget import JSON at .config/winget/packages.json.
# Apply manually: winget import -i %USERPROFILE%\.config\winget\packages.json
{ pkgs, ... }:
let
  packages = [
    # Shell & prompt
    "Microsoft.PowerShell"
    "JanDeDobbeleer.OhMyPosh"

    # Window management
    "LGUG2Z.komorebi"
    "LGUG2Z.whkd"
    "AmN.yasb"

    # Terminal
    "Microsoft.WindowsTerminal"

    # Security
    "AgileBits.1Password"
    "AgileBits.1Password.CLI"

    # Communication
    "Discord.Discord"
    "WhatsApp.WhatsApp"

    # Browser
    "Mozilla.Firefox"

    # Media
    "Spotify.Spotify"

    # Development
    "Microsoft.VisualStudioCode"
    "Git.Git"
  ];

  wingetManifest = {
    "$schema" = "https://aka.ms/winget-packages.schema.2.0.json";
    CreationDate = "2025-01-01";
    Sources = [
      {
        Packages = map (id: { PackageIdentifier = id; }) packages;
        SourceDetails = {
          Argument = "https://cdn.winget.microsoft.com/cache";
          Identifier = "Microsoft.Winget.Source_8wekyb3d8bbwe";
          Name = "winget";
          Type = "Microsoft.PreIndexed.Package";
        };
      }
    ];
  };
in
{
  windows.configFiles.".config/winget/packages.json" = pkgs.writeText "winget-packages.json" (
    builtins.toJSON wingetManifest
  );
}
