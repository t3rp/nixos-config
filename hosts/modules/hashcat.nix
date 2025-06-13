{ 
  config, 
  pkgs, 
  lib, 
  ... 
}:

{
  # Add CUDA and OpenCL support to existing graphics configuration
  hardware.graphics.extraPackages = with pkgs; [
    intel-ocl
    opencl-headers
    clinfo
    cudatoolkit
    nvidia-vaapi-driver
  ];
  
  # Install hashcat and related tools
  environment.systemPackages = with pkgs; [
    hashcat
    hashcat-utils
    clinfo
    cudatoolkit
  ];

  # Ensure CUDA is available in environment
  environment.variables = {
    CUDA_PATH = "${pkgs.cudatoolkit}";
    CUDA_ROOT = "${pkgs.cudatoolkit}";
  };
}