{
  # terminal file manager
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y"; # Adopt new default (was "yy" before 26.05)
  };
}
