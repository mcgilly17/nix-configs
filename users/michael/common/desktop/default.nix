{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Just install these with no config
    ## Entertainment
    # spotify #Spotify is a digital music service that gives you access to millions of songs https://www.spotify.com/
    # deluge
    # steam #Steam is a digital distribution platform for video games developed by Valve Corporation, which offers digital rights management, multiplayer servers, video streaming, and social networking services https://store.steampowered.com/
    # plex-media-player #Plex media player
  ];
}
