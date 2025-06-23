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

    # Multiple scripts
    (writeShellScriptBin "sway-tree" (builtins.readFile ./scripts/sway-tree.sh))
    (writeShellScriptBin "nixos-update" (builtins.readFile ./scripts/nixos-update.sh))
    (writeShellScriptBin "nixos-deploy" (builtins.readFile ./scripts/nixos-deploy.sh))
    (writeShellScriptBin "sway-screenshot" (builtins.readFile ./scripts/sway-screenshot.sh))
    (writeShellScriptBin "tmux-logging" (builtins.readFile ./scripts/tmux-logging.sh))
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
    ./modules/cloud.nix
  ];

  # Fixed username for NixOS
  home.username = "terp";
  home.homeDirectory = "/home/terp";

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

  # Home Manager configuration
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
