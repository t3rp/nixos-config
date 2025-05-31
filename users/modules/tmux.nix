{ config, pkgs, ... }:

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
      dracula
    ];
    
    # Your complete tmux configuration
    extraConfig = ''
      # Dracula theme configuration
      set -g @dracula-show-powerline true
      set -g @dracula-show-flags true
      set -g @dracula-show-left-icon session
      set -g @dracula-cpu-usage true
      set -g @dracula-ram-usage true
      set -g @dracula-day-month true
      set -g @dracula-military-time true
      set -g @dracula-git-show-current-symbol ✓
      set -g @dracula-git-show-diff-symbol !
      set -g @dracula-show-timezone false
      set -g @dracula-show-location false
      set -g @dracula-show-weather false

      # Explicitly set what plugins to show and their order
      set -g @dracula-plugins "cpu-usage ram-usage battery time"

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
      bind v copy-mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

      # Fixing copy/paste to system clipboard - FIXED SYNTAX
      bind -Tcopy-mode-vi C-j send -X copy-pipe-and-cancel "${pkgs.xsel}/bin/xsel -i"
      bind -Tcopy-mode-vi Enter send -X copy-pipe-and-cancel "${pkgs.xsel}/bin/xsel -i"
      bind -Tcopy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "${pkgs.xsel}/bin/xsel -i"

      # Reload - FIXED ESCAPING
      bind-key r source-file ~/.config/tmux/tmux.conf \\; display-message "Config reloaded!"

      # Manual logging with datetime in filename
      bind-key o pipe-pane -o 'exec ${pkgs.bash}/bin/bash -c "DATETIME=$(date +%%Y%%m%%d_%%H%%M%%S); while IFS= read -r line; do printf \"%%(%Y%m%dT%H%M%S%z)T: %%s\\n\" -1 \"\\$line\"; done; exec cat >>./tmux-#S-#W-#I-#P-$DATETIME.log"' \\; display-message "Started logging with datetime"
      bind-key O pipe-pane \\; display-message "Ended logging"

      # REMOVED - These cause delays and prevent proper theme loading
      # set-hook -g session-created 'run ~/.bin/tmux_logging.sh'
      # set-hook -g after-new-window 'run ~/.bin/tmux_logging.sh' 
      # set-hook -g after-split-window 'run ~/.bin/tmux_logging.sh'
    '';
  };
}