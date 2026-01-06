# Desktop applications for NixOS workstations
_: {
  # 1Password GUI (CLI enabled in common.nix)
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "michael" ];
  };
}
