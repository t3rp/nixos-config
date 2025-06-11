#!/usr/bin/env bash
# Community standard script for NixOS + Home Manager deployment with Git integration

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly FLAKE_PATH="."
readonly SYSTEM_TARGET="ares"
readonly HOME_TARGET="terp@nixos"

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not in a git repository"
    fi
    
    if [[ $(git status --porcelain) ]]; then
        warn "Working directory has uncommitted changes"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Capture pre-deployment state
capture_pre_state() {
    log "Capturing pre-deployment state..."
    
    # Git information
    COMMIT_HASH=$(git rev-parse HEAD)
    COMMIT_SHORT=$(git rev-parse --short HEAD)
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    COMMIT_MSG=$(git log -1 --pretty=%s)
    
    # Generation information
    OLD_SYSTEM_GEN=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n1 | awk '{print $1}')
    OLD_HM_GEN=$(home-manager generations | head -n1 | awk '{print $5}' 2>/dev/null || echo "none")
    
    log "Branch: $BRANCH"
    log "Commit: $COMMIT_SHORT ($COMMIT_MSG)"
    log "Current System Generation: $OLD_SYSTEM_GEN"
    log "Current Home Manager Generation: $OLD_HM_GEN"
}

# Test builds before deployment
test_builds() {
    log "Testing builds..."
    
    log "Testing NixOS build..."
    if ! sudo nixos-rebuild build --flake "$FLAKE_PATH#$SYSTEM_TARGET"; then
        error "NixOS build failed"
    fi
    
    log "Testing Home Manager build..."
    if ! home-manager build --flake "$FLAKE_PATH#$HOME_TARGET"; then
        error "Home Manager build failed"
    fi
    
    success "All builds successful"
}

# Deploy changes
deploy() {
    log "Deploying changes..."
    
    log "Deploying NixOS configuration..."
    if ! sudo nixos-rebuild switch --flake "$FLAKE_PATH#$SYSTEM_TARGET"; then
        error "NixOS deployment failed"
    fi
    
    log "Deploying Home Manager configuration..."
    if ! home-manager switch --flake "$FLAKE_PATH#$HOME_TARGET"; then
        error "Home Manager deployment failed"
    fi
    
    success "Deployment completed"
}

# Capture post-deployment state and create records
finalize_deployment() {
    log "Finalizing deployment..."
    
    # New generation information
    NEW_SYSTEM_GEN=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n1 | awk '{print $1}')
    NEW_HM_GEN=$(home-manager generations | head -n1 | awk '{print $5}' 2>/dev/null || echo "none")
    NIXOS_VERSION=$(nixos-version)
    DEPLOY_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create deployment record
    DEPLOY_TAG="deploy-$(date +%Y%m%d-%H%M%S)"
    TAG_MESSAGE="Deployment Record

Git Information:
- Branch: $BRANCH
- Commit: $COMMIT_HASH
- Message: $COMMIT_MSG

Generation Changes:
- System: $OLD_SYSTEM_GEN → $NEW_SYSTEM_GEN
- Home Manager: $OLD_HM_GEN → $NEW_HM_GEN

System Information:
- NixOS Version: $NIXOS_VERSION
- Hostname: $(hostname)
- Deploy Time: $DEPLOY_TIME
- User: $(whoami)"
    
    # Create Git tag with deployment information
    if git tag -a "$DEPLOY_TAG" -m "$TAG_MESSAGE" 2>/dev/null; then
        success "Created deployment tag: $DEPLOY_TAG"
    else
        warn "Failed to create Git tag (non-fatal)"
    fi
    
    # Log deployment summary
    echo
    echo "🎉 Deployment Summary:"
    echo "   Commit:     $COMMIT_SHORT"
    echo "   System:     $OLD_SYSTEM_GEN → $NEW_SYSTEM_GEN"
    echo "   Home Mgr:   $OLD_HM_GEN → $NEW_HM_GEN"
    echo "   Tag:        $DEPLOY_TAG"
    echo "   Time:       $DEPLOY_TIME"
    echo
    
    # Optional: Add to deployment log
    DEPLOY_LOG="$HOME/.nixos-deployments.log"
    echo "$(date -Iseconds) | $COMMIT_SHORT | sys:$OLD_SYSTEM_GEN→$NEW_SYSTEM_GEN | hm:$OLD_HM_GEN→$NEW_HM_GEN | $DEPLOY_TAG" >> "$DEPLOY_LOG"
    
    success "Deployment record saved to $DEPLOY_LOG"
}

# Main execution
main() {
    log "Starting NixOS deployment process..."
    
    check_prerequisites
    capture_pre_state
    test_builds
    deploy
    finalize_deployment
    
    success "Deployment process completed successfully!"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: nixos-deploy [options]"
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo "  --dry-run     Test builds without deploying"
        exit 0
        ;;
    --dry-run)
        log "Dry run mode - testing builds only"
        check_prerequisites
        capture_pre_state
        test_builds
        success "Dry run completed - builds are ready for deployment"
        exit 0
        ;;
    *)
        main
        ;;
esac