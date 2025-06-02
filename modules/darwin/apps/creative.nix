{pkgs, ...}: {
  ### Creative applications
  homebrew = {
    casks = [
      "autodesk-fusion" # Autodesk CAD Software
      "adobe-creative-cloud" # For installing Lightroom
      "affinity-designer"
      "affinity-photo"
      "affinity-publisher"
      "figma"
    ];
  };
}
