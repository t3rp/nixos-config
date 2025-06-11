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
    ./modules/sway.nix
    ./modules/mako.nix
    ./modules/darkness.nix
  ];

  # Fixed username for NixOS
  home.username = "terp";
  home.homeDirectory = "/home/terp";

  # Link script files
  home.file.".bin" = {
    source = ./scripts;
    recursive = true;
    executable = true;
  };

  # Link function files
  home.file.".bash_functions" = {
    source = ./functions;
    recursive = true;
    executable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Font configuration
  fonts.fontconfig.enable = true;

  # Home Manager configuration
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
