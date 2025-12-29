{
  config,
  myVars,
  ...
}:
let
  user = myVars.users.michael.username;
in
{
  # Fully declarative dock using the latest from Nix Store
  local.dock = {
    enable = true;
    username = user;
    entries = [
      {
        path = "${config.users.users.${user}.home}/Downloads";
        section = "others";
        options = "--sort name --view list --display folder";
      }
      {
        path = "/Applications/";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
    ];
  };
}
