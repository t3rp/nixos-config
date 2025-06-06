{
  description = "NixOS Multi-host Configuration";

  # Update flakes: nix flake update
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
      
      # Linux
      "anon@linux" = let
        username = "anon";
        system = "x86_64-linux";
      in home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { 
          inherit username system; 
        };
        modules = [
          ./users/common.nix
          ./users/modules/i3.nix
          {
            targets.genericLinux.enable = true;
            home.username = username;
            home.homeDirectory = "/home/${username}";
          }
        ];
      };

      # macOS
      "terp@mac" = let
        username = "terp";
        system = "x86_64-darwin"; # or "aarch64-darwin" for Apple Silicon
      in home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { 
          inherit username system; 
        };
        modules = [
          ./users/common.nix
          {
            home.username = username;
            home.homeDirectory = "/Users/${username}";
          }
        ];
      };
    };
  };
}
