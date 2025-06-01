# NixOS Multiple Systems Configuration Flake

- --I don't know what I'm doing--
- I definitely know what I'm doing
- This setup has been stable for me, running this for over a year
- I do most of my work within a VM, e.g. Debian, Kali
- My system configuration philosophy is to keep it simple, defaults where possible
- Copy and paste at your own peril

## Resources

I typically use these references when looking for answers, in order:

- [NixOS & Flakes by Ryan Yin](https://nixos-and-flakes.thiscute.world/)
- [MyNixOS](https://mynixos.com/)
- [Official NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Reference Manual (Language)](https://nix.dev/manual/nix/2.26/language/)

## Lessons Learned

- Home-manager may fail if it finds a file that already exist, but when running `nixos-rebuild` the output does not show what file/s need moved. The command `journalctl -xe --unit home-manager-terp.service` provides more complete output and allows you to find the offending files. If running in standalone mode you can add `-b backup` and it will backup the file in place.

## Home Manager Basics

- Quick script to bootstrap things

```bash
curl -L https://raw.githubusercontent.com/t3rp/nixos-config/main/bootstrap.sh | sh
```

### Common Commands

```bash
# Apply configuration changes
home-manager switch -f users/common.nix

# Show what would change without applying
home-manager build

# List installed packages
home-manager packages

# Show package generations/history
home-manager generations

# Rollback to previous generation
home-manager rollback

# Remove old generations (cleanup)
home-manager expire-generations "-7 days"

# Check configuration for errors
home-manager build --dry-run
```

### Package Management

```bash
# Update flake inputs (pull latest from GitHub)
nix flake update

# Update specific input only
nix flake update nixpkgs

# Search for packages
nix search nixpkgs firefox
nix search nixpkgs --json python | jq

# Show package information
nix eval nixpkgs#firefox.meta.description

# List all available packages (slow)
nix-env -qaP '*' --description
```

### System Integration

```bash
# Apply both system and home-manager changes
sudo nixos-rebuild switch --flake .#$(hostname)
home-manager switch --flake .#terp

# One command for both (if using NixOS module)
sudo nixos-rebuild switch --flake .#$(hostname)

# Check what's different between configs
nix profile diff-closures --profile /nix/var/nix/profiles/system
```

### Debugging & Troubleshooting

```bash
# Show detailed logs for home-manager service
journalctl --user -xe --unit home-manager-terp.service

# Check which files home-manager manages
home-manager packages | grep -E "\.config|\.local"

# Force backup conflicting files
home-manager switch -b backup

# Remove broken symlinks
find ~ -xtype l -delete

# Check for conflicting files before applying
home-manager build --show-trace
```

### Git Integration

```bash
# Update configuration from git
git pull origin main
nix flake update
home-manager switch --flake .#terp

# Check what changed in flake lock
git diff flake.lock

# Commit configuration changes
git add .
git commit -m "Update home configuration"
git push origin main
```

### Performance & Cleanup

```bash
# Garbage collect old packages
nix-collect-garbage -d

# Remove old home-manager generations
home-manager expire-generations "-30 days"
nix-collect-garbage

# Check disk usage of Nix store
du -sh /nix/store

# Optimize Nix store (deduplicate)
nix-store --optimise
```

