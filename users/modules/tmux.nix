{ 
  config, 
  pkgs, 
  ... 
}:

let
  tmuxConfigPath = "${config.home.homeDirectory}/.config/tmux/tmux.conf";
in
{
  programs.tmux = {
    enable = true;
    historyLimit = 1337000;
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    
    # Plugins
    plugins = with pkgs.tmuxPlugins; [
      yank
      logging
      cpu
      battery
    ];
    
    # Extras
    extraConfig = ''
      # Set status bar to match terminal background
      set -g status-style "bg=default,fg=default"
      set -g status-left-style "bg=default,fg=default"
      set -g status-right-style "bg=default,fg=default"
      
      # Window status colors to match terminal
      set -g window-status-style "bg=default,fg=default"
      set -g window-status-current-style "bg=default,fg=brightwhite,bold"
      set -g window-status-activity-style "bg=default,fg=yellow"
      
      # Pane borders to match terminal
      set -g pane-border-style "fg=brightblack"
      set -g pane-active-border-style "fg=brightwhite"
      
      # Message colors to match terminal
      set -g message-style "bg=default,fg=default"
      set -g message-command-style "bg=default,fg=default"
      
      # Simple status bar with font icons (CPU and memory only)
      set -g status-left "#[fg=brightwhite,bold] #S "
      set -g status-right "#[fg=default]  #(top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | sed 's/%us,//')  #(free | grep Mem | awk '{printf \"%.1f%%\", $3/$2 * 100.0}') %H:%M %b-%d "

      # Vim-like pane switching
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes with vim keys (repeatable)
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1

      # Renumber windows when a window is closed
      set -g renumber-windows on

      # Enable activity alerts
      setw -g monitor-activity on
      set -g visual-activity on

      # Copy mode improvements
      # bind v copy-mode
      # bind-key -T copy-mode-vi v send-keys -X begin-selection
      # bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      # bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

      # Fixing copy/paste to system clipboard - FIXED SYNTAX
      # bind -Tcopy-mode-vi C-j send -X copy-pipe-and-cancel "${pkgs.xsel}/bin/xsel -i"
      # bind -Tcopy-mode-vi Enter send -X copy-pipe-and-cancel "${pkgs.xsel}/bin/xsel -i"
      # bind -Tcopy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "${pkgs.xsel}/bin/xsel -i"

      # Reload - FIXED ESCAPING
      bind r source-file ${tmuxConfigPath} \; display-message "Config reloaded..."

      # Automatic, don't log big stuff like btop
      set-hook -g session-created 'run tmux-logging.sh'
      set-hook -g after-new-window 'run tmux-logging.sh' 
      set-hook -g after-split-window 'run tmux-logging.sh'

      # Bind Prefix+l to run zsh-logging.sh and show a status message
      bind l run-shell "${config.home.homeDirectory}/.config/scripts/zsh-logging.sh; tmux display-message 'CSV Logging Started..."
    '';
  };
}