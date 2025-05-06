# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, username, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Define hostname
  networking.hostName = "ares"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Configure x11 resources for 4k monitor
  # Enable the X11 windowing system
  # services.xserver = {
  #   enable = true;
  #   displayManager.sessionCommands = ''
  #     xrdb -merge <<EOF
  #     Xcursor.size: 16
  #     Xft.dpi: 172
  #     EOF
  #   '';
  # };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Keyring
  services.gnome.gnome-keyring.enable = true;

  # Enable polkit for permission management
  security.polkit.enable = true;
  # Enable dbus
  services.dbus.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Enable VirtualBox host support (kernel modules, services, etc.)
  virtualisation.virtualbox.host.enable = true;

  # Enable libvirt support (kernel modules, services, etc.)
  virtualisation.libvirtd.enable = true;

  # Fix for slow networking in virt-manager
  networking.extraHosts = ''
    127.0.0.1 localhost ${config.networking.hostName}
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [ "networkmanager" "wheel" "vboxusers" "libvirtd"];
    # Specific programs for this system and user
    packages = with pkgs; [
    virt-manager # virtual machine manager
    qemu # virtual machine manager
    quickemu # quicker virtual machines
    ];
  };
  
  # Set the default editor to vim
  environment.variables.EDITOR = "vim";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # text editor
    gnome-keyring # keyring manager
    seahorse # keyring manager
    nerdfonts # nerd fonts
    git # version control
    firefox # web browser
    wget # file downloader
    alacritty # terminal emulator
  ];
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
