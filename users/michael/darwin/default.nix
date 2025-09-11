{
  pkgs,
  specialArgs,
  ...
}: {
  imports = specialArgs.myLibs.scanPaths ./.;

  # Home manager configs
  # UI apps on MacOS will get installed to /Users/username/Applications/Home Manager Apps
  home.packages = with pkgs; [
    # cocoapods
    m-cli # useful macOS CLI commands
  ];

  programs = {};
}
