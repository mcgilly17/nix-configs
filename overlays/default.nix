#
# This file defines overlays/custom modifications to upstream packages
#
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: {
    # Can't get the below to work...will just go with the package route
    # mosaic = inputs.mosaic.overlays.default;
    mosaic = inputs.mosaic.packages.${final.pkgs.system}.default;
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # leaving as an example - moved to github.com/mcgilly17/Mosaic
    # vimPlugins =
    #   prev.vimPlugins
    #   // {
    #     eyeliner-nvim = prev.vimPlugins.eyeliner-nvim.overrideAttrs (oldAttrs: {
    #       version = "2024-08-09";
    #       src = final.fetchFromGitHub {
    #         owner = "jinh0";
    #         repo = "eyeliner.nvim";
    #         rev = "7385c1a29091b98ddde186ed2d460a1103643148";
    #         hash = "sha256-PyCcoSC/LeJ/Iuzlm5gd/0lWx8sBS50Vhe7wudgZzqM=";
    #       };
    #     });
    #   };

    # NOTE: Cant get this to work as the cargoHash is still set to the 0.40.1 versions
    # and there isnt a new one yet. If anyone understands how to overcome this, please
    # let me know!

    # zellij = prev.zellij.overrideAttrs (oldAttrs: {
    #   src = final.fetchFromGitHub {
    #     owner = "zellij-org";
    #     repo = "zellij";
    #     rev = "d76c4e5e49430414acd94b3270145ce0ca99d0ed";
    #     hash = "sha256-rn4steY8psI18Ktcpk61cz/1q2Q43owhTjc+8AqkEiw=";
    #   };
    # });
  };
}
