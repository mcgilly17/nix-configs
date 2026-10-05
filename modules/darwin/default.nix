{ myLibs, ... }:
{
  imports =
    myLibs.scanPaths ./.
    ++ (map myLibs.relativeToRoot [
      "modules/common/core.nix"
      "resources/lib/dock.nix"
    ]);
}
