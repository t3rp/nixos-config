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

  # Copy i3 configuration
  home.file = {
    # Sway configuration
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

    # i3
    windowManager.i3 = {
      enable = true;

      config = {
        # Basic settings
        modifier = "Mod4";  # Super key
        window = {
          border = 1;
          hideEdgeBorders = "smart";
        };

        # Workspace settings
        workspaceAutoBackAndForth = true;

        # Key bindings
        keybindings = let
          mod = "Mod4";
        in {
          # Screen lock
          "${mod}+Ctrl+l" = "exec ${pkgs.i3lock}/bin/i3lock -c 000000";

          # Volume controls
          "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
          "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
          "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";

          # Brightness controls
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +10%";
          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";

          # Screenshot - full screen
          "Print" = "exec ${pkgs.scrot}/bin/scrot ~/Pictures/screenshot_%Y%m%d_%H%M%S.png && notify-send 'Screenshot saved'";
          
          # Screenshot - select area
          "${mod}+Print" = "exec ${pkgs.scrot}/bin/scrot -s ~/Pictures/screenshot_%Y%m%d_%H%M%S.png";
          
          # Screenshot - current window
          "${mod}+Shift+Print" = "exec ${pkgs.scrot}/bin/scrot -u ~/Pictures/screenshot_%Y%m%d_%H%M%S.png";
        };
      };
    };
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