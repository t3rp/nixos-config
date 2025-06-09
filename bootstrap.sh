#!/usr/bin/env bash
# curl -L https://raw.githubusercontent.com/t3rp/nixos-config/main/bootstrap.sh | bash

set -euo pipefail

log() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; exit 1; }

# Check system compatibility
[[ "$OSTYPE" == "linux-gnu"* ]] || error "Linux only"

# Install Nix if needed
if ! command -v nix &>/dev/null; then
    log "Installing Nix..."
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    # Source nix for current session
    [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ] && \
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Setup 24.11 channels
log "Setting up 24.11 channels..."
nix-channel --remove nixpkgs 2>/dev/null || true
nix-channel --remove home-manager 2>/dev/null || true
nix-channel --add https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
nix-channel --update

# Install Home Manager
if ! command -v home-manager &>/dev/null; then
    log "Installing Home Manager..."
    export NIX_PATH="${NIX_PATH:-}$HOME/.nix-defexpr/channels"
    nix-shell '<home-manager>' -A install
fi

# Clone config
config_dir="$HOME/nixos-config"
if [ ! -d "$config_dir" ]; then
    log "Cloning configuration..."
    git clone https://github.com/t3rp/nixos-config.git "$config_dir"
fi

# Apply configuration
log "Applying Home Manager configuration..."
cd "$config_dir/users"
export NIX_PATH="${NIX_PATH:-}$HOME/.nix-defexpr/channels"
home-manager switch -f home.nix -b backup

# Setup shell integration
shell_rc="$HOME/.$(basename "$SHELL")rc"
if ! grep -q "nix-profile/etc/profile.d/nix.sh" "$shell_rc" 2>/dev/null; then
    log "Adding Nix integration to shell..."
    cat >> "$shell_rc" << 'EOF'

# Nix integration
[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && . "$HOME/.nix-profile/etc/profile.d/nix.sh"
[ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
EOF
fi

# Create homeswitch wrapper for non-terp users
if [ "$(whoami)" != "terp" ]; then
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/homeswitch" << EOF
#!/bin/bash
export NIX_PATH="\${NIX_PATH:-}\$HOME/.nix-defexpr/channels"
cd "$config_dir/users" && home-manager switch -f home.nix
EOF
    chmod +x "$HOME/.local/bin/homeswitch"
    grep -q ".local/bin" "$shell_rc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
fi

log "✓ Setup complete! Restart your terminal or run: source $shell_rc"
log "✓ Use 'homeswitch' to update your configuration"