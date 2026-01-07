# TUI-based greeter (minimal, text-mode)
{ config, pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --remember \
            --asterisks \
            --time-format "%H:%M | %a, %d %b" \
            --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions
        '';
        user = "greeter";
      };
    };
  };
}
