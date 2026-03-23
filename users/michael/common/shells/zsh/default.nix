{
  pkgs,
  config,
  ...
}:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = "${config.xdg.configHome}/zsh";
    syntaxHighlighting.enable = false; # using fast-syntax-highlighting plugin instead
    enableCompletion = true;
    autosuggestion.enable = true;
    defaultKeymap = "emacs";

    history = {
      path = "${config.xdg.dataHome}/zsh/history";
      share = true;
      extended = true;
      save = 50000;
      size = 50000;
      ignorePatterns = [ "rm *" ];
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
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
      # NOTE: zsh-autosuggestions is loaded by autosuggestion.enable above
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

    initContent = pkgs.lib.mkMerge [
      # nix-daemon must load before everything else
      (pkgs.lib.mkOrder 0 ''
        # macos upgrades might nix install: https://github.com/NixOS/nix/issues/3616
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      '')
      # zshrc must load after plugins (default order 1000)
      (pkgs.lib.mkOrder 1100 ''
        ${builtins.readFile ./zshrc}
      '')
    ];

    envExtra = ''
      ${builtins.readFile ./zshenv}
    '';

    shellAliases = {
      ll = "eza --group --header --group-directories-first --long --git --all --icons --sort name";
      lt = "eza --tree --level=2 --long --icons --git";
      cat = "bat";
      cd = "z";
      tig = "gitui";
      docker-compose = "podman-compose";
    };

    shellGlobalAliases = {
      G = "| grep";
    };
  };

}
