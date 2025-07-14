{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # Wayland/Sway core
    sway
    waybar
    swaylock
    swayidle
    wl-clipboard
    grim
    slurp
    wofi
    wf-recorder
    alacritty
    nemo
    firefox
    pamixer
    brightnessctl
    pavucontrol
    networkmanagerapplet
    libnotify
    ncdu
    jq
    feh
    gvfs # for nemo and udiskie
  ];

  # Copy Sway and Waybar configs
  home.file = {
    # Sway configuration
    ".config/sway/config".source = ../dotfiles/sway/config;
    ".config/waybar/config".source = ../dotfiles/waybar/config;
    ".config/waybar/style.css".source = ../dotfiles/waybar/style.css;
    ".config/wofi/config".source = ../dotfiles/wofi/config;
    ".config/wofi/style.css".source = ../dotfiles/wofi/style.css;
  };

  # Enable XDG desktop integration
  xdg.enable = true;

  # Set default applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "inode/directory" = "nemo.desktop";
    };
  };

  # Auto mount USB drives
  services.udiskie = {
    enable = true;
    tray = "never";
    automount = true;
  };
}
