# Waybar status bar configuration
{
  lib,
  pkgs,
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
          "group/hardware"
          "network"
          "pulseaudio"
          "clock"
        ];

        "group/left" = {
          orientation = "horizontal";
          modules = [
            "custom/notification"
            "tray"
          ];
        };

        "group/hardware" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 300;
            transition-left-to-right = false;
          };
          modules = [
            "cpu"
            "memory"
            "custom/temps"
            "custom/fans"
          ];
        };

        "custom/temps" = {
          exec = builtins.toString (
            pkgs.writeShellScript "waybar-temps" ''
              # Find coretemp for CPU
              CORETEMP=$(grep -l "^coretemp$" /sys/class/hwmon/*/name 2>/dev/null | head -1 | xargs dirname)
              OCTO=$(grep -l "^octo$" /sys/class/hwmon/*/name 2>/dev/null | head -1 | xargs dirname)

              cpu=$(($(cat "$CORETEMP/temp1_input" 2>/dev/null) / 1000))
              gpu=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | tr -d ' ' || echo "N/A")

              # NVMe temps
              nvme1=""
              nvme2=""
              for h in /sys/class/hwmon/hwmon*; do
                if [ "$(cat "$h/name" 2>/dev/null)" = "nvme" ]; then
                  temp=$(($(cat "$h/temp1_input" 2>/dev/null) / 1000))
                  if [ -z "$nvme1" ]; then nvme1=$temp; else nvme2=$temp; fi
                fi
              done

              # PCH temp
              PCH=$(grep -l "^pch_cannonlake$" /sys/class/hwmon/*/name 2>/dev/null | head -1 | xargs dirname)
              pch=$(($(cat "$PCH/temp1_input" 2>/dev/null) / 1000))

              # Octo temps
              water=$(($(cat "$OCTO/temp1_input" 2>/dev/null) / 1000))
              air=$(($(cat "$OCTO/temp2_input" 2>/dev/null) / 1000))

              tooltip=$(printf "%-12s %3d°C" "CPU Package" "$cpu")
              tooltip="$tooltip\n$(printf "%-12s %3d°C" "GPU (3090)" "$gpu")"
              tooltip="$tooltip\n$(printf "%-12s %3d°C" "NVMe #1" "$nvme1")"
              tooltip="$tooltip\n$(printf "%-12s %3d°C" "NVMe #2" "$nvme2")"
              tooltip="$tooltip\n$(printf "%-12s %3d°C" "PCH" "$pch")"
              tooltip="$tooltip\n$(printf "%-12s %3d°C" "Water Loop" "$water")"
              tooltip="$tooltip\n$(printf "%-12s %3d°C" "Ambient" "$air")"

              echo "{\"text\": \"󰔏 ''${cpu}°C\", \"tooltip\": \"$tooltip\"}"
            ''
          );
          return-type = "json";
          interval = 5;
        };

        "custom/fans" = {
          exec = builtins.toString (
            pkgs.writeShellScript "waybar-fans" ''
              OCTO=$(grep -l "^octo$" /sys/class/hwmon/*/name 2>/dev/null | head -1 | xargs dirname)

              pump=$(cat "$OCTO/fan1_input" 2>/dev/null)

              tooltip=$(printf "%-8s %5d rpm" "Pump" "$pump")
              for i in 2 3 4 5 6 7 8; do
                rpm=$(cat "$OCTO/fan''${i}_input" 2>/dev/null)
                if [ "$rpm" -gt 0 ] 2>/dev/null; then
                  tooltip="$tooltip\n$(printf "%-8s %5d rpm" "Fan $i" "$rpm")"
                fi
              done

              echo "{\"text\": \"󰈐 ''${pump} rpm\", \"tooltip\": \"$tooltip\"}"
            ''
          );
          return-type = "json";
          interval = 5;
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
