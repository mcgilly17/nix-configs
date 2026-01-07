# Hypridle auto-lock and idle configuration
{
  lib,
  osConfig,
  ...
}:
lib.mkIf (osConfig.programs.hyprland.enable or false) {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        # Dim screen after 2.5 minutes
        {
          timeout = 150;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        # Lock after 5 minutes
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        # Turn off screen after 5.5 minutes
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # Suspend after 30 minutes
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
