{ config, pkgs, lib, ... }:

let
  # Application configuration
  apps = {
    fileManager = "${pkgs.nemo}/bin/nemo";
    browser = "${pkgs.firefox}/bin/firefox";
    imageViewer = "${pkgs.feh}/bin/feh";
    terminal = "${pkgs.alacritty}/bin/alacritty";
  };
in
{
  # Sway-related packages for the user
  home.packages = with pkgs; [
    alacritty         # terminal emulator
    firefox           # web browser
    feh               # image viewer
    nemo              # file manager
    wf-recorder       # screen recorder
    mako              # notification daemon
    grim              # screenshot tool
    slurp             # screenshot tool
    wofi              # dmenu replacement
    waybar            # status bar
    swaylock          # screen locker
    swayidle          # idle manager
    feh               # image viewer
    brightnessctl     # brightness control
    pamixer           # audio control
    playerctl         # media control
    font-awesome      # for waybar icons
    liberation_ttf    # fonts
    jq                # JSON processor (used by script)
    xdg-user-dirs     # for xdg-user-dir command
    wl-clipboard      # for wl-copy command
  ];

  # Sway configuration via Home Manager
  wayland.windowManager.sway = {
    enable = true;
    
    config = {
      # Basic settings
      modifier = "Mod4";  # Super key
      terminal = apps.terminal;
      menu = "wofi --show drun";
      
      # Font
      fonts = {
        size = 9.0;  # Increase from default (usually 10)
      };
      
      # Keybindings
      keybindings = let 
        modifier = "Mod4";
      in lib.mkOptionDefault {
        # Custom keybindings
        "Shift+F12" = "exec ~/.bin/sway_screenshot.sh";
        "Ctrl+Mod1+l" = "exec swaylock -f -c 111111";
        
        # Volume controls
        "XF86AudioMute" = "exec pamixer --toggle-mute";
        "XF86AudioLowerVolume" = "exec pamixer --decrease 5";
        "XF86AudioRaiseVolume" = "exec pamixer --increase 5";
        
        # Brightness controls  
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        
        # Screenshot
        "Print" = "exec grim";
        
        # Application keybindings
        "${modifier}+Shift+f" = "exec ${apps.fileManager}";
        "${modifier}+Shift+b" = "exec ${apps.browser}";
        "${modifier}+Shift+i" = "exec ${apps.imageViewer}";
        "${modifier}+Return" = "exec ${apps.terminal}";
      };
      
      # Window rules
      window = {
        border = 1;
      };
      
      # Gaps
      gaps = {
        inner = 4;
        outer = 4;
      };
      
      # Output configuration
      output = {
        "*" = {
          bg = "#333333 solid_color";
        };
      };
      
      # Input configuration
      input = {
        "*" = {
          xkb_layout = "us";
        };
      };
      
      # Disable default bar
      bars = [];
    };
    
    extraConfig = ''
      # System integration
      exec systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
      exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
    '';
  };

  # MINIMAL Waybar configuration
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        # height = 24;
        
        # Minimal modules
        modules-left = [ "sway/workspaces" ];
        modules-center = [ "username" ];
        modules-right = [ "clock" ];
        
        # Simple workspaces
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };
        
        # Simple clock
        "clock" = {
          format = "{:%a %B %d - %H:%M}";   # Mon December 25 - 14:30
        };

        # Username
        "username" = {
          exec = "echo \"$USER\"";
          interval = "once";
          format = "{}";
        };
      };
    };
    
    # Minimal styling
    style = ''
      * {
        font-size: 12px;
        border-radius: 0;  /* Remove all rounded corners */
      }

      window#waybar {
        background-color: #222222;
        color: #ffffff;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ffffff;
      }

      #workspaces button.focused {
        background-color: #444444;
      }

      #clock, #custom-hostname {
        padding: 0 8px;
      }
    '';
  };
}