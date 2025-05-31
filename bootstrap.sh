#!/usr/bin/env bash
# curl -L https://raw.githubusercontent.com/t3rp/nixos-config/main/bootstrap.sh | bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on supported system
check_system() {
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        error "This script only supports Linux systems"
        exit 1
    fi
    
    log "Running on $(uname -a)"
}

# Install Nix if not present
install_nix() {
    if command -v nix &> /dev/null; then
        log "Nix is already installed"
        return 0
    fi
    
    log "Installing Nix..."
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    
    # Source nix for current session
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    
    log "Nix installation completed"
}

# Install Home Manager
install_home_manager() {
    if command -v home-manager &> /dev/null; then
        log "Home Manager is already installed"
        return 0
    fi
    
    log "Installing Home Manager..."
    nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
    
    log "Home Manager installation completed"
}

# Clone configuration repository
clone_config() {
    local config_dir="$HOME/nixos-config"
    
    if [ -d "$config_dir" ]; then
        warn "Configuration directory already exists at $config_dir"
        read -p "Do you want to remove it and re-clone? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$config_dir"
        else
            log "Using existing configuration directory"
            return 0
        fi
    fi
    
    log "Cloning configuration repository..."
    git clone https://github.com/t3rp/nixos-config.git "$config_dir"
    
    log "Configuration cloned to $config_dir"
}

# Apply Home Manager configuration
apply_home_manager() {
    local config_dir="$HOME/nixos-config/users"
    
    log "Applying Home Manager configuration..."
    cd "$config_dir"
    home-manager switch -f home.nix -b backup
    
    log "Home Manager configuration applied successfully"
}

# Update shell configuration for proper Nix integration
update_shell_config() {
    local shell_rc=""
    local current_shell=$(basename "$SHELL")
    
    case "$current_shell" in
        bash)
            shell_rc="$HOME/.bashrc"
            ;;
        zsh)
            shell_rc="$HOME/.zshrc"
            ;;
        *)
            warn "Unsupported shell: $current_shell. Manual configuration may be required."
            return 0
            ;;
    esac
    
    log "Updating $shell_rc for Nix integration..."
    
    # Create backup
    if [ -f "$shell_rc" ]; then
        cp "$shell_rc" "${shell_rc}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Add Nix sourcing if not already present
    if ! grep -q "nix-profile/etc/profile.d/nix.sh" "$shell_rc" 2>/dev/null; then
        cat >> "$shell_rc" << 'EOF'

# Nix integration
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then 
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Home Manager session variables
if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi
EOF
        log "Added Nix integration to $shell_rc"
    else
        log "Nix integration already present in $shell_rc"
    fi
}

# Fix homeswitch alias for current user
fix_homeswitch_alias() {
    local current_user=$(whoami)
    local config_dir="$HOME/nixos-config/users"
    
    if [ "$current_user" != "terp" ]; then
        log "Creating user-specific homeswitch alias..."
        
        # Create a local shell alias file
        mkdir -p "$HOME/.local/bin"
        cat > "$HOME/.local/bin/homeswitch" << EOF
#!/bin/bash
cd $config_dir && home-manager switch -f home.nix
EOF
        chmod +x "$HOME/.local/bin/homeswitch"
        
        log "Created homeswitch script for user '$current_user'"
    fi
}

# Main execution
main() {
    log "Starting automated Home Manager setup..."
    
    check_system
    install_nix
    install_home_manager
    clone_config
    apply_home_manager
    update_shell_config
    fix_homeswitch_alias
    
    log "Setup completed successfully!"
    log "Please restart your terminal or run 'source ~/.${SHELL##*/}rc' to load the new environment"
    log "You can now use 'homeswitch' to update your Home Manager configuration"
}

# Run main function
main "$@"