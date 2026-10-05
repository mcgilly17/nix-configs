_: {
  # Don't install with nix, this doesn't work. Only use homebrew
  # packages = [pkgs.karabiner-elements];

  xdg.configFile."karabiner/karabiner.json".source = ./karabiner.json;
}
