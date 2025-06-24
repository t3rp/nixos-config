{ config, pkgs, lib, ... }:

{
  # Packages
  home.packages = with pkgs; [
    rofi 
    i3lock 
    scrot 
    libnotify 
    networkmanagerapplet
    alacritty
    firefox
    nemo
    pamixer
    brightnessctl
    xclip
    xsel
    arandr
    pavucontrol 
    rxvt-unicode
  ];

  # Set cursor configuration
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 16;
    x11.enable = true;
  };

  # Copy dotfiles
  home.file = {
    # i3 configuration
    ".config/i3/config".source = ../dotfiles/i3/config;
  };

  # Session
  xsession = {
    enable = true;
    
    # Set up environment
    initExtra = ''
      # Set cursor theme
      ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr

      # Disable screen saver
      ${pkgs.xorg.xset}/bin/xset s off
      ${pkgs.xorg.xset}/bin/xset -dpms
      
      # Create Pictures directory for screenshots
      mkdir -p ~/Pictures
      
      # Set up environment for standalone systems
      export XDG_SESSION_TYPE=x11
      export XDG_CURRENT_DESKTOP=i3
    '';
  };

  # Rofi configuration
  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    extraConfig = {
      show-icons = true;
      drun-display-format = "{name}";
    };
  };
}