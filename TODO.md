# TODOs

## Priority Todos

- [ ] Configure Just

## General Todos

- [ ] Advanced Configuring ZSH - <https://github.com/mattmc3/zdotdir/tree/c53974484b863eb632278921088563134adbfc60> <https://github.com/MaJinjie/dotfiles/blob/b68ab9325ce790d41e0222eb4232ed4b8fda7c8c/.config/zsh/zsh.d/00-options.zsh>
- [ ] manage autocompletions for yabai and other tools - <https://github.com/mattmc3/zdotdir/tree/c53974484b863eb632278921088563134adbfc60> <https://github.com/Amar1729/yabai-zsh-completions/blob/main/src/_yabai>
- [ ] Explore bar options for mac (spacebar from Calum MacRae)
- [ ] Update dock config to allow for spacers
- [ ] update/config starship prompt for development envs and cloud providers
- [ ] checkout cli/tui tools lazydocker, navi, gh-dash, opencode
- [ ] setup nix shell
- [ ] separate brew apps of different types
- [ ] Karabiner configs: <https://github.com/mattsawyer77/nix-configuration/blob/7b099354e249fa73b3c31418d604953a09f94199/home/karabiner/default.nix#L474>

## Nvim todos

- [ ] Markdown table of contents
- [ ] Look at file management from within NeoVim (get better with oil or use telescope-file-browser etc)
- [ ] Sort out folding functions
- [ ] line wrapping
- [ ] incremental rename

## Infrastructure Improvements

- [ ] CI/CD: GitHub Actions workflow for automated weekly flake updates (DeterminateSystems/update-flake-lock)
- [ ] CI/CD: Add statix linting + deadnix + format checking on push
- [ ] Binary caching: Set up Cachix to avoid redundant builds across hosts (especially ARM cluster)
- [ ] Custom CLI wrapper script for common nix operations (rebuild, update, gc, repl)
- [ ] Evaluate Stylix for unified theming (fonts + colors + wallpaper) vs per-app catppuccin enables
- [ ] Evaluate Lanzaboote secure boot for ganon (pairs with existing LUKS)
- [ ] Convention-based host auto-discovery (like khanelinix parseSystemConfigurations)
- [ ] Grouped flake updates (core/system/app categories instead of all-or-nothing)

## Future Deployments

- [ ] Update secrets management to do host level decryption (for linux machines)

## Done

- [x] Configure Zellij Layouts
- [x] git aliases
- [x] fix autocomplete on zsh so that complete isnt done with only right arrow
- [x] I think i should move all keymaps to one file
- [x] Extract NixVim configs out into a standalone repo
- [x] LSP keymaps are screwed up
- [x] Tab between variables in snippets not working
- [x] fix markdown-preview
- [x] fix neovim markdown formatting - important notes remove new line
- [x] Learn about using nix in development environments
- [x] auto set my dock <https://github.com/dustinlyons/nixos-config/blob/main/flake.nix>
- [x] Research and Configure ZelliJ or Tmux
- [x] Configure LSP and more advanced features in NixVim
- [x] Add md viewer to fzf-tap
- [x] configure NeoVim
- [x] configure secrets
- [x] configure ssh
- [x] checkout Zoxide cli tool
- [x] configure git
- [x] Configure Starship - <https://github.com/malob/nixpkgs/blob/master/home/starship-symbols.nix> / <https://dev.to/therubberduckiee/how-to-configure-starship-to-look-exactly-like-p10k-zsh-warp-h9h>
- [x] Set caps lock as ctrl <https://github.com/LnL7/nix-darwin/issues/55>
- [x] configure 1password cli - <https://developer.1password.com/docs/cli/shell-plugins/nix/> <https://github.com/malob/nixpkgs/blob/master/flake.nix>
- [x] speed up zsh loading time - <https://github.com/pietersp/dotfiles/blob/4611be8a3e3509e1083aebc37c742a5896fd670d/home/pieter/common/core/zsh/default.nix>
- [x] Finish configuring yabai and SKHD
- [x] How to get custom sha256s and revs <https://www.reddit.com/r/NixOS/comments/10ueaev/how_do_i_get_the_sha256_for_a_package_to_use_in/>
- [x] Configure Raycast
- [x] Configure first nixOS machine
- [x] Configure remote deployment and server specific deployments

## On Hold

- [ ] configure wallpapers - doesnt seem overly easy in mac os right now. need to do more research
- [ ] ON HOLD - configure screensaver Brooklyn - Will fix when latest pull requests are merged

## Read more

### ZSH / fzf

<https://github.com/juampivallejo/dotfiles/blob/5989eab7ef94455c9a35c5b8997739799536a44d/home-manager/lessfilter.sh>
<https://thevaluable.dev/zsh-completion-guide-examples/>
<https://thevaluable.dev/zsh-line-editor-configuration-mouseless/>
<https://thevaluable.dev/practical-guide-fzf-example/>
