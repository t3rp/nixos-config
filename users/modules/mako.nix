{ 
  config, 
  pkgs, 
  lib, 
  ...
}:

{
  # Notification system configuration
  services.mako = {
    enable = true;
    backgroundColor = "#222222";
    textColor = "#ffffff";
    borderColor = "#74b9ff";
    borderRadius = 0;
    borderSize = 2;
    defaultTimeout = 5000;
    width = 300;
    height = 100;
    margin = "10";
    padding = "10";
    font = "DejaVu Sans Mono 10";
    maxVisible = 5;
    sort = "-time";
    anchor = "top-right";
    actions = true;
    
    extraConfig = ''
      on-button-left=dismiss
      on-button-middle=dismiss-all
      
      [urgency=low]
      border-color=#74b9ff
      default-timeout=1000
      
      [urgency=normal]
      border-color=#74b9ff
      default-timeout=2000
      
      [urgency=critical]
      border-color=#e17055
      background-color=#2d1b1b
      default-timeout=0
    '';
  };

  # Notification-related packages
  home.packages = with pkgs; [
    mako
    libnotify
  ];

  # Optional: Add notification keybindings here
  # This would be merged with Sway's keybindings
  wayland.windowManager.sway.config.keybindings = let
    modifier = "Mod4";
  in {
    # Notification controls
    "${modifier}+n" = "exec ${pkgs.mako}/bin/makoctl dismiss";
    "${modifier}+Shift+n" = "exec ${pkgs.mako}/bin/makoctl dismiss --all";
    "${modifier}+Ctrl+n" = "exec ${pkgs.mako}/bin/makoctl restore";
  };
}