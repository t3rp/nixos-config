# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ 
  config, 
  lib, 
  pkgs, 
  username, 
  ... 
}:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Dell XPS 13 Plus specific hardware configurations
  hardware = {
    # Enable CPU microcode updates for Intel
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    
    # Enable firmware updates
    enableRedistributableFirmware = true;
    
    # Bluetooth support
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    
    # Graphics optimization for Intel Iris Xe
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver # VAAPI driver for newer Intel GPUs (Iris Xe)
        vaapiIntel         # VAAPI driver for older Intel GPUs
        vaapiVdpau
        libvdpau-va-gl
        intel-compute-runtime # OpenCL support
      ];
    };

    # FIDO2/WebAuthn support for security keys
    fido.enable = true;
  };

  # Power management optimizations for laptop
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # TLP for advanced battery management
  services.tlp = {
    enable = true;
    settings = {
      # CPU scaling
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # CPU energy performance policy
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      
      # CPU boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      
      # WiFi power management
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      
      # USB autosuspend
      USB_AUTOSUSPEND = 1;
      
      # Battery charge thresholds (helps preserve battery life)
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Thermal management
  services.thermald.enable = true;

  # Backlight control
  programs.light.enable = true;

  # Auto CPU frequency scaling
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Define hostname
  networking.hostName = "athena";

  # Enhanced networking for XPS 13 Plus
  networking = {
    networkmanager.enable = true;
    # Use iwd backend for better WiFi performance
    networkmanager.wifi.backend = "iwd";
    wireless.iwd.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Console configuration for HiDPI display
  console = {
    font = "ter-v32n";
    packages = with pkgs; [ terminus_font ];
    useXkbConfig = true;
  };

  # Enable greetd tui login
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'sway --unsupported-gpu'";
        user = "greeter";
      };
    };
  };

  # Configure keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Touchpad configuration
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      clickMethod = "clickfinger";
      disableWhileTyping = true;
      accelSpeed = "0.3";
    };
  };

  # Enhanced audio with pipewire and Dell-specific improvements
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # Dell XPS audio improvements
    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 32;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 32;
      };
    };
  };

  # Fingerprint reader support
  services.fprintd.enable = true;
  
  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # XDG portal support with HiDPI awareness
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  # Suspend and hibernation improvements
  systemd.sleep.extraConfig = ''
    HibernateDelaySec = 1h
  '';

  # Udev rules for Dell hardware
  services.udev.extraRules = ''
    # Dell XPS 13 Plus specific rules
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl --no-block start battery-low.service"
  '';

  # Enable Docker with optimizations
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  # Define a user account with laptop-specific groups
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "vboxusers" 
      "libvirtd" 
      "docker" 
      "video" 
      "audio"
      "plugdev"  # For hardware keys and USB devices
      "input"    # For input devices
    ];
    packages = with pkgs; [
      virt-manager
      qemu
      quickemu
      # Laptop-specific tools
      brightnessctl
      bluez-tools
    ];
  };
  
  # Set the default editor to vim
  environment.variables = {
    EDITOR = "vim";
    # HiDPI environment variables
    GDK_SCALE = "1.5";
    GDK_DPI_SCALE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    XCURSOR_SIZE = "32";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Comprehensive package list for Dell XPS 13 Plus
  environment.systemPackages = with pkgs; [
    # Base system tools
    vim
    git
    wget
    firefox
    alacritty
    
    # Desktop environment
    gnome-keyring
    seahorse
    nerdfonts
    greetd.tuigreet
    xdg-desktop-portal-wlr
    
    # Audio/Video
    pwvucontrol
    helvum
    
    # Development
    docker-compose
    cudatoolkit
    
    # Laptop-specific utilities
    powertop              # Power consumption analysis
    acpi                  # Battery and power info
    brightnessctl         # Backlight control
    bluez-tools          # Bluetooth utilities
    intel-gpu-tools     # Intel GPU monitoring
    libfprint           # Fingerprint utilities
    
    # HiDPI and display tools
    wdisplays           # Wayland display configuration
    
    # Network tools
    iw                  # WiFi configuration
    networkmanager      # Network management
    
    # System monitoring
    htop
    btop
    iotop
    
    # File management
    file
    tree
    unzip
    zip
    
    # Security
    yubikey-personalization  # YubiKey support
    
    # Performance tools
    stress              # System stress testing
    memtest86plus      # Memory testing
  ];
  
  # Font configuration for HiDPI
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      nerdfonts
    ];
    
    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      hinting.style = "slight";
      subpixel.rgba = "rgb";
      defaultFonts = {
        monospace = [ "Fira Code" "DejaVu Sans Mono" ];
        sansSerif = [ "Noto Sans" "DejaVu Sans" ];
        serif = [ "Noto Serif" "DejaVu Serif" ];
      };
    };
  };
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
