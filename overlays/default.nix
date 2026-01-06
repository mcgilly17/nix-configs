#
# This file defines overlays/custom modifications to upstream packages
#
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: {
    # Can't get the below to work...will just go with the package route
    # mosaic = inputs.mosaic.overlays.default;
    mosaic = inputs.mosaic.packages.${final.system}.default;

    # Patched elephant package - fixes missing go.sum entry for regexp2
    # TODO: Remove this overlay once upstream fixes the go.sum
    # See: https://github.com/abenz1267/elephant/issues (report the bug)
    elephant-patched =
      let
        inherit (final) lib;
        elephantSrc = inputs.elephant;
        version = lib.trim (builtins.readFile "${elephantSrc}/cmd/elephant/version.txt");

        # Missing go.sum entry for regexp2 v1.11.5 (transitive dep of goja)
        # go.mod requires v1.11.5 but go.sum only has /go.mod without h1: checksum
        goSumPatch = final.writeText "go-sum-additions.txt" ''
          github.com/dlclark/regexp2 v1.11.5 h1:Q/sSnsKerHeCkc/jSTNq1oCm7KiVgUMZRDUoRu0JQZQ=
        '';

        # Patched source with fixed go.sum
        patchedSrc = final.runCommand "elephant-src-patched" { } ''
          cp -r ${elephantSrc} $out
          chmod -R +w $out
          cat ${goSumPatch} >> $out/go.sum
        '';

        # Base elephant binary
        elephant = final.buildGo125Module {
          pname = "elephant";
          inherit version;
          src = patchedSrc;
          vendorHash = "sha256-hA9DWhCnkM9v/RWdQWxk+w3knmZ5zJEJd3PUYbP3ptc=";
          buildInputs = with final; [ protobuf ];
          nativeBuildInputs = with final; [
            protoc-gen-go
            makeWrapper
          ];
          subPackages = [ "cmd/elephant" ];
          postFixup = ''
            wrapProgram $out/bin/elephant \
              --prefix PATH : ${lib.makeBinPath (with final; [ fd ])}
          '';
        };

        # Providers
        elephant-providers = final.buildGo125Module rec {
          pname = "elephant-providers";
          inherit version;
          src = patchedSrc;
          vendorHash = "sha256-hA9DWhCnkM9v/RWdQWxk+w3knmZ5zJEJd3PUYbP3ptc=";
          buildInputs = with final; [ wayland ];
          nativeBuildInputs = with final; [
            protobuf
            protoc-gen-go
          ];
          excludedProviders = [ "archlinuxpkgs" ];
          buildPhase = ''
            runHook preBuild
            echo "Building elephant providers..."
            EXCLUDE_LIST="${lib.concatStringsSep " " excludedProviders}"
            is_excluded() {
              target="$1"
              for e in $EXCLUDE_LIST; do
                [ -z "$e" ] && continue
                if [ "$e" = "$target" ]; then return 0; fi
              done
              return 1
            }
            if [ -d ./internal/providers ]; then
              for dir in ./internal/providers/*; do
                [ -d "$dir" ] || continue
                provider=$(basename "$dir")
                if is_excluded "$provider"; then
                  echo "Skipping excluded provider: $provider"
                  continue
                fi
                set -- "$dir"/*.go
                if [ -e "$1" ]; then
                  echo "Building provider: $provider"
                  if ! go build -buildmode=plugin -o "$provider.so" ./internal/providers/"$provider"; then
                    echo "Failed to build provider: $provider"
                    exit 1
                  fi
                fi
              done
            fi
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            mkdir -p $out/lib/elephant/providers
            for so_file in *.so; do
              if [[ -f "$so_file" ]]; then
                cp "$so_file" "$out/lib/elephant/providers/"
              fi
            done
            runHook postInstall
          '';
        };
      in
      final.stdenv.mkDerivation {
        pname = "elephant-with-providers";
        inherit version;
        dontUnpack = true;
        buildInputs = [
          elephant
          elephant-providers
        ];
        nativeBuildInputs = with final; [ makeWrapper ];
        installPhase = ''
          mkdir -p $out/bin $out/lib/elephant
          cp ${elephant}/bin/elephant $out/bin/
          cp -r ${elephant-providers}/lib/elephant/providers $out/lib/elephant/
        '';
        postFixup = ''
          wrapProgram $out/bin/elephant \
            --prefix PATH : ${
              lib.makeBinPath (
                with final;
                [
                  wl-clipboard
                  libqalculate
                  imagemagick
                  bluez
                ]
              )
            }
        '';
      };
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: _prev: {
    # leaving as an example - moved to github.com/mcgilly17/Mosaic
    # vimPlugins =
    #   prev.vimPlugins
    #   // {
    #     eyeliner-nvim = prev.vimPlugins.eyeliner-nvim.overrideAttrs (oldAttrs: {
    #       version = "2024-08-09";
    #       src = final.fetchFromGitHub {
    #         owner = "jinh0";
    #         repo = "eyeliner.nvim";
    #         rev = "7385c1a29091b98ddde186ed2d460a1103643148";
    #         hash = "sha256-PyCcoSC/LeJ/Iuzlm5gd/0lWx8sBS50Vhe7wudgZzqM=";
    #       };
    #     });
    #   };

    # NOTE: Cant get this to work as the cargoHash is still set to the 0.40.1 versions
    # and there isnt a new one yet. If anyone understands how to overcome this, please
    # let me know!

    # zellij = prev.zellij.overrideAttrs (oldAttrs: {
    #   src = final.fetchFromGitHub {
    #     owner = "zellij-org";
    #     repo = "zellij";
    #     rev = "d76c4e5e49430414acd94b3270145ce0ca99d0ed";
    #     hash = "sha256-rn4steY8psI18Ktcpk61cz/1q2Q43owhTjc+8AqkEiw=";
    #   };
    # });
  };
}
