{pkgs, ...}: {
  ### Creative applications
  homebrew = {
    casks = [
      "adobe-creative-cloud" # For installing Lightroom
      "affinity-photo"
    ];
  };
}
