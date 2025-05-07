#!/usr/bin/env bash

# Exit on error
set -euo pipefail

# Install Nix package manager
sh <(curl -L https://nixos.org/nix/install)

# Source Nix profile for this session
. "$HOME/.nix-profile/etc/profile.d/nix.sh" 2>/dev/null || \
. "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

# Set up Home Manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Clone your dotfiles repo if not already present
if [ ! -d "$HOME/nixos-config" ]; then
  git clone https://github.com/t3rp/nixos-config.git "$HOME/nixos-config"
fi

cd "$HOME/nixos-config/users/terp"

# Run home manager to set up the environment
home-manager switch

echo "Nix, Home Manager, and your dotfiles are set up!"