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
          left: ["komorebi_workspaces", "komorebi_active_layout", "active_window", "traffic"]
          center: ["clock"]
          right: ["systray", "media", "cpu", "memory", "wifi", "volume", "notifications", "power_menu"]

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

      traffic:
        type: "yasb.traffic.TrafficWidget"
        options:
          label: "\ueab4 {download_speed} \ueab7 {upload_speed}"
          label_alt: "\ueab4 {download_speed} \ueab7 {upload_speed}"
          update_interval: 1000
          interface: "Auto"
          hide_if_offline: false
          speed_unit: "bits"
          hide_decimal: true
          speed_threshold:
            min_upload: 1000
            min_download: 1000
          callbacks:
            on_left: "toggle_menu"
            on_right: "toggle_label"
          menu:
            blur: true
            round_corners: true
            round_corners_type: "normal"
            border_color: "None"
            alignment: "left"
            direction: "down"
            offset_top: 6
            offset_left: 0
            show_interface_name: true
            show_internet_info: true

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
          label: "<span>\uefc5</span> {virtual_mem_outof}"
          label_alt: "<span>\uefc5</span> {virtual_mem_outof}"
          update_interval: 10000
          callbacks:
            on_left: "toggle_label"
            on_right: "exec cmd /c Taskmgr"

      media:
        type: "yasb.media.MediaWidget"
        options:
          label: "{title}"
          label_alt: "{title}{s}{artist}"
          separator: " - "
          max_field_size:
            label: 20
            label_alt: 30
          show_thumbnail: false
          controls_only: false
          controls_left: true
          controls_hide: false
          hide_empty: true
          icons:
            prev_track: "\uf048"
            next_track: "\uf051"
            play: "\uf04b"
            pause: "\uf04c"
          callbacks:
            on_left: "toggle_media_menu"
            on_middle: "toggle_play_pause"
            on_right: "toggle_label"
          media_menu:
            blur: true
            round_corners: true
            round_corners_type: "normal"
            border_color: "None"
            alignment: "right"
            direction: "down"
            offset_top: 6
            offset_left: 0
            thumbnail_corner_radius: 4
            thumbnail_size: 80
            max_title_size: 60
            max_artist_size: 20
            show_source: true
          media_menu_icons:
            play: "\ue768"
            pause: "\ue769"
            prev_track: "\ue892"
            next_track: "\ue893"

      volume:
        type: "yasb.volume.VolumeWidget"
        options:
          label: "<span>{icon}</span> {level}"
          label_alt: "{volume}"
          scroll_step: 2
          tooltip: true
          volume_icons:
            - "\ueee8"
            - "\uf026"
            - "\uf027"
            - "\uf027"
            - "\uf028"
          audio_menu:
            blur: true
            round_corners: true
            round_corners_type: "normal"
            border_color: "None"
            alignment: "right"
            direction: "down"
            offset_top: 6
            offset_left: 0
            show_apps: true
            show_app_labels: false
            show_app_icons: true
            show_apps_expanded: false
            app_icons:
              toggle_down: "\uf078"
              toggle_up: "\uf077"
          callbacks:
            on_left: "toggle_volume_menu"
            on_middle: "do_nothing"
            on_right: "toggle_mute"

      systray:
        type: "yasb.systray.SystrayWidget"
        options:
          class_name: "systray"
          label_collapsed: "\uf47d"
          label_expanded: "\uf460"
          label_position: "right"
          icon_size: 16
          pin_click_modifier: "alt"
          show_unpinned: false
          show_unpinned_button: true
          show_battery: false
          show_volume: false
          show_network: false
          tooltip: true

      wifi:
        type: "yasb.wifi.WifiWidget"
        options:
          label: "<span>{wifi_icon}</span>"
          label_alt: "<span>{wifi_icon}</span> {wifi_name}"
          update_interval: 5000
          callbacks:
            on_left: "toggle_label"
            on_middle: "do_nothing"
            on_right: "exec cmd /c ncpa.cpl"
          wifi_icons:
            - "\uf92b"
            - "\uf91f"
            - "\uf922"
            - "\uf925"
            - "\uf928"
          ethernet_icon: "\uf0e8"

      notifications:
        type: "yasb.notifications.NotificationsWidget"
        options:
          label: "<span>\uf476</span> {count}"
          label_alt: "{count} notifications"
          hide_empty: true
          tooltip: false
          callbacks:
            on_left: "toggle_notification"
            on_right: "do_nothing"
            on_middle: "toggle_label"

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
      --base: rgba(30, 30, 46, 0.8);
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
      background-color: var(--base);
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
      color: var(--text);
      padding: 0 6px;
      cursor: pointer;
    }

    .komorebi-workspaces .ws-btn.active.button-1,
    .komorebi-workspaces .ws-btn.populated.button-1 { color: var(--red); font-weight: 900; }
    .komorebi-workspaces .ws-btn.active.button-2,
    .komorebi-workspaces .ws-btn.populated.button-2 { color: var(--peach); font-weight: 900; }
    .komorebi-workspaces .ws-btn.active.button-3,
    .komorebi-workspaces .ws-btn.populated.button-3 { color: var(--yellow); font-weight: 900; }
    .komorebi-workspaces .ws-btn.active.button-4,
    .komorebi-workspaces .ws-btn.populated.button-4 { color: var(--green); font-weight: 900; }
    .komorebi-workspaces .ws-btn.active.button-5,
    .komorebi-workspaces .ws-btn.populated.button-5 { color: var(--teal); font-weight: 900; }
    .komorebi-workspaces .ws-btn.active.button-6,
    .komorebi-workspaces .ws-btn.populated.button-6 { color: var(--sapphire); font-weight: 900; }
    .komorebi-workspaces .ws-btn.active.button-7,
    .komorebi-workspaces .ws-btn.populated.button-7 { color: var(--blue); font-weight: 900; }
    .komorebi-workspaces .ws-btn.active.button-8,
    .komorebi-workspaces .ws-btn.populated.button-8 { color: var(--mauve); font-weight: 900; }

    /* Traffic */
    .traffic-widget {
      color: var(--sky);
    }

    .traffic-widget .widget-container {
      color: var(--sky);
    }

    .traffic-widget .label {
      color: var(--sky);
    }

    .traffic-widget .icon {
      color: var(--sky);
    }

    .traffic-menu {
      background-color: var(--crust);
      min-width: 280px;
    }

    .traffic-menu .header {
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
      background-color: var(--crust);
    }

    .traffic-menu .header .title {
      padding: 8px;
      font-size: 16px;
      font-weight: 600;
      font-family: 'Segoe UI';
      color: var(--text);
    }

    .traffic-menu .header .reset-button {
      font-size: 11px;
      padding: 4px 8px;
      margin-right: 8px;
      font-family: 'Segoe UI';
      border-radius: 4px;
      font-weight: 600;
      background-color: transparent;
      border: none;
    }

    .traffic-menu .reset-button:hover {
      color: var(--text);
      background-color: rgba(255, 255, 255, 0.05);
      border: 1px solid rgba(255, 255, 255, 0.1);
    }

    .traffic-menu .reset-button:pressed {
      color: var(--text);
      background-color: rgba(255, 255, 255, 0.1);
      border: 1px solid rgba(255, 255, 255, 0.2);
    }

    .traffic-menu .download-speed,
    .traffic-menu .upload-speed {
      background-color: transparent;
      padding: 4px 10px;
      margin-right: 12px;
      margin-left: 12px;
      margin-top: 16px;
      margin-bottom: 0;
      border-bottom: 1px solid rgba(255, 255, 255, 0.2);
    }

    .traffic-menu .speed-separator {
      max-width: 1px;
      background-color: rgba(255, 255, 255, 0.2);
      margin: 32px 0 16px 0;
    }

    .traffic-menu .upload-speed-value,
    .traffic-menu .download-speed-value {
      font-size: 24px;
      font-weight: 900;
      font-family: 'Segoe UI';
      color: var(--subtext1);
    }

    .traffic-menu .upload-speed-unit,
    .traffic-menu .download-speed-unit {
      font-size: 13px;
      font-family: 'Segoe UI';
      font-weight: 600;
      padding-top: 4px;
    }

    .traffic-menu .upload-speed-placeholder,
    .traffic-menu .download-speed-placeholder {
      color: var(--overlay0);
      font-size: 11px;
      font-family: 'Segoe UI';
      padding: 0 0 4px 0;
    }

    .traffic-menu .section-title {
      font-size: 12px;
      font-weight: 600;
      color: var(--overlay1);
      margin-bottom: 4px;
      font-family: 'Segoe UI';
    }

    .traffic-menu .session-section,
    .traffic-menu .today-section,
    .traffic-menu .alltime-section {
      margin: 8px 8px 0 8px;
      padding: 0 10px 10px 10px;
      background-color: transparent;
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }

    .traffic-menu .data-text {
      font-size: 13px;
      color: var(--subtext0);
      padding: 2px 0;
      font-family: 'Segoe UI';
    }

    .traffic-menu .data-value {
      font-weight: 600;
      font-size: 13px;
      font-family: 'Segoe UI';
      padding: 2px 0;
    }

    .traffic-menu .interface-info,
    .traffic-menu .internet-info {
      font-size: 12px;
      color: var(--overlay0);
      padding: 8px 0;
      font-family: 'Segoe UI';
    }

    .traffic-menu .internet-info {
      background-color: rgba(68, 68, 68, 0.1);
    }

    .traffic-menu .internet-info.connected {
      background-color: rgba(166, 227, 161, 0.096);
      color: var(--green);
    }

    .traffic-menu .internet-info.disconnected {
      background-color: rgba(243, 139, 168, 0.1);
      color: var(--red);
    }

    /* Volume */
    .volume-widget .icon {
      color: var(--blue);
      margin: 1px 2px 0 0;
    }

    .audio-menu {
      background-color: var(--crust);
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

    .audio-menu .toggle-apps {
      background-color: transparent;
      border: none;
      color: var(--overlay1);
      padding: 4px 8px;
      border-radius: 4px;
    }

    .audio-menu .toggle-apps:hover {
      background-color: rgba(255, 255, 255, 0.06);
    }

    .audio-menu .apps-container .app {
      background-color: transparent;
      padding: 4px 8px;
      margin: 2px 0;
      border-radius: 4px;
    }

    .audio-menu .apps-container .app:hover {
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
      background-color: transparent;
      border: none;
      font-size: 12px;
      padding: 0 4px;
      margin: 0 2px;
    }

    .media-widget .btn:hover {
      color: var(--text);
    }

    .media-widget .label {
      color: var(--green);
    }

    /* Media menu */
    .media-menu {
      min-width: 360px;
      max-width: 360px;
      background-color: var(--crust);
    }

    .media-menu .title,
    .media-menu .artist,
    .media-menu .source {
      font-size: 14px;
      font-weight: 600;
      margin-left: 10px;
      font-family: 'Segoe UI';
    }

    .media-menu .artist {
      font-size: 13px;
      color: var(--overlay0);
      margin-top: 0;
      margin-bottom: 8px;
    }

    .media-menu .source {
      font-size: 11px;
      color: var(--crust);
      font-weight: normal;
      border-radius: 3px;
      background-color: var(--subtext1);
      padding: 2px 4px;
    }

    .media-menu .btn {
      font-family: "Segoe Fluent Icons";
      font-size: 14px;
      font-weight: 400;
      margin: 10px 2px 0 2px;
      min-width: 40px;
      max-width: 40px;
      min-height: 40px;
      max-height: 40px;
      border-radius: 20px;
    }

    .media-menu .btn:hover {
      color: white;
      background-color: rgba(255, 255, 255, 0.1);
    }

    .media-menu .btn.play {
      background-color: rgba(255, 255, 255, 0.1);
      font-size: 20px;
    }

    .media-menu .btn.disabled:hover,
    .media-menu .btn.disabled {
      color: var(--surface2);
      background-color: transparent;
    }

    .media-menu .playback-time {
      font-size: 13px;
      font-family: 'Segoe UI';
      color: var(--overlay1);
      margin-top: 0;
      min-width: 100px;
    }

    .media-menu .progress-slider {
      height: 20px;
      margin: 0 4px 5px 4px;
      border-radius: 3px;
    }

    .media-menu .progress-slider::groove {
      background: rgba(255, 255, 255, 0.1);
      height: 2px;
      border-radius: 3px;
    }

    .media-menu .progress-slider::groove:hover {
      background: rgba(255, 255, 255, 0.2);
      height: 6px;
      border-radius: 3px;
    }

    .media-menu .progress-slider::sub-page {
      background: var(--blue);
      border-radius: 3px;
      height: 4px;
    }

    /* System tray */
    .systray {
      background: transparent;
      border: none;
      margin: 0;
      padding: 0;
    }

    .systray .button {
      border-radius: 4px;
      padding: 2px 2px;
      background-color: transparent;
    }

    .systray .button:hover,
    .systray .unpinned-visibility-btn:hover {
      background: rgba(255, 255, 255, 0.1);
    }

    .systray .unpinned-visibility-btn {
      height: 20px;
      width: 16px;
      background-color: transparent;
      border: none;
      font-size: 14px;
    }

    .systray .unpinned-visibility-btn:hover {
      border-radius: 4px;
    }

    /* Wifi */
    .wifi-widget .icon {
      color: var(--sky);
    }

    /* Notifications */
    .notification-widget .icon {
      color: var(--overlay1);
    }

    .notification-widget .icon.new-notification {
      color: var(--blue);
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
