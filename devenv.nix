{
  pkgs,
  lib,
  ...
}:
{
  # Nix development tools
  packages = with pkgs; [
    # Nix tooling
    nil # Nix LSP
    nixfmt-rfc-style # Nix formatter (matches flake.nix formatter)
    statix # Nix linter
    deadnix # Find dead Nix code

    # For Spec Kit. uv is NOT here on purpose: it comes from homebrew
    # (modules/darwin/apps/development.nix) so `uv`/`uvx` resolve globally for
    # Claude's MCP servers. A devenv copy would shadow it with an older pin.
    python3

    # For GSD (Get Shit Done)
    nodejs
  ];

  # Nix language support
  languages.nix.enable = true;

  # Helper scripts
  scripts = {
    # Format all Nix files
    fmt.exec = ''
      ${lib.getExe pkgs.nixfmt-rfc-style} ./**/*.nix
    '';

    # Lint Nix files
    lint.exec = ''
      echo "Running statix..."
      ${lib.getExe pkgs.statix} check .
      echo ""
      echo "Running deadnix..."
      ${lib.getExe pkgs.deadnix} .
    '';

    # Build a darwin configuration
    build-darwin.exec = ''
      HOST="''${1:-bowser}"
      echo "Building darwin configuration for $HOST..."
      nix build ".#darwinConfigurations.$HOST.system" --show-trace
    '';

    # Build a NixOS configuration
    build-nixos.exec = ''
      HOST="''${1:-ganon}"
      echo "Building NixOS configuration for $HOST..."
      nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" --show-trace
    '';

    # Spec Kit setup
    speckit-setup.exec = ''
      TARGET_DIR="''${1:-.}"
      ${lib.getExe pkgs.uv}x --from git+https://github.com/github/spec-kit.git specify init "$TARGET_DIR"
    '';

    # GSD (Get Shit Done) setup
    gsd-setup.exec = ''
      npx get-shit-done-cc --local
    '';
  };

  enterShell = ''
    echo "dots - NixOS & nix-darwin configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Hosts:"
    echo "  Darwin: bowser, glados, shodan"
    echo "  NixOS:  ganon, zenith-{0,1,2,3}, ocelot, mantis"
    echo ""
    echo "Commands:"
    echo "  fmt              Format Nix files"
    echo "  lint             Run statix + deadnix"
    echo "  build-darwin     Build darwin config (default: bowser)"
    echo "  build-nixos      Build NixOS config (default: ganon)"
    echo "  speckit-setup    Initialize Spec Kit"
    echo "  gsd-setup        Install Get Shit Done workflow"
  '';

  # Git hooks for code quality
  git-hooks.hooks = {
    nixfmt-rfc-style.enable = true;
    statix.enable = true;
    deadnix.enable = true;
  };
}
