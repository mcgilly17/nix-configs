{ config, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ya/yabai/package.nix
  services.yabai = {
    enable = true;

    # Whether to enable yabai's scripting-addition.
    # SIP must be disabled for this to work.
    # https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection
    enableScriptingAddition = true;
    config = {
      # global settings
      mouse_follows_focus = false;
      focus_follows_mouse = "off";
      window_placement = "second_child";
      window_opacity = "off";
      window_shadow = "on";
      split_ratio = 0.50;
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";

      # general space settings
      layout = "bsp";
      top_padding = 20;
      bottom_padding = 20;
      left_padding = 20;
      right_padding = 20;
      window_gap = 15;
      auto_balance = false;
    };

    extraConfig = builtins.readFile ./yabairc;
  };

  # custom log path for debugging
  launchd.user.agents.yabai.serviceConfig =
    let
      homeDir = config.users.users.michael.home;
    in
    {
      StandardErrorPath = "${homeDir}/Library/Logs/yabai.stderr.log";
      StandardOutPath = "${homeDir}/Library/Logs/yabai.stdout.log";
    };
}
