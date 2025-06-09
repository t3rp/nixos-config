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
      # Auto-detect current user
      "auto@linux" = let
        currentUser = builtins.getEnv "USER";
      in home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { username = currentUser; };
        modules = [
          ./users/home.nix
          { targets.genericLinux.enable = true; }
        ];
      };

      # Auto-detect current user ci
      "auto@ci" = let
        currentUser = builtins.getEnv "USER";
      in home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { username = currentUser; };
        modules = [
          ./users/home-ci.nix
          { targets.genericLinux.enable = true; }
        ];
      };
    };
  };
}
