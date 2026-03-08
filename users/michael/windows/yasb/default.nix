# YASB (Yet Another Status Bar) configuration
# Generates config.yaml and styles.css with Catppuccin Mocha theming
# and komorebi workspace/layout widgets.
#
# No isWSL guard needed — parent aggregator handles it.
#
# Windows-side prerequisite: YASB must be installed.
# Config location: %USERPROFILE%\.config\yasb\
{ pkgs, ... }:
let
  # Catppuccin Mocha palette
  colors = {
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
    surface0 = "#313244";
    surface1 = "#45475a";
    surface2 = "#585b70";
    overlay0 = "#6c7086";
    text = "#cdd6f4";
    subtext0 = "#a6adc8";
    blue = "#89b4fa"; # Sapphire accent on Linux side
    sapphire = "#74c7ec";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    peach = "#fab387";
    red = "#f38ba8";
    mauve = "#cba6f7";
    teal = "#94e2d5";
    sky = "#89dceb";
  };

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
          center: false
        blur_effect:
          enabled: false
          acrylic: false
          dark_mode: true
          round_corners: false
        window_flags:
          always_on_top: false
          windows_app_bar: true
        dimensions:
          width: "100%"
          height: 32
        padding:
          top: 4
          left: 4
          bottom: 0
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
          label_offline: "Komorebi Offline"
          label_workspace_btn: "{name}"
          label_workspace_active_btn: "{name}"
          label_workspace_populated_btn: "{name}"
          label_default_name: "{index}"
          label_zero_index: false
          hide_empty_workspaces: false
          hide_if_offline: true
          animation: true

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
          label_alt: "[{win[process][name]}]"
          label_no_window: ""
          label_icon: true
          label_icon_size: 14
          max_length: 48
          max_length_ellipsis: "..."
          monitor_exclusive: true

      clock:
        type: "yasb.clock.ClockWidget"
        options:
          label: "{%a %d %b  %H:%M}"
          label_alt: "{%A, %d %B %Y  %H:%M:%S}"
          timezones: []
          callbacks:
            on_left: "toggle_label"
            on_right: "toggle_label"

      cpu:
        type: "yasb.cpu.CpuWidget"
        options:
          label: "CPU {info[percent][total]}%"
          label_alt: "CPU {info[histograms][cpu_percent]}"
          update_interval: 2000
          callbacks:
            on_left: "toggle_label"
            on_right: "do_nothing"

      memory:
        type: "yasb.memory.MemoryWidget"
        options:
          label: "MEM {virtual_mem[percent]}%"
          label_alt: "MEM {virtual_mem[used]} / {virtual_mem[total]}"
          update_interval: 5000
          callbacks:
            on_left: "toggle_label"
            on_right: "do_nothing"

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
          label: "\uf028 {level}"
          label_alt: "Vol {level}%"
          tooltip: false
          volume_icons:
            - "\uf026"
            - "\uf027"
            - "\uf027"
            - "\uf028"
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
          button_row: 3
          buttons:
            lock: ["\uf023", "Lock"]
            shutdown: ["\uf011", "Shut Down"]
            restart: ["\uf021", "Restart"]
            hibernate: ["\uf236", "Hibernate"]
            cancel: ["\uf00d", "Cancel"]
  '';

  # Catppuccin Mocha styles matching the Linux waybar aesthetic
  # Uses same color palette: base #1e1e2e, text #cdd6f4, sapphire accent #89b4fa
  stylesCss = ''
    * {
      font-family: "JetBrainsMono Nerd Font", "Segoe UI", sans-serif;
      font-size: 12px;
      font-weight: 600;
      color: ${colors.text};
    }

    .yasb-bar {
      background-color: ${colors.base};
      border: none;
      border-radius: 0;
    }

    .widget {
      padding: 0 8px;
    }

    .tooltip {
      background-color: ${colors.base};
      border: 1px solid ${colors.blue};
      border-radius: 8px;
      padding: 4px 8px;
      color: ${colors.text};
    }

    /* Komorebi workspaces — colored circles matching waybar */
    .komorebi-workspaces .ws-btn {
      min-width: 24px;
      min-height: 24px;
      border-radius: 12px;
      margin: 2px 3px;
      padding: 0;
      font-weight: bold;
      color: ${colors.base};
      background-color: ${colors.surface1};
    }

    .komorebi-workspaces .ws-btn.populated {
      background-color: ${colors.overlay0};
      color: ${colors.base};
    }

    .komorebi-workspaces .ws-btn.active {
      background-color: ${colors.blue};
      color: ${colors.base};
    }

    /* Per-workspace colors matching waybar nth-child pattern */
    .komorebi-workspaces .ws-btn.button-1 { background-color: ${colors.blue}; }
    .komorebi-workspaces .ws-btn.button-2 { background-color: ${colors.green}; }
    .komorebi-workspaces .ws-btn.button-3 { background-color: ${colors.yellow}; }
    .komorebi-workspaces .ws-btn.button-4 { background-color: ${colors.peach}; }
    .komorebi-workspaces .ws-btn.button-5 { background-color: ${colors.red}; }

    .komorebi-workspaces .ws-btn.active {
      border: 2px solid ${colors.text};
    }

    /* Layout indicator */
    .komorebi-active-layout-widget {
      padding: 0 6px;
      color: ${colors.subtext0};
    }

    /* Active window */
    .active-window-widget {
      padding: 0 8px;
      color: ${colors.subtext0};
    }

    /* Clock — sapphire accent like waybar */
    .clock-widget {
      color: ${colors.blue};
    }

    /* CPU — red like waybar */
    .cpu-widget {
      color: ${colors.red};
    }

    /* Memory — peach like waybar */
    .memory-widget {
      color: ${colors.peach};
    }

    /* Media — green like waybar mpris */
    .media-widget {
      color: ${colors.green};
    }

    .media-widget .btn {
      color: ${colors.green};
      font-size: 12px;
      padding: 0 2px;
    }

    /* Volume — mauve like waybar pulseaudio */
    .volume-widget .icon {
      color: ${colors.mauve};
    }

    .volume-widget .label {
      color: ${colors.mauve};
    }

    /* Power menu */
    .power-menu-widget {
      color: ${colors.red};
      padding: 0 8px;
    }

    .power-menu-popup {
      background-color: ${colors.base};
      border: 1px solid ${colors.surface1};
      border-radius: 8px;
    }

    .power-menu-popup .btn {
      background-color: ${colors.surface0};
      color: ${colors.text};
      border-radius: 8px;
      margin: 4px;
      padding: 8px 12px;
    }

    .power-menu-popup .btn:hover {
      background-color: ${colors.surface1};
    }
  '';
in
{
  windows.configFiles."yasb/config.yaml" = pkgs.writeText "yasb-config.yaml" configYaml;
  windows.configFiles."yasb/styles.css" = pkgs.writeText "yasb-styles.css" stylesCss;
}
