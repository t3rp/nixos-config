# Home manager configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Packages
  home.packages = with pkgs; [
    # Comprehensive font packages for icon support
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "FiraMono"
      ];
    })
    font-awesome_6
    material-design-icons
    material-symbols
    fontconfig
    liberation_ttf
  ];

  # NixOS-specific imports (Sway for NixOS)
  imports = [
    ./modules/general.nix
    ./modules/tmux.nix
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/vscode.nix
    ./modules/mako.nix
    ./modules/darkness.nix
    ./modules/cloud.nix
  ];

  # Linux
  home.username = "anon";
  home.homeDirectory = "/home/anon";

  # ZSH functions
  home.file.".zsh_functions" = {
    source = ./functions;
    recursive = true;
    executable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Font configuration
  fonts.fontconfig.enable = true;

  # Enable Nix package manager
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Home Manager configuration
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
