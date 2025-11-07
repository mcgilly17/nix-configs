{
  programs.lazygit = {
    enable = true;

    settings = {
      gui = {
        authorColors = {
          "Michael" = "#c6a0f6";
        };
        branchColors = {
          main = "#ed8796";
          master = "#ed8796";
          dev = "#8bd5ca";
        };
        nerdFontsVersion = "3";
      };
      git = {
        overrideGpg = true;
      };
    };
  };

  home.shellAliases = {
    lg = "lazygit";
  };
}
