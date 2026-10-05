{ specialArgs, ... }:
{
  imports = specialArgs.myLibs.scanPaths ./. ++ [
    ../common/core.nix
  ];
}
