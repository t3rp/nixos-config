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
      
      # Workstation ARES with integrated Home Manager
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

    # Standalone Home Manager configurations
    homeConfigurations = {
      # NixOS user (for standalone use)
      "terp@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { username = "terp"; };
        modules = [
          ./users/home-nixos.nix
        ];
      };

      # Generic Linux (auto-detect username)
      "auto@linux" = let
        currentUser = builtins.getEnv "USER";
      in home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { username = currentUser; };
        modules = [
          ./users/home-linux.nix
          { targets.genericLinux.enable = true; }
        ];
      };

      # CI configuration
      "auto@ci" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { username = "runner"; };
        modules = [
          ./users/home-ci.nix
          { targets.genericLinux.enable = true; }
        ];
      };
    };
  };
}
