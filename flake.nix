{
  description = "NixOS Multi-host Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
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
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = inputs // specialArgs;
            home-manager.users.${username} = import ./users/${username}/home.nix;
          }
        ];
      };
      # Droplet Loki C2
      # loki = let
      #   username = "terp";
      #   specialArgs = {inherit username;};
      # in nixpkgs.lib.nixosSystem {
      #   inherit specialArgs;
      #   system = "x86_64-linux";
      #   modules = [
      #     ./hosts/loki/configuration.nix
      #     # make home-manager as a module of nixos
      #     # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
      #     home-manager.nixosModules.home-manager
      #     {
      #       home-manager.useGlobalPkgs = true;
      #       home-manager.useUserPackages = true;
      #       home-manager.extraSpecialArgs = inputs // specialArgs;
      #       home-manager.users.${username} = import ./users/${username}/home.nix;
      #     }
      #   ];
      # };
    };
  };
}
