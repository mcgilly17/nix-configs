{
  pkgs,
  config,
  myVars,
  ...
}: {
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = "${config.xdg.configHome}/zsh";
    syntaxHighlighting.enable = false;
    enableCompletion = true;
    autosuggestion.enable = true;
    defaultKeymap = "emacs";

    history = {
      path = "${config.xdg.dataHome}/zsh/history"; # ~/.local/share/...
      share = true;
      extended = true;
      save = 5000;
      size = 5000;
      ignorePatterns = ["rm *"];
      ignoreDups = true; # makes searching history faster
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = false;
    };

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.plugin.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
      {
        name = "fzf-tab-source";
        src = pkgs.fetchFromGitHub {
          owner = "Freed-Wu";
          repo = "fzf-tab-source";
          rev = "1ee4a320822b7b13c4761a07cb6b39c7bb678921";
          sha256 = "sha256-fEpO1d+GDsHrpg2MKiOQNZBNXogHrzmeF9G230tO9Vw=";
        };
        file = "fzf-tab-source.plugin.zsh";
      }
    ];

    # completiojnInit = ''
    #   autoload -U compinit; compinit
    #   # fzf, enables it for ^r, ^s and tab completion
    #   # source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    # '';

    initContent = pkgs.lib.mkOrder 0 ''
      # macos upgrades might nix install: https://github.com/NixOS/nix/issues/3616
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      ### our zshrc
      ${builtins.readFile ./zshrc}
    '';

    envExtra = ''
      ${builtins.readFile ./zshenv}
      export OPENAI_API_KEY=$(cat ${config.sops.secrets."openAIKey".path})
    '';

    #

    shellAliases = {
      ll = "eza --group --header --group-directories-first --long --git --all --icons --sort name";
      lt = "eza --tree --level=2 --long --icons --git";
      cat = "bat"; # better cat - bat
      cd = "z"; # better cd - zoxide
      tig = "gitui"; # my fingers just do this too often
    };

    shellGlobalAliases = {
      G = "| grep";
    };
  };
}
