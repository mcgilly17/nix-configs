{ ... }:
{
  imports = [
    # Common home manager configs
    ../common/home.nix
    ../common/core
    ../common/ai-tools
    ../common/tui
    ../common/shells
    ../common/desktop # Includes 1Password shell plugins
    ../common/desktop/terminals
    ../common/desktop/development
    ../common/dev # Dev machine specific (kubeconfig, etc.)

    # Linux-specific (Hyprland, Walker, Waybar, etc.)
    ../linux

    # Linux desktop apps
    ../linux/apps/default.nix # Base desktop (browsers, 1password, etc.)
    ../linux/apps/gaming.nix # Gaming (Steam, Lutris, etc.)
  ];
}
