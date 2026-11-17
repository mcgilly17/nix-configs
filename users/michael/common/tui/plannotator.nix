{ pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;

  # Prebuilt release binaries rather than building from source: upstream ships a
  # static binary per platform, and neither project has a Nix-friendly build.
  fromRelease =
    {
      pname,
      version,
      repo,
      assets,
      binName ? pname,
    }:
    let
      asset = assets.${system};
    in
    pkgs.runCommand "${pname}-${version}" { } ''
      install -Dm755 ${
        pkgs.fetchurl {
          url = "https://github.com/${repo}/releases/download/v${version}/${asset.name}";
          inherit (asset) sha256;
        }
      } $out/bin/${binName}
    '';

  # Annotate markdown in the terminal: select, comment, looks-good, delete, then
  # send the review back to the agent.
  plannotator-tui = fromRelease {
    pname = "plannotator-tui";
    version = "0.9.2";
    repo = "plannotator/plannotator-tui";
    assets = {
      aarch64-darwin = {
        name = "plannotator-tui-aarch64-apple-darwin";
        sha256 = "79c8801babac5cd257034036536bbcf51a7b4cd8d06b437f1e85713714521eb0";
      };
      x86_64-darwin = {
        name = "plannotator-tui-x86_64-apple-darwin";
        sha256 = "36ef05666c066db7c32759c8d6eebe62237117b88748818463fa2acf94ef5834";
      };
      aarch64-linux = {
        name = "plannotator-tui-aarch64-unknown-linux-gnu";
        sha256 = "ef579f63c24bbe474019be3cc5cc5a5bd0541eb79391b190957e50ab6ea0edb3";
      };
      x86_64-linux = {
        name = "plannotator-tui-x86_64-unknown-linux-gnu";
        sha256 = "874ecabaa35e3ace549d5bf3c7383fa4d1288ba06b36e9f04eb4f4b7b55229a5";
      };
    };
  };

  # The same review in the browser, on a local server. Also the CLI the `guides`
  # agent skill shells out to for `plannotator guide export`.
  plannotator = fromRelease {
    pname = "plannotator";
    version = "0.28.66";
    repo = "backnotprop/plannotator";
    assets = {
      aarch64-darwin = {
        name = "plannotator-darwin-arm64";
        sha256 = "44a86b2f7cd762c258e50555c665cf93388fca8a8058569b99111c3f3f2cc907";
      };
      x86_64-darwin = {
        name = "plannotator-darwin-x64";
        sha256 = "0b0555043b7f8eba76310591aee11edbc4ef0d30709d9919fe3c0a64d3fc813e";
      };
      aarch64-linux = {
        name = "plannotator-linux-arm64";
        sha256 = "fda6b7ed4844504fdecd2b370991f2641801dd974b35155bf4a5fce328fcd5c7";
      };
      x86_64-linux = {
        name = "plannotator-linux-x64";
        sha256 = "4fdf6271f4da85ab9d0fafa5fc16057785d9f40490231926149adfb5b5c510c2";
      };
    };
  };

  # The Claude Code plugin from the same tag as the binary, so its hooks and the
  # CLI never drift apart. It adds plan review, the plannotator_inbox tool and
  # the reply wake, including in T3 Code's Claude threads. Loaded from the store
  # because `claude plugin install` writes settings.json, which home-manager owns.
  plannotatorSrc = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "plannotator";
    rev = "v${pkgs.lib.getVersion plannotator}";
    hash = "sha256-dcL+4aAC0eaH7wruRzpWHA80+CnHSyU1T8ITIdK4Dy0=";
  };
in
{
  # Global rather than per-project: the documents worth reviewing live in repos
  # that have no devenv of their own, the wiki among them.
  home.packages = [
    plannotator-tui
    plannotator
  ];

  programs.claude-code.plugins = [ "${plannotatorSrc}/apps/hook" ];
}
