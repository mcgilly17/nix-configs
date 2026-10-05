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
    version = "0.27.18";
    repo = "backnotprop/plannotator";
    assets = {
      aarch64-darwin = {
        name = "plannotator-darwin-arm64";
        sha256 = "5313b0432243983b83a4136d20c6da6da6dd5c6ca8b1ffaf5fbef041e78760c2";
      };
      x86_64-darwin = {
        name = "plannotator-darwin-x64";
        sha256 = "1b8fcf9f737b92f961ba7ac97a606cbd71bc18b7f05c16d8603937a2d9fc8b20";
      };
      aarch64-linux = {
        name = "plannotator-linux-arm64";
        sha256 = "122e59339bba1531a237d29c287bcc587b1f2bd73a4e8c19327369671b5b5c26";
      };
      x86_64-linux = {
        name = "plannotator-linux-x64";
        sha256 = "d3908e01b4689886e73ba7c6d3784d98518edfc998ed7ab37f2b956d7fdd0870";
      };
    };
  };
in
{
  # Global rather than per-project: the documents worth reviewing live in repos
  # that have no devenv of their own, the wiki among them.
  home.packages = [
    plannotator-tui
    plannotator
  ];
}
