{
  inputs,
  pkgs,
  specialArgs,
  ...
}: {
  imports =
    specialArgs.myLibs.scanPaths ./.
    ++ [
      inputs.catppuccin.homeManagerModules.catppuccin
      inputs._1password-shell-plugins.hmModules.default
    ];

  # Using catppuccin nix - global application of the catppuccin theme is enabled
  # For every supported application:
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "sapphire";
    k9s = {
      enable = true;
      flavor = "macchiato";
    };
    btop = {
      enable = true;
      flavor = "frappe";
    };
  };

  home.packages = with pkgs; [
    # Just install these with no config
    # Search here for config options for each. https://mynixos.com/home-manager/options/programs

    # Core Modules
    autoconf #Automatic configure script builder
    ack # Search tool like grep, but optimized for programmers https://beyondgrep.com/
    gawk # GNU awk utility
    openssl # Cryptography and SSL/TLS Toolkit
    findutils # Collection of GNU find, xargs, and locate https://www.gnu.org/software/findutils/
    wget # Internet file retriever
    readline # Library for command-line editing
    libyaml # A C library for parsing and emitting YAML https://github.com/yaml/libyaml
    gnupg # GnuPG is a complete and free implementation of the OpenPGP standard https://www.gnupg.org/
    ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
    curl # A command line tool for transferring files with URL syntax
    fd # A simple, fast and user-friendly alternative to find

    # Utilities
    pandoc # Conversion between documentation formats
    chafa # Terminal graphics
    hex # Futuristic take on hexdump, made in Rust
    gnused # GNU sed, a batch stream editor
    tealdeer # Simplified and community-driven man pages written in rust
    tmux #Terminal multiplexer https://tmux.github.io/
    moreutils # Collection of tools that nobody wrote when UNIX was young https://joeyh.name/code/moreutils/
    grc # Colorize logfiles and command output https://github.com/garabik/grc
    thefuck # Magnificent app which corrects your previous console command https://github.com/nvbn/thefuck
    tmate # Instant terminal sharing https://tmate.io/
    tree # Display directories as trees with optional color/HTML output http://mama.indstate.edu/users/ice/tree/
    tmux-xpanes # Awesome tmux-based terminal divider https://github.com/greymd/tmux-xpanes
    calc #Launch calc and you can start typing equations https://github.com/lcn2/calc
    # parallel # Shell tool for executing jobs in parallel
    sad # CLI search and replace, just like sed, but with diff preview.
    just # a command runner like make, but simpler
    hyperfine # command-line benchmarking tool
    duf # Disk Usage/Free Utility - a better 'df' alternative
    du-dust # A more intuitive version of `du` in rust
    gdu # disk usage analyzer(replacement of `du`)
    abduco # lightweight session management
    bottom # fancy version of `top` with ASCII graphs
    croc # File transfer between computers securely and easily
    mdcat # cat for markdown files

    # Networking
    nmap # Port scanning utility for large networks https://nmap.org/
    traefik # A reverse proxy / load balancer
    gping # ping, but with a graph(TUI)
    doggo # DNS client for humans
    bandwhich # display current network utilization by process

    # Nix Specific
    statix # Lints and suggestions for the nix programming language
    nix-output-monitor # it provides the command `nom` works just like `nix with more details log output
    nix-index # A small utility to index nix store paths
    nix-melt # A TUI flake.lock viewer
    nix-tree # A TUI to visualize the dependency graph of a nix derivation
    comma # run software from without installing it
    nix-update # swiss-knife for updating nix packages
    nixpkgs-review # review pull-requests on nixpkgs
    nixpkgs-fmt # Nix code formatter for nixpkgs
    deadnix # scan nix files for dead code
    node2nix # generate Nix expressions to build NPM packages
    alejandra # Nix formatter

    # Development Specific
    jq #json in the terminal
    cachix # adding/managing alternative binary caches hosted by Cachix
    yq-go # yaml processor https://github.com/mikefarah/yq
    prettierd # Prettier, as a daemon, for improved formatting speed
    kubetail
    devbox
    graphviz
    mutagen
    rclone
    socat
    neofetch
    devenv
    watchman
    nodejs_23

    # Neovim LSP and other pkgs
    prettierd
    nodePackages.prettier
    google-java-format
    black
    rustfmt
    selene
    eslint_d
    nodePackages.jsonlint
    # nodePackages."@prisma/language-server"
    nodePackages.graphql-language-service-cli
    emmet-language-server
    checkstyle
    markdownlint-cli2
    typescript
    marksman

    # Git speific addons
    bfg-repo-cleaner # Removes large or troublesome blobs in a git repository like git-filter-branch does, but faster
    git-crypt # git-crypt enables transparent encryption and decryption of files in a git repository https://www.agwa.name/projects/git-crypt/
    github-commenter # Command line utility for creating GitHub comments on Commits, Pull Request Reviews or Issues
    github-release # Commandline app to create and edit releases on Github and upload artifacts https://github.com/aktau/github-release
    libgit2 # Linkable library implementation of Git that you can use in your application (used for nvim git implementation)
  ];
}
