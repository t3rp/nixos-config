#!/usr/bin/env bash

# Create logs directory if it doesn't exist
mkdir -p "$HOME/logs"

# Generate timestamp for filename
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Simpler version that works reliably
tmux pipe-pane -o "while read line; do echo \"\$(date +'%Y%m%dT%H%M%S%z'): \$line\"; done >> ./tmux-#S-#W-#I-#P-${TIMESTAMP}.log" \; display-message "Started logging to ./tmux-#S-#W-#I-#P-${TIMESTAMP}.log"