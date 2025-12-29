{
  pkgs,
  lib,
  ...
}: {
  # Nix development tools
  packages = with pkgs; [
    # Nix tooling
    nil                # Nix LSP
    nixfmt-rfc-style   # Nix formatter (matches flake.nix formatter)
    statix             # Nix linter
    deadnix            # Find dead Nix code

    # For Spec Kit
    python3
    uv
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
      HOST="''${1:-sephiroth}"
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
  };

  enterShell = ''
    echo "dots - NixOS & nix-darwin configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Hosts:"
    echo "  Darwin: sephiroth, bowser"
    echo "  NixOS:  ganon, rk1-node{1,2,3,4}"
    echo ""
    echo "Commands:"
    echo "  fmt              Format Nix files"
    echo "  lint             Run statix + deadnix"
    echo "  build-darwin     Build darwin config (default: sephiroth)"
    echo "  build-nixos      Build NixOS config (default: ganon)"
    echo "  speckit-setup    Initialize Spec Kit"
  '';

  # Git hooks for code quality
  git-hooks.hooks = {
    nixfmt-rfc-style.enable = true;
    statix.enable = true;
    deadnix.enable = true;
  };
}
