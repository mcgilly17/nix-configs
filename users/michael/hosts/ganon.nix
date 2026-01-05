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

    # Linux desktop apps
    ../linux/apps/default.nix # Base desktop (browsers, 1password, etc.)
    ../linux/apps/gaming.nix # Gaming (Steam, Lutris, etc.)

    # Development tools
    ../common/desktop/development
  ];
}
