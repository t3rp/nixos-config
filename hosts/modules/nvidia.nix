{ 
    config, 
    pkgs, 
    ... 
}:

{
    # Blacklist nouveau kernel module
    boot.blacklistedKernelModules = [ "nouveau" ];
   
    # Newer method here, commented out old
    # https://wiki.nixos.org/wiki/Graphics -> move to hardware.graphics in 24.11
    # https://wiki.nixos.org/wiki/NVIDIA -> nvidia
    # https://wiki.nixos.org/wiki/CUDA -> cuda
    hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
            nvidia-vaapi-driver
            clinfo
            cudatoolkit
        ];
    };
    
    # Deprecated, but needed for hashcat on 24.11
    # hardware.opengl = {
    #     enable = true;
    #     extraPackages = with pkgs; [
    #         nvidia-vaapi-driver
    #         cudatoolkit
    #         clinfo
    #         ocl-icd
    #     ];
    # };

    # Ensure CUDA is available in environment
    environment.variables = {
        CUDA_PATH = "${pkgs.cudatoolkit}";
        CUDA_ROOT = "${pkgs.cudatoolkit}";
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];
        # Enable the Nvidia driver for Xorg and Wayland
        hardware.nvidia = {
        # Modesetting is required.
        modesetting.enable = true;
        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        # Enable this if you have graphical corruption issues or application crashes after waking
        # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
        # of just the bare essentials.
        powerManagement.enable = false;
        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;
        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of 
        # supported GPUs is at: 
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
        # Only available from driver 515.43.04+
        open = true;
        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;
    };
}