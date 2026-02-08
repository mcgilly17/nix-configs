{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "MesloLGS Nerd Font Mono"; # Should try "JetBrainsMono Nerd Font"
      # use different font size on macOS
      size = if pkgs.stdenv.isDarwin then 12 else 11;
    };
    settings = {
      background_opacity = "0.98";
      scrollback_lines = 4000;
      scrollback_pager_history_size = 2048;
      enable_audio_bell = false;
      macos_option_as_alt = true; # Option key acts as Alt on macOS

      # Layout / Window / Tabs
      hide_window_decorations = "titlebar-only";
      tab_bar_edge = "top"; # tab bar on top;
      tab_bar_min_tabs = 1; # show tab bar from 1 tab min
      tab_bar_style = "powerline"; # use snazzy separators
      tab_title_template = "{title}";
    };
    # macOS specific settings
    darwinLaunchOptions = [ ];

    # Extra config for mouse mappings
    extraConfig = ''
      # Cmd+click to open URLs (macOS convention)
      # Mirrors the default ctrl+shift+left binding
      mouse_map cmd+left press grabbed discard_event
      mouse_map cmd+left release grabbed,ungrabbed mouse_handle_click link
    '';
  };
}
