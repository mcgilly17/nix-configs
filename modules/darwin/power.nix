{
  networking.wakeOnLan.enable = true;

  # tcpkeepalive and powernap have no nix-darwin options yet
  system.activationScripts.postActivation.text = ''
    sudo pmset -a tcpkeepalive 1
    sudo pmset -a powernap 1
  '';
}
