{
  networking.wakeOnLan.enable = true;

  # these pmset options have no nix-darwin equivalents yet
  system.activationScripts.postActivation.text = ''
    sudo pmset -a tcpkeepalive 1
    sudo pmset -a powernap 1
    sudo pmset -a ttyskeepawake 1
  '';
}
