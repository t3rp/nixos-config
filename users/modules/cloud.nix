{ 
  config, 
  pkgs, 
  lib, 
  ... 
}: 

{
  # Cloud
  home.packages = with pkgs; [
    awscli2
    azure-cli
    google-cloud-sdk
    terraform
    kubectl
    helm
  ];
}