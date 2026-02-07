# Ocelot - WSL Home Manager Configuration
# Full development environment with Windows integration
{ pkgs, ... }:

{
  imports = [
    # Common home manager configs
    ../common/home.nix
    ../common/core
    ../common/tui
    ../common/shells
    ../common/ai-tools
  ];

  # WSL-specific shell aliases for Windows integration
  programs.zsh.shellAliases = {
    # Windows interop
    explorer = "explorer.exe";
    code = "code.exe";
    clip = "clip.exe";
    # Open current directory in Windows Explorer
    open = "explorer.exe .";
    # Copy to Windows clipboard
    pbcopy = "clip.exe";
  };

  home.packages = with pkgs; [
    # Additional dev tools
    ripgrep
    fd
    eza
    bat
    fzf
  ];
}
