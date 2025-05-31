#!/usr/bin/env bash
# Autologging for TMUX - Will generate large files if you run btop etc
tmux pipe-pane -o 'exec bash -c "while IFS= read -r line; do printf \"%%(%%Y%%m%%dT%%H%%M%%S%%z)T: %%s\n\" -1 \"\$line\"; done"\; exec cat >> #S-#W-#I-#P.log' \; display-message 'Started logging to #S-#W-#I-#P.log'
