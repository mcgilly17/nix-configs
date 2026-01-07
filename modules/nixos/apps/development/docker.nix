# Docker Engine for local development
#
# Usage:
# - docker ps                          # List running containers
# - docker compose up -d               # Start services in background
#
# Supabase local development:
# - npx supabase start                 # Start local Supabase stack
# - npx supabase stop                  # Stop local Supabase stack
_: {
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Add user to docker group (no sudo needed)
  users.users.michael.extraGroups = [ "docker" ];
}
