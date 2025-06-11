#!/usr/bin/env bash
# ~/.local/bin/nixos-update (make it executable)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔄 Starting NixOS update process...${NC}"

# 1. Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# 2. Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Uncommitted changes detected. Committing current state...${NC}"
    git add .
    git commit -m "chore: save work before system update"
fi

# 3. Update flake.lock
echo -e "${YELLOW}📦 Updating flake inputs...${NC}"
nix flake update

# 4. Show what changed
echo -e "${YELLOW}📋 Flake changes:${NC}"
git diff flake.lock

# 5. Test build
echo -e "${YELLOW}🔨 Testing system build...${NC}"
sudo nixos-rebuild build --flake .#ares

# 6. Get current generation info
OLD_SYSTEM_GEN=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n1 | awk '{print $1}')
OLD_HM_GEN=$(home-manager generations | head -n1 | awk '{print $5}')

# 7. Apply system changes
echo -e "${YELLOW}🚀 Applying system changes...${NC}"
sudo nixos-rebuild switch --flake .#ares

# 8. Apply home-manager changes
echo -e "${YELLOW}🏠 Applying home-manager changes...${NC}"
home-manager switch --flake .#terp@nixos

# 9. Get new generation info
NEW_SYSTEM_GEN=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n1 | awk '{print $1}')
NEW_HM_GEN=$(home-manager generations | head -n1 | awk '{print $5}')

# 10. Commit the update with generation info
NIXOS_VERSION=$(nixos-version)
COMMIT_MSG="update: flake inputs and system configuration

- System generation: ${OLD_SYSTEM_GEN} → ${NEW_SYSTEM_GEN}
- Home Manager generation: ${OLD_HM_GEN} → ${NEW_HM_GEN}
- NixOS version: ${NIXOS_VERSION}
- Updated: $(date '+%Y-%m-%d %H:%M:%S')"

git add flake.lock
git commit -m "$COMMIT_MSG"

echo -e "${GREEN}✅ Update complete and committed!${NC}"
echo -e "${GREEN}🧹 Cleaning old generations...${NC}"

# 11. Clean old generations
sudo nix-collect-garbage --delete-older-than 7d
home-manager expire-generations "-7 days"

echo -e "${GREEN}🎉 All done!${NC}"