{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.starship.settings = {
    # Language Symbols
    docker_context.symbol = mkDefault "";
    python.symbol = mkDefault " ";
    package.symbol = mkDefault " ";
    nix_shell.symbol = mkDefault " ";

    # Git Symbols
    git_branch.symbol = mkDefault " ";
    git_commit.tag_symbol = mkDefault " ";
    git_status = {
      format = mkDefault "([$all_status$ahead_behind]($style) )";
      conflicted = mkDefault " ";
      ahead = mkDefault " ";
      behind = mkDefault " ";
      diverged = mkDefault "󰃻 ";
      untracked = mkDefault " ";
      stashed = mkDefault " ";
      modified = mkDefault " ";
      staged = mkDefault " ";
      renamed = mkDefault " ";
      deleted = mkDefault " ";
    };

    # System Symbols
    battery = {
      full_symbol = mkDefault "󰁹";
      charging_symbol = mkDefault "󰂉";
      discharging_symbol = mkDefault "󱟟";
      unknown_symbol = mkDefault "󰂑";
      empty_symbol = mkDefault "󱉞";
    };

    # hyperscaler symbols
    aws.symbol = mkDefault "🅰 ";
    gcloud.symbol = mkDefault " ";
  };
}
