# YASB (Yet Another Status Bar) configuration
# Generates config.yaml and styles.css with Catppuccin Mocha theming
# and komorebi workspace/layout widgets.
#
# Theme based on: https://github.com/amnweb/yasb-themes/tree/main/themes/68dd7099-3fea-45a7-9882-6d59bb05431c
#
# No isWSL guard needed — parent aggregator handles it.
#
# Windows-side prerequisite: YASB must be installed.
# Config location: %USERPROFILE%\.config\yasb\
{ pkgs, ... }:
let
  configYaml = ''
    watch_stylesheet: true
    watch_config: true
    debug: false
    update_check: false

    komorebi:
      start_command: "komorebic start --whkd"
      stop_command: "komorebic stop --whkd"
      reload_command: "komorebic stop --whkd && komorebic start --whkd"

    bars:
      status-bar:
        enabled: true
        screens: ["*"]
        class_name: "yasb-bar"
        alignment:
          position: "top"
          center: true
        blur_effect:
          enabled: true
          acrylic: false
          dark_mode: true
          round_corners: true
          round_corners_type: "normal"
          border_color: None
        window_flags:
          always_on_top: false
          windows_app_bar: true
        dimensions:
          width: "100%"
          height: 32
        padding:
          top: 4
          left: 4
          bottom: 4
          right: 4
        animation:
          enabled: true
          duration: 400
        widgets:
          left: ["komorebi_workspaces", "komorebi_active_layout", "active_window"]
          center: ["clock"]
          right: ["media", "cpu", "memory", "volume", "power_menu"]

    widgets:
      komorebi_workspaces:
        type: "komorebi.workspaces.WorkspaceWidget"
        options:
          label_offline: "\u23fc Offline"
          label_workspace_btn: "\udb80\udd30"
          label_workspace_active_btn: "\udb80\udd2f"
          label_workspace_populated_btn: "\udb80\udd30"
          label_default_name: "{index}"
          label_zero_index: false
          hide_empty_workspaces: false
          hide_if_offline: true
          animation: false

      komorebi_active_layout:
        type: "komorebi.active_layout.ActiveLayoutWidget"
        options:
          hide_if_offline: true
          label: "{icon}"
          layouts:
            - "bsp"
            - "columns"
            - "rows"
            - "grid"
            - "vertical_stack"
            - "horizontal_stack"
          layout_icons:
            bsp: "BSP"
            columns: "COLS"
            rows: "ROWS"
            grid: "GRID"
            vertical_stack: "V-STK"
            horizontal_stack: "H-STK"
            monocle: "MONO"
            maximized: "MAX"
            floating: "FLOAT"
            paused: "PAUSE"
          callbacks:
            on_left: "next_layout"
            on_middle: "toggle_monocle"
            on_right: "prev_layout"

      active_window:
        type: "yasb.active_window.ActiveWindowWidget"
        options:
          label: "{win[title]}"
          label_alt: "[class_name='{win[class_name]}' exe='{win[process][name]}' hwnd={win[hwnd]}]"
          label_no_window: ""
          label_icon: true
          label_icon_size: 14
          max_length: 50
          max_length_ellipsis: "..."
          monitor_exclusive: true

      clock:
        type: "yasb.clock.ClockWidget"
        options:
          label: "<span>\uf017</span>{%H:%M}"
          label_alt: "<span>\uf017</span>{%A, %B %d %Y  %H:%M}"
          timezones: []
          calendar:
            round_corners: true
            round_corners_type: "small"
            border_color: "#89b4fa"
            alignment: "center"
            offset_top: 0
          callbacks:
            on_left: "toggle_calendar"
            on_right: "toggle_label"

      cpu:
        type: "yasb.cpu.CpuWidget"
        options:
          label: "<span>\uf4bc</span> {info[percent][total]}%"
          label_alt: "<span>\uf4bc</span> {info[histograms][cpu_percent]}"
          update_interval: 2000
          callbacks:
            on_left: "toggle_label"
            on_right: "exec cmd /c Taskmgr"

      memory:
        type: "yasb.memory.MemoryWidget"
        options:
          label: "<span>\uf4bc</span> {virtual_mem_outof}"
          label_alt: "<span>\uf4bc</span> {virtual_mem_outof}"
          update_interval: 10000
          callbacks:
            on_left: "toggle_label"
            on_right: "exec cmd /c Taskmgr"

      media:
        type: "yasb.media.MediaWidget"
        options:
          label: "{title}"
          label_alt: "{artist} - {title}"
          max_field_size:
            label: 20
            label_alt: 30
          show_thumbnail: false
          controls_only: false
          controls_left: true
          controls_hide: true
          hide_empty: true
          icons:
            prev_track: "\uf048"
            next_track: "\uf051"
            play: "\uf04b"
            pause: "\uf04c"
          callbacks:
            on_left: "play_pause"
            on_middle: "do_nothing"
            on_right: "toggle_label"

      volume:
        type: "yasb.volume.VolumeWidget"
        options:
          label: "<span>{icon}</span> {level}"
          label_alt: "{volume}"
          volume_icons:
            - "\ueee8"
            - "\uf026"
            - "\uf027"
            - "\uf027"
            - "\uf028"
          audio_menu:
            blur: true
            round_corners: true
            round_corners_type: "small"
            border_color: "#89b4fa"
            alignment: "center"
            direction: "down"
            offset_top: 0
          callbacks:
            on_left: "toggle_mute"
            on_right: "toggle_label"

      power_menu:
        type: "yasb.power_menu.PowerMenuWidget"
        options:
          label: "\uf011"
          uptime: true
          blur: false
          blur_background: true
          animation_duration: 200
          button_row: 5
          buttons:
            shutdown: ["\uf011", "Shut Down"]
            restart: ["\uead2", "Restart"]
            signout: ["\udb80\udf43", "Sign out"]
            hibernate: ["\uf28e", "Hibernate"]
            sleep: ["\u23fe", "Sleep"]
            cancel: ["", "Cancel"]
  '';

  # Catppuccin Mocha theme from yasb-themes (68dd7099)
  # Uses CSS variables for the full palette
  stylesCss = ''
    :root {
      --rosewater: #f5e0dc;
      --flamingo: #f2cdcd;
      --pink: #f5c2e7;
      --mauve: #cba6f7;
      --red: #f38ba8;
      --maroon: #eba0ac;
      --peach: #fab387;
      --yellow: #f9e2af;
      --green: #a6e3a1;
      --teal: #94e2d5;
      --sky: #89dceb;
      --sapphire: #74c7ec;
      --blue: #89b4fa;
      --lavender: #b4befe;
      --text: #cdd6f4;
      --subtext1: #bac2de;
      --subtext0: #a6adc8;
      --overlay2: #9399b2;
      --overlay1: #7f849c;
      --overlay0: #6c7086;
      --surface2: #585b70;
      --surface1: #45475a;
      --surface0: #313244;
      --base: #1e1e2e;
      --mantle: rgba(24, 24, 37, 0.8);
      --crust: rgba(17, 17, 27, 0.8);
    }

    * {
      font-size: 12px;
      color: var(--subtext0);
      font-weight: 700;
      font-family: "JetBrainsMono NFP";
      margin: 0;
      padding: 0;
    }

    .yasb-bar {
      padding: 0;
      margin: 0;
      background-color: var(--crust);
    }

    .widget {
      padding: 0 8px;
      margin: 0 2px;
    }

    .widget .label {
      padding: 0 2px;
    }

    .icon {
      font-size: 16px;
      margin: 0 4px 0 0;
    }

    /* Clock */
    .clock-widget {
      background-color: var(--crust);
      margin: 4px 0;
      border-radius: 12px;
      border: 0;
    }

    .clock-widget .icon {
      font-size: 14px;
      color: var(--sky);
    }

    .clock-widget .label {
      font-size: 14px;
      font-weight: 700;
      color: var(--subtext0);
    }

    .calendar {
      background-color: var(--mantle);
    }

    .calendar .calendar-table,
    .calendar .calendar-table::item {
      background-color: transparent;
      color: rgba(162, 177, 196, 0.85);
      margin: 0;
      padding: 0;
      border: none;
      outline: none;
    }

    .calendar .calendar-table::item:selected {
      color: var(--crust);
      background-color: var(--lavender);
      border-radius: 5px;
    }

    .calendar .day-label {
      margin-top: 20px;
    }

    .calendar .day-label,
    .calendar .month-label,
    .calendar .date-label {
      font-size: 16px;
      color: var(--lavender);
      font-weight: 700;
      min-width: 180px;
      max-width: 180px;
    }

    .calendar .month-label {
      font-weight: normal;
    }

    .calendar .date-label {
      font-size: 88px;
      font-weight: 900;
      color: rgb(255, 255, 255);
      margin-top: -20px;
    }

    /* Komorebi workspaces */
    .komorebi-workspaces {
      background-color: var(--crust);
      margin: 4px 0;
      border-radius: 12px;
      border: 0;
    }

    .komorebi-workspaces .ws-btn {
      font-size: 14px;
      border: none;
      color: var(--overlay0);
      padding: 0 6px;
      cursor: pointer;
    }

    .komorebi-workspaces .ws-btn.active {
      color: var(--red);
      font-weight: 900;
    }

    .komorebi-workspaces .ws-btn.populated {
      color: var(--blue);
      font-weight: 900;
    }

    /* Volume */
    .volume-widget .icon {
      color: var(--blue);
      margin: 1px 2px 0 0;
    }

    .audio-menu {
      background-color: var(--mantle);
    }

    .audio-container .device {
      background-color: transparent;
      border: none;
      padding: 6px 8px 6px 4px;
      margin: 2px 0;
      font-size: 12px;
      border-radius: 4px;
    }

    .audio-container .device.selected {
      background-color: rgba(255, 255, 255, 0.085);
    }

    .audio-container .device:hover {
      background-color: rgba(255, 255, 255, 0.06);
    }

    /* Memory */
    .memory-widget .icon {
      color: var(--mauve);
    }

    /* CPU */
    .cpu-widget .icon {
      color: var(--red);
    }

    /* Media */
    .media-widget {
      color: var(--green);
    }

    .media-widget .btn {
      color: var(--green);
    }

    /* Power menu */
    .power-menu-widget .label {
      color: var(--red);
      font-size: 13px;
    }

    .power-menu-popup {
      background-color: transparent;
    }

    .power-menu-popup .button {
      padding: 0;
      width: 180px;
      height: 230px;
      border-radius: 8px;
      background-color: var(--base);
      border: 8px solid rgba(58, 59, 83, 0);
      margin: 0;
    }

    .power-menu-popup .button.hover {
      background-color: var(--surface0);
      border: 8px solid var(--surface0);
    }

    .power-menu-popup .button .label {
      margin-bottom: 8px;
      font-size: 16px;
      font-weight: 500;
      color: var(--lavender);
    }

    .power-menu-popup .button .icon {
      font-size: 64px;
      padding-top: 32px;
      color: var(--lavender);
    }

    .power-menu-popup .button.cancel {
      height: 32px;
      border-radius: 4px;
    }

    .power-menu-popup .button.cancel .icon {
      padding: 0;
      margin: 0;
    }

    .power-menu-popup .button.cancel .label {
      color: var(--red);
      margin: 0;
    }

    /* Uptime in power menu */
    .uptime {
      font-size: 14px;
      margin-bottom: 10px;
      color: var(--surface2);
      font-weight: 600;
    }
  '';
in
{
  windows.configFiles."yasb/config.yaml" = pkgs.writeText "yasb-config.yaml" configYaml;
  windows.configFiles."yasb/styles.css" = pkgs.writeText "yasb-styles.css" stylesCss;
}
