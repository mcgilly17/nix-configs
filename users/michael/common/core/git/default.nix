{
  pkgs,
  config,
  lib,
  specialArgs,
  ...
}: let
  inherit (specialArgs.myVars.users) michael;
  aliases = import ./aliases.nix;
  ignores = import ./ignores.nix;
in {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  # https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  #
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';

  home = {
    inherit (aliases) shellAliases;
  };

  programs.git = {
    enable = true;

    inherit (ignores) ignores;

    lfs.enable = true;
    package = pkgs.gitAndTools.gitFull;

    # Enable different config for work when
    # includes = [
    #   {
    #     # use different email & name for work
    #     path = "~/work/.gitconfig";
    #     condition = "gitdir:~/work/";
    #   }
    # ];

    settings = {
      user = {
        name = michael.handle;
        email = michael.gitEmail;
      };

      alias = aliases.aliases;

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      fetch.prune = true;
      merge.conflictStyle = "zdiff3";
      commit.verbose = true;
      diff.algorithm = "histogram";
      log.date = "iso";
      column.ui = "auto";
      branch.sort = "committerdate";

      url = {
        "ssh://git@github.com" = {
          insteadOf = "https://github.com";
        };
        "ssh://git@gitlab.com" = {
          insteadOf = "https://gitlab.com";
        };
        "ssh://git@bitbucket.com/" = {
          insteadOf = "https://bitbucket.com/";
        };
      };
    };
  };

  # Better git diff!
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      diff-so-fancy = true;
      line-numbers = true;
      true-color = "always";
      side-by-side = true;
      # features => named groups of settings, used to keep related settings organized
      # features = "";
    };
  };
  programs.gh = {
    enable = true;
    settings = {
      # Configure gh to use SSH for git operations
      git_protocol = "ssh";

      # Set default editor
      editor = "vim";
    };
  };
}
