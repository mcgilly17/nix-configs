# Eternal Terminal - roaming remote shell that relays bytes rather than
# emulating a terminal, so zellij's nested-session handshake survives it.
# mosh cannot carry that handshake: its terminal emulator consumes escape
# sequences it does not recognise, so a guest session never announces itself.
#
# Installed everywhere because every host is both ends of a connection: the
# client needs `et`, the host being reached needs `etserver` and `etterminal`.
# Only glados runs the server daemon - see hosts/glados/default.nix, which
# binds it to glados's tailnet address.
#
# The package is pinned to the 26.05 nixpkgs on every host (overlays/default.nix):
# ET sends a wire-protocol version on connect, so both ends must match.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    eternal-terminal
  ];

  # nixpkgs builds et with telemetry compiled in (homebrew's formula passes
  # -DDISABLE_TELEMETRY=ON; this derivation does not), so it reports crashes
  # and errors upstream unless this is set. The etserver daemon needs it too -
  # launchd inherits no shell environment - see hosts/glados/default.nix.
  home.sessionVariables.ET_NO_TELEMETRY = "1";
}
