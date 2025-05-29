{
  description = "NixOS Multi-host Configuration";

  # Update flakes: nix flake update
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = inputs@{ self, nixpkgs, ... }: {
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
  };
}
