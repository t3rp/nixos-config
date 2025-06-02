# Home manager configuration

{ 
  config,
  lib,
  pkgs,
  ... 
}:

let
  # Detect if we're in a CI environment
  isCI = builtins.getEnv "CI" == "true" || builtins.getEnv "GITHUB_ACTIONS" == "true";
  
  # Get username from environment
  # Fix for home-manager on linux
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";
in
{
  # Required Home Manager configuration - now dynamic with fallback
  home.username = if username != "" then username else "terp";
  home.homeDirectory = if homeDirectory != "" then homeDirectory else "/home/terp";
  
  # Allow unfree packages (for VSCode)
  nixpkgs.config.allowUnfree = true;

  # Imports
  imports = [
    ./modules/general.nix
    ./modules/tmux.nix
    ./modules/sway.nix
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/vscode.nix
  ];

  # Link script files
  home.file.".bin" = {
    source = ./scripts;
    recursive = true;   # link recursively
    executable = true;  # make all files executable
  };

  # Link function files
  home.file.".bash_functions" = {
    source = ./functions;
    recursive = true;   # link recursively
    executable = true;  # make all files executable
  };

  # Environment variables
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "Adwaita-Dark";
  };

  # GTK and icon theme - only enable if not in CI
  gtk = lib.mkIf (!isCI) {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
  };

  # QT Adwaita Dark - only enable if not in CI
  qt = lib.mkIf (!isCI) {
    enable = true;
    platformTheme.name = "gtk";
  };

  # Services that require D-Bus - disable in CI
  services = lib.mkIf (!isCI) {
    # Any services you have configured
  };

  # Nix configuration for user
  # Set this for flakes and nix command, still need env for first run
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}