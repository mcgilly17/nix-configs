{ options, ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
  }
  // (
    if options.programs.fzf ? historyWidget then
      {
        historyWidget = {
          options = [ "--reverse" ];
          # Atuin owns Ctrl-R; leave fzf's history widget unbound.
          command = "";
        };
      }
    else
      # home-manager 26.05 (glados' pinned Intel stack) predates the
      # historyWidget rename. No command option there; atuin's zsh
      # integration rebinds Ctrl-R over fzf's widget anyway.
      {
        historyWidgetOptions = [ "--reverse" ];
      }
  );
}
