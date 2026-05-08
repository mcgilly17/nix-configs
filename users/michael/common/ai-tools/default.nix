{
  inputs,
  ...
}:
{
  imports = [
    ./claude-code
    inputs.qmd.homeModules.default
  ];
  programs.opencode = {
    enable = true;
  };
  programs.qmd = {
    enable = true;
  };
}
