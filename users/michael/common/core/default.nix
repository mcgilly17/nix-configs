{ specialArgs, ... }:
{
  imports = specialArgs.myLibs.scanPaths ./.;
}
