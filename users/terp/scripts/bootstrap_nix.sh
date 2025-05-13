#!/usr/bin/env bash

# Exit on error
set -euo pipefail

# Check if home-manager is already installed
if command -v home-manager &> /dev/null; then
    echo "Home Manager is already installed."
    exit 0
fi

# Install Nix package manager
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
# Uninstall Nix if it was already installed
# sh <(curl -L https://nixos.org/nix/uninstal  # # Backup the current bash.bashrc

# Source Nix profile for this session
. "$HOME/.nix-profile/etc/profile.d/nix.sh" 2>/dev/null || \
. "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

# Set up Home Manager latest
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Clone your dotfiles repo if not already present
if [ ! -d "$HOME/nixos-config" ]; then
  git clone https://github.com/t3rp/nixos-config.git "$HOME/nixos-config"
fi

# Run home manager to set up the environment
home-manager switch -f "$HOME/nixos-config/users/terp/home.nix" -b backup

echo "Nix, Home Manager, and your dotfiles are set up!"