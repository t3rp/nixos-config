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
          # Application launchers
          # "${mod}+Return" = "exec ${pkgs.rxvt-unicode}/bin/urxvt";
          "${mod}+Return = "exec ${pkgs.alacritty}/bin/alacritty";
          "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun";
          "${mod}+Shift+Return" = "exec ${pkgs.firefox}/bin/firefox";
          "${mod}+e" = "exec ${pkgs.nemo}/bin/nemo";

          # Window management
          "${mod}+q" = "kill";
          "${mod}+Shift+q" = "kill";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+Shift+space" = "floating toggle";
          "${mod}+space" = "focus mode_toggle";

          # Focus movement (vim-like)
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";

          # Window movement
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";

          # Layout changes
          "${mod}+s" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+t" = "layout toggle split";
          "${mod}+v" = "split h";
          "${mod}+b" = "split v";

          # Workspace switching
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";

          # Move to workspace
          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";

          # System controls
          "${mod}+Shift+c" = "reload";
          "${mod}+Shift+r" = "restart";
          "${mod}+Shift+e" = "exec i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'";

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

        # Simple bar configuration
        bars = [{
          position = "bottom";
          statusCommand = "${pkgs.writeShellScript "i3status-simple" ''
            #!/bin/bash
            while true; do
              # Simple status: Load | Memory | Time
              load=$(cat /proc/loadavg | cut -d' ' -f1)
              mem=$(free | grep Mem | awk '{printf "%.0f%%", $3/$2 * 100.0}')
              time=$(date '+%H:%M %m-%d')
              echo " CPU: $load | MEM: $mem | $time"
              sleep 5
            done
          ''}";
          colors = {
            background = "#222222";
            statusline = "#ffffff";
            separator = "#666666";
            focusedWorkspace = {
              background = "#4c7899";
              border = "#4c7899";
              text = "#ffffff";
            };
            activeWorkspace = {
              background = "#333333";
              border = "#333333"; 
              text = "#ffffff";
            };
            inactiveWorkspace = {
              background = "#222222";
              border = "#222222";
              text = "#888888";
            };
          };
        }];

        # Window-specific settings
        window.commands = [
          {
            criteria = { class = "Firefox"; };
            command = "move to workspace number 1";
          }
        ];

        # Startup applications
        startup = [
          { command = "${pkgs.networkmanagerapplet}/bin/nm-applet"; notification = false; }
        ];
      };
    };
  };

  # Rofi configuration - Fixed: removed lib.mkIf without condition
  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    extraConfig = {
      show-icons = true;
      drun-display-format = "{name}";
    };
  };

  # Optional: Configure urxvt
  home.file.".Xresources".text = ''
    URxvt.font: xft:DejaVu Sans Mono:size=10
    URxvt.background: #222222
    URxvt.foreground: #ffffff
    URxvt.scrollBar: false
    URxvt.cursorBlink: true
    URxvt.saveLines: 1000
  '';
}