{
  description = "NixOS Multi-host Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      # Workstation ARES
      ares = let
        username = "terp";
        specialArgs = {inherit username;};
      in nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/ares/configuration.nix
          ./hosts/modules/sway.nix
          ./hosts/modules/nvidia.nix
          ./hosts/modules/libvirtd.nix
        ];
      };
    };

    # Home Manager configurations for standalone use
    homeConfigurations = {
      # Generic configuration that auto-detects username
      "auto@linux" = let
        currentUser = let
          envUser = builtins.getEnv "USER";
          envLogname = builtins.getEnv "LOGNAME";
        in
          if envUser != "" then envUser
          else if envLogname != "" then envLogname
          else "anon";  # fallback to anon
      in home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./users/home.nix
          { targets.genericLinux.enable = true; }
          # Pass username as module argument
          { config._module.args.username = currentUser; }
        ];
      };

      # Specific configuration for Kali
      "anon@kali" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./users/home.nix
          { targets.genericLinux.enable = true; }
          # Explicitly pass username
          { config._module.args.username = "anon"; }
        ];
      };

      # CI configuration
      "auto@ci" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./users/home-ci.nix
          { targets.genericLinux.enable = true; }
          # Pass username for CI
          { config._module.args.username = builtins.getEnv "USER"; }
        ];
      };
    };
  };
}
