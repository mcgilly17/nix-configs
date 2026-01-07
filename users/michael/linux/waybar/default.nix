# Waybar status bar configuration
{
  lib,
  osConfig,
  ...
}:
# Only enable if Hyprland is enabled at the system level
lib.mkIf (osConfig.programs.hyprland.enable or false) {
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 4;
        margin-top = 6;
        margin-left = 10;
        margin-right = 10;

        modules-left = [
          "group/left"
          "mpris"
        ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [
          "cpu"
          "memory"
          "network"
          "pulseaudio"
        ];

        "group/left" = {
          orientation = "horizontal";
          modules = [
            "custom/notification"
            "clock"
            "tray"
          ];
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "1";
            "3" = "2";
            "4" = "2";
            "5" = "3";
            "6" = "3";
            "7" = "4";
            "8" = "4";
            "9" = "5";
            "10" = "5";
          };
          all-outputs = false;
          persistent-workspaces = {
            "DP-3" = [
              1
              3
              5
              7
              9
            ];
            "DP-2" = [
              2
              4
              6
              8
              10
            ];
          };
          on-click = "activate";
        };

        mpris = {
          format = "{player_icon} {artist} - {title}";
          format-paused = "{status_icon} {artist} - {title}";
          format-stopped = "";
          player-icons = {
            default = "▶";
            spotify = "";
            firefox = "󰈹";
          };
          status-icons = {
            paused = "⏸";
          };
          max-length = 40;
          on-click = "playerctl play-pause";
        };

        clock = {
          format = "󰥔 {:%H:%M}";
          format-alt = "󰥔 {:%a %d %b %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          on-click = "gnome-calendar";
          calendar = {
            mode = "month";
            weeks-pos = "right";
            format = {
              months = "<span color='#cba6f7'><b>{}</b></span>";
              days = "<span color='#cdd6f4'>{}</span>";
              weeks = "<span color='#74c7ec'><b>W{}</b></span>";
              weekdays = "<span color='#f9e2af'><b>{}</b></span>";
              today = "<span color='#89b4fa'><b><u>{}</u></b></span>";
            };
          };
        };

        cpu = {
          format = "󰍛 {usage}%";
          interval = 2;
          tooltip = true;
        };

        memory = {
          format = "󰘚 {}%";
          interval = 2;
          tooltip = true;
          tooltip-format = "{used:0.1f}GB / {total:0.1f}GB";
        };

        network = {
          format-wifi = "󰖩 {signalStrength}%";
          format-ethernet = "󰌗 {ipaddr}";
          format-disconnected = "󰌙 ";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname}: {ipaddr}";
          on-click = "nm-connection-editor";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 ";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "pavucontrol";
          tooltip-format = "{desc}";
        };

        "custom/notification" = {
          exec = "swaync-client -swb";
          return-type = "json";
          format = "{icon}";
          format-icons = {
            notification = "󱅫";
            none = "󰂚";
            dnd-notification = "󰂛";
            dnd-none = "󰂛";
          };
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        tray = {
          icon-size = 16;
          spacing = 8;
        };
      };
    };

    style = builtins.readFile ./style.css;
  };
}
