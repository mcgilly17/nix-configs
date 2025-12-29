{ inputs, ... }:
{
  users = {
    michael = {
      username = "michael";
      handle = "McGilly17";
      gitEmail = "4136843+mcgilly17@users.noreply.github.com";
      userFullName = inputs.nix-secrets.michaelFullName;
      email = inputs.nix-secrets.michaelEmail;
      # isMinimal = false; # Used to indicate nixos-installer build
    };
  };
}
