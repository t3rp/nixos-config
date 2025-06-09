{ 
  config, 
  pkgs, 
  lib, 
  ... 
}:

{

  # Imports
  imports = [
    ./mako.nix
  ];

  # Packages for Sway
  home.packages = with pkgs; [
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
  ];

  # Enable Sway if Wayland is available
  wayland.windowManager.sway = {
    enable = true;
    
    config = {
      # Basic settings
      modifier = "Mod4";  # Super key
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "${pkgs.wofi}/bin/wofi --show drun";
      
      # Keybindings
      keybindings = let 
        modifier = "Mod4";
      in {
        # Volume/brightness
        "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer --toggle-mute";
        "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer --decrease 5";
        "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer --increase 5";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
        
        # Sway-specific
        "Ctrl+Mod1+l" = "exec ${pkgs.swaylock}/bin/swaylock -f -c 222222";
        "Shift+F12" = "exec ~/.bin/sway_screenshot.sh";
        
        # Screenshots
        "Print" = "exec ${pkgs.grim}/bin/grim ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && ${pkgs.libnotify}/bin/notify-send 'Screenshot saved'";
        "${modifier}+Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && ${pkgs.libnotify}/bin/notify-send 'Area screenshot saved'";
        "${modifier}+Shift+Print" = "exec grim -g \"$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | \"\\(.x),\\(.y) \\(.width)x\\(.height)\"')\" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && notify-send 'Window screenshot saved'";
        
        # Screenshot to clipboard
        "Ctrl+Print" = "exec ${pkgs.grim}/bin/grim - | wl-copy";
        "Ctrl+${modifier}+Print" = "exec ${pkgs.grim}/bin/grim -g \"$(slurp)\" - | wl-copy";
        
        # Applications
        "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
        "${modifier}+Shift+f" = "exec ${pkgs.nemo}/bin/nemo";
        "${modifier}+Shift+b" = "exec ${pkgs.firefox}/bin/firefox";

        # WORKSPACE KEYBINDINGS - EXPLICIT OVERRIDE
        # Workspace switching
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        # Move container to workspace
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        # Window management
        "${modifier}+q" = "kill";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+space" = "focus mode_toggle";

        # Focus movement (vim-like)
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";

        # Window movement
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";

        # Layout management
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+v" = "split h";
        "${modifier}+b" = "split v";

        # Sway control
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+r" = "restart";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
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
      # Import specific environment variables
      exec systemctl --user import-environment PATH WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      
      # Update D-Bus with Wayland-specific variables
      exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      
      # Optional: Set additional Wayland variables
      exec systemctl --user set-environment XDG_CURRENT_DESKTOP=sway
      exec systemctl --user set-environment XDG_SESSION_TYPE=wayland

      # Add your custom variables here
      set $file_manager ${pkgs.nemo}/bin/nemo
      set $browser ${pkgs.firefox}/bin/firefox
      set $image_viewer ${pkgs.feh}/bin/feh
    '';
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        
        # Expanded modules
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ 
          "pulseaudio" 
          "network" 
          "battery" 
          "backlight"
          "memory" 
          "cpu" 
          "temperature"
          "disk"
          "tray"
          "clock" 
        ];
        
        # Workspaces (keep existing)
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2"; 
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            "urgent" = "!";
            "focused" = "●";
            "default" = "○";
          };
        };

        # Current mode
        "sway/mode" = {
          format = "<span style=\"italic\">{}</span>";
        };

        # Active window title
        "sway/window" = {
          format = "{title}";
          max-length = 50;
          tooltip = false;
        };

        # Audio control
        "pulseaudio" = {
          format = "Audio: {volume}% {icon}";
          format-bluetooth = "Audio: {volume}% {icon}";
          format-bluetooth-muted = "Audio: ";
          format-muted = "Audio: ";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "${pkgs.pamixer}/bin/pamixer --toggle-mute";
          on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
          scroll-step = 5;
        };

        # Network status
        "network" = {
          format-wifi = "Net: {essid} ({signalStrength}%) ";
          format-ethernet = "Net: {ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "Net: {ifname} (No IP) ";
          format-disconnected = "Net: Disconnected ⚠";
          format-alt = "Net: {ifname}: {ipaddr}/{cidr}";
          on-click-right = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        # Battery (if laptop)
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "Bat: {capacity}% {icon}";
          format-charging = "Bat: {capacity}%  ";
          format-plugged = "Bat: {capacity}%  ";
          format-alt = "Bat: {time} {icon}";
          format-icons = ["" "" "" "" ""];
          tooltip-format = "{timeTo}, {capacity}%";
        };

        # Screen brightness
        "backlight" = {
          format = "Bright: {percent}% {icon}";
          format-icons = ["" "" "" "" "" "" "" "" ""];
          on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
          on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        };

        # Memory usage
        "memory" = {
          interval = 30;
          format = "Memory: {used:0.1f}G/{total:0.1f}G ";
          tooltip-format = "Memory: {used:0.1f}GB used of {total:0.1f}GB ({percentage}%)";
        };

        # CPU usage
        "cpu" = {
          interval = 10;
          format = "Compute: {usage}% ";
          tooltip-format = "CPU Usage: {usage}%";
          on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.btop}/bin/btop";
        };

        # CPU temperature
        "temperature" = {
          thermal-zone = 2;
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 80;
          format-critical = "Temp: {temperatureC}°C {icon}";
          format = "Temp: {temperatureC}°C {icon}";
          format-icons = ["" "" ""];
          tooltip-format = "CPU Temperature: {temperatureC}°C";
        };

        # Disk usage
        "disk" = {
          interval = 30;
          format = "Disk: {percentage_used}% ";
          path = "/";
          tooltip-format = "Disk: {used} used of {total} on {path} ({percentage_used}%)";
          on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.ncdu}/bin/ncdu /";
        };

        # System tray
        "tray" = {
          icon-size = 16;
          spacing = 8;
        };

        # Enhanced clock
        "clock" = {
          interval = 60;
          format = "Time: {:%a %b %d - %H:%M}";
          format-alt = "Date: {:%Y-%m-%d %H:%M:%S}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
      };
    };
    
    # Style
    style = ''
      * {
        font-family: "DejaVu Sans Mono", monospace;
        font-size: 11px;
        border-radius: 0;  /* Keep your no rounded corners */
      }

      window#waybar {
        background-color: #222222;
        color: #ffffff;
        transition-property: background-color;
        transition-duration: 0.5s;
        border-bottom: 2px solid #444444;
      }

      /* Workspaces styling (keep existing) */
      #workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: #ffffff;
        border: none;
      }

      #workspaces button:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #workspaces button.focused {
        background-color: #444444;
        color: #ffffff;
      }

      #workspaces button.urgent {
        background-color: #eb4d4b;
        color: #ffffff;
      }

      /* Module styling */
      #mode, #window, #pulseaudio, #network, #battery, #backlight, 
      #memory, #cpu, #temperature, #disk, #tray, #clock {
        padding: 0 8px;
        color: #ffffff;
      }

      /* Specific module colors */
      #pulseaudio {
        color: #74b9ff;
      }

      #pulseaudio.muted {
        color: #636e72;
      }

      #network {
        color: #00b894;
      }

      #network.disconnected {
        color: #e17055;
      }

      #battery {
        color: #a29bfe;
      }

      #battery.charging, #battery.plugged {
        color: #00b894;
      }

      #battery.critical:not(.charging) {
        background-color: #e17055;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      #backlight {
        color: #ffeaa7;
      }

      #memory {
        color: #fd79a8;
      }

      #cpu {
        color: #fdcb6e;
      }

      #temperature {
        color: #e84393;
      }

      #temperature.critical {
        background-color: #e17055;
        color: #ffffff;
      }

      #disk {
        color: #55a3ff;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #e17055;
      }

      #clock {
        color: #ffffff;
        font-weight: bold;
      }

      /* Animations */
      @keyframes blink {
        to {
          background-color: #ffffff;
          color: #000000;
        }
      }
    '';
  };
}