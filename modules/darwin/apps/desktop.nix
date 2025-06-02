{pkgs, ...}: {
  ### Desktop only Apps
  homebrew = {
    casks = [
      "altserver" # Server for signging Apollo to my IOS
      "crystalfetch" # ISO fetch for windows and UTM
      "steam"
    ];
  };
}
