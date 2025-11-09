{
  outputs,
  lib,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

}
