# PowerShell 7 profile and oh-my-posh theme
# Generates the PS profile that sets KOMOREBI_CONFIG_HOME and loads oh-my-posh,
# plus a Catppuccin Mocha theme that replicates the Starship 3-line prompt.
{ pkgs, ... }:
let
  # Oh-my-posh theme replicating the Starship layout:
  # Line 1: user@host, cmd_duration — right: shell name
  # Line 2: path, git branch+status — right: time
  # Line 3: prompt character (› green / ~› red)
  ompTheme = {
    "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
    version = 2;
    final_space = true;
    console_title_template = "{{ .Folder }}";

    palette = {
      rosewater = "#f5e0dc";
      flamingo = "#f2cdcd";
      pink = "#f5c2e7";
      mauve = "#cba6f7";
      red = "#f38ba8";
      maroon = "#eba0ac";
      peach = "#fab387";
      yellow = "#f9e2af";
      green = "#a6e3a1";
      teal = "#94e2d5";
      sky = "#89dceb";
      sapphire = "#74c7ec";
      blue = "#89b4fa";
      lavender = "#b4befe";
      text = "#cdd6f4";
      subtext1 = "#bac2de";
      subtext0 = "#a6adc8";
      overlay2 = "#9399b2";
      overlay1 = "#7f849c";
      overlay0 = "#6c7086";
      surface2 = "#585b70";
      surface1 = "#45475a";
      surface0 = "#313244";
      base = "#1e1e2e";
      mantle = "#181825";
      crust = "#11111b";
    };

    blocks = [
      # ── Line 1 ──────────────────────────────────────────
      {
        type = "prompt";
        alignment = "left";
        segments = [
          {
            type = "session";
            style = "plain";
            foreground = "p:yellow";
            template = "{{ .UserName }}";
          }
          {
            type = "session";
            style = "plain";
            foreground = "p:green";
            template = "@{{ .HostName }} ";
          }
          {
            type = "executiontime";
            style = "plain";
            foreground = "p:yellow";
            template = "took {{ .FormattedMs }} ";
            properties = {
              threshold = 0;
              style = "austin";
            };
          }
        ];
      }
      {
        type = "prompt";
        alignment = "right";
        segments = [
          {
            type = "shell";
            style = "plain";
            foreground = "p:overlay1";
            template = "{{ .Name }}";
          }
        ];
      }
      # ── Line 2 ──────────────────────────────────────────
      {
        type = "prompt";
        alignment = "left";
        newline = true;
        segments = [
          {
            type = "path";
            style = "plain";
            foreground = "p:sapphire";
            template = "{{ .Path }} ";
            properties = {
              style = "full";
            };
          }
          {
            type = "git";
            style = "plain";
            foreground = "p:lavender";
            template = " {{ .HEAD }}{{ if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }} ";
            properties = {
              branch_icon = " ";
              commit_icon = " ";
              tag_icon = " ";
              cherry_pick_icon = " ";
              rebase_icon = " ";
              merge_icon = " ";
              fetch_status = true;
              fetch_upstream_icon = true;
            };
          }
        ];
      }
      {
        type = "prompt";
        alignment = "right";
        segments = [
          {
            type = "time";
            style = "plain";
            foreground = "p:subtext0";
            template = "[{{ .CurrentDate | date .Format }}]";
            properties = {
              time_format = "15:04:05";
            };
          }
        ];
      }
      # ── Line 3 ──────────────────────────────────────────
      {
        type = "prompt";
        alignment = "left";
        newline = true;
        segments = [
          {
            type = "text";
            style = "plain";
            foreground_templates = [
              "{{ if gt .Code 0 }}p:red{{ end }}"
            ];
            foreground = "p:green";
            template = "{{ if gt .Code 0 }}~›{{ else }}›{{ end }} ";
          }
        ];
      }
    ];
  };

  profileContent = ''
    # Managed by Nix — do not edit manually
    # Set KOMOREBI_CONFIG_HOME so komorebi finds its Nix-managed config
    $Env:KOMOREBI_CONFIG_HOME = "$Env:USERPROFILE\.config\komorebi"

    # Ensure oh-my-posh is on PATH (winget installs here)
    $ompBin = "$Env:LOCALAPPDATA\Programs\oh-my-posh\bin"
    if ((Test-Path $ompBin) -and ($Env:PATH -notlike "*$ompBin*")) {
        $Env:PATH = "$ompBin;$Env:PATH"
    }

    # Initialize oh-my-posh with Catppuccin Mocha theme
    $ompTheme = "$Env:USERPROFILE\Documents\PowerShell\catppuccin-mocha.omp.json"
    if (Test-Path $ompTheme) {
        oh-my-posh init pwsh --config $ompTheme | Invoke-Expression
    }
  '';
in
{
  windows.configFiles = {
    "Documents/PowerShell/Microsoft.PowerShell_profile.ps1" =
      pkgs.writeText "Microsoft.PowerShell_profile.ps1" profileContent;
    "Documents/PowerShell/catppuccin-mocha.omp.json" = pkgs.writeText "catppuccin-mocha.omp.json" (
      builtins.toJSON ompTheme
    );
  };
}
