{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ../tui/btop.nix
    ../tui/k9s.nix
    ../tui/starship.nix
    ../tui/starship_symbols.nix
    ../tui/zellij
    inputs.catppuccin.homeModules.catppuccin
  ];

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

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.clipboard = "unnamedplus"
      vim.opt.termguicolors = true
      vim.opt.scrolloff = 8
      vim.opt.signcolumn = "yes"
    '';
  };

  home.packages = with pkgs; [
    # Core CLI
    ripgrep
    fd
    curl
    wget
    jq
    yq-go
    tree
    gnused
    gawk
    unzip
    openssl
    zstd

    # Disk
    duf
    dust

    # K8s / cluster ops
    kubectl
    kubetail
    fluxcd

    # Network debugging
    nmap
    gping
    doggo
    bandwhich
    socat

    # Hardware
    tpi
  ];
}
