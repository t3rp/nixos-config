#!/usr/bin/env bash
# Search for packages in Nixpkgs

nixsearch() {
  # Check if arguments provided
  if [[ $# -eq 0 ]]; then
    echo "Usage: nixsearch <package>"
    return 1
  fi
  
  # Use zsh-compatible parameter expansion
  local search_term="$*"
  
  echo "Searching for: $search_term"
  nix search nixpkgs "$search_term"
}

# Make function available immediately
nixsearch "$@"