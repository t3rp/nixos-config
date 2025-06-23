#!/usr/bin/env bash

# Where logs
LOG_DIR="$HOME/Logs"
if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
fi

# Generate timestamp for filename
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Simpler version that works reliably
tmux pipe-pane -o "while read line; do echo \"\$(date +'%Y%m%dT%H%M%S%z'): \$line\"; done >> ${LOG_DIR}/tmux-#S-#W-#I-#P-${TIMESTAMP}.log" \; display-message "Started logging to ${LOG_DIR}/tmux-#S-#W-#I-#P-${TIMESTAMP}.log"