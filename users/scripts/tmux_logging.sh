#!/usr/bin/env bash

# Generate human-readable timestamp for filename
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# Start logging with timestamp in filename
tmux pipe-pane -o "exec bash -c \"while IFS= read -r line; do printf '%%(%%Y%%m%%dT%%H%%M%%S%%z)T: %%s\n' -1 '\$line'; done; exec cat >> ./tmux-#S-#W-#I-#P-${TIMESTAMP}.log\"" \; display-message "Started logging to tmux-#S-#W-#I-#P-${TIMESTAMP}.log"