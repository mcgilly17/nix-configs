_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
    };
  };

}
