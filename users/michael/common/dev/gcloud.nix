# Google Cloud SDK (gcloud, gsutil, bq)
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    google-cloud-sdk
  ];
}
