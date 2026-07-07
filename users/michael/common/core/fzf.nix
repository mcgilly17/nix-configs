{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    historyWidget = {
      options = [ "--reverse" ];
      # Atuin owns Ctrl-R; leave fzf's history widget unbound.
      command = "";
    };
  };
}
