{ 
  config, 
  pkgs, 
  ... 
}:

let
  tmuxConfigPath = "${config.home.homeDirectory}/.config/tmux/tmux.conf";
in
{
  # Packages
  home.packages = with pkgs; [
    wl-clipboard
    xsel
    xclip
  ];

  # TMUX Configuration
  programs.tmux = {
    enable = true;
    historyLimit = 1337000;
    mouse = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    baseIndex = 1;
    clock24 = true;
    
    # Remove yank plugin - we'll use native tmux clipboard integration
    plugins = with pkgs.tmuxPlugins; [
      logging
      cpu
      battery
    ];
    
    extraConfig = ''
      # Enable clipboard
      set -g set-clipboard on

      # Copy mode
      bind v copy-mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'r' send -X rectangle-toggle
      
      # X11 clipboard integration
      bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "${pkgs.xclip}/bin/xclip -selection clipboard"
      bind-key -T copy-mode-vi Enter send -X copy-pipe-and-cancel "${pkgs.xclip}/bin/xclip -selection clipboard"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "${pkgs.xclip}/bin/xclip -selection clipboard"
      
      # Paste from X11 clipboard
      bind p run "${pkgs.xclip}/bin/xclip -selection clipboard -o | tmux load-buffer - && tmux paste-buffer"

      # Reload TMUX configuration
      bind r source-file ${tmuxConfigPath} \; display-message "TMUX Configuration Reloaded..."

      # Automatic logging
      set-hook -g session-created 'run tmux-logging'
      set-hook -g after-new-window 'run tmux-logging' 
      set-hook -g after-split-window 'run tmux-logging'

      # Bind Prefix+l to run zsh-logging.sh and show a status message
      bind l send-keys 'source zsh-logging; tmux display-message "CSV Logging Started..."' C-m
    '';
  };
}