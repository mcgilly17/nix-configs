{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR"; # auto close if you can fit all onto screen
      style = "numbers,changes";
    };
  };

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
