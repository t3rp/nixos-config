#!/usr/bin/env bash
# Search for packages in Nixpkgs
nixsearch() {
  if [ $# -eq 0 ]; then
    echo "Usage: nixsearch <package>"
    return 1
  fi
  nix search nixpkgs "$*"
}