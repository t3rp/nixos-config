{ 
  config, 
  pkgs, 
  lib, 
  ... 
}:

{
  # Enable OpenGL and OpenCL support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-ocl
      opencl-headers
      opencl-info
      clinfo
    ];
  };

  # Add CUDA and OpenCL support to existing graphics configuration
  hardware.graphics.extraPackages = with pkgs; [
    # OpenCL support
    opencl-headers
    opencl-info
    clinfo
    # CUDA support for hashcat
    cudatoolkit
    nvidia-vaapi-driver
  ];
`
  # Install hashcat and related tools
  environment.systemPackages = with pkgs; [
    hashcat
    hashcat-utils
    opencl-info
    clinfo
    # CUDA tools
    cudatoolkit
    nvidia-smi
  ];

  # Ensure CUDA is available in environment
  environment.variables = {
    CUDA_PATH = "${pkgs.cudatoolkit}";
    CUDA_ROOT = "${pkgs.cudatoolkit}";
  };
}