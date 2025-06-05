{ config, pkgs, lib, ... }:

let
  isCI = builtins.getEnv "CI" == "true" || builtins.getEnv "GITHUB_ACTIONS" == "true";
in
{
  # Wayland-specific packages only
  home.packages = with pkgs; lib.optionals (!isCI) [
    # Wayland-only packages
    waybar 
    swaylock 
    swayidle 
    wl-clipboard 
    grim 
    slurp 
    wofi 
    mako 
    wf-recorder
  ];

  # Only enable Sway if Wayland is available and not in CI
  wayland.windowManager.sway = lib.mkIf (!isCI) {
    enable = true;
    
    config = {
      # Basic settings
      modifier = "Mod4";  # Super key
      terminal = "${pkgs.alacritty}/bin/alacritty";  # CHANGE: Use direct pat
      menu = "${pkgs.wofi}/bin/wofi --show drun";    # CHANGE: Use direct path
      
      # Font
      fonts.size = 9.0;  # Increase from default (usually 10)
      
      # Keybindings
      keybindings = let 
        modifier = "Mod4";
      in lib.mkOptionDefault {
        # Volume/brightness (works in both WMs)
        "XF86AudioMute" = "exec pamixer --toggle-mute";
        "XF86AudioLowerVolume" = "exec pamixer --decrease 5";
        "XF86AudioRaiseVolume" = "exec pamixer --increase 5";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        
        # Sway-specific
        "Ctrl+Mod1+l" = "exec swaylock -f -c 111111";
        
        # Enhanced screenshots
        "Print" = "exec grim ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && notify-send 'Screenshot saved'";
        "${modifier}+Print" = "exec grim -g \"$(slurp)\" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && notify-send 'Area screenshot saved'";
        "${modifier}+Shift+Print" = "exec grim -g \"$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | \"\\(.x),\\(.y) \\(.width)x\\(.height)\"')\" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && notify-send 'Window screenshot saved'";
        
        # Screenshot to clipboard (your current behavior)
        "Ctrl+Print" = "exec grim - | wl-copy";
        "Ctrl+${modifier}+Print" = "exec grim -g \"$(slurp)\" - | wl-copy";
        
        # Applications using env vars
        "${modifier}+Shift+f" = "exec $FILE_MANAGER";
        "${modifier}+Shift+b" = "exec $BROWSER";
        "${modifier}+Return" = "exec $TERMINAL";
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
      exec systemctl --user import-environment
      exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
    '';
  };

  programs.waybar = lib.mkIf (!isCI) {
    enable = true;
    
    # Use default systemd integration
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