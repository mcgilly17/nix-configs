{ ... }:
{
  imports = [
    # Common home manager configs
    ../common/home.nix
    ../common/core
    ../common/ai-tools
    ../common/tui
    ../common/shells
    ../common/desktop/terminals

    # Linux-specific (Hyprland, Walker, Waybar, etc.)
    ../linux

    # Gaming-specific development tools
    ../common/desktop/development
  ];
}
