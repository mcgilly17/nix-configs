{pkgs, ...}: {
  ### Desktop only Apps
  homebrew = {
    casks = [
      # "altserver@1.7.2" # Server for signging Apollo to my IOS
      "crystalfetch" # ISO fetch for windows and UTM
      "steam"
    ];
  };
}
