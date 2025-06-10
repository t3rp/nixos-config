# Home manager configuration

{ 
  config,
  pkgs,
  lib,
  username ? null,
  ... 
}:

let
  # Username detection with fallback chain
  detectedUsername =
    if username != null then username
    else if (builtins.getEnv "USER") != "" then (builtins.getEnv "USER")
    else if (builtins.getEnv "LOGNAME") != "" then (builtins.getEnv "LOGNAME")
    else builtins.abort "Username could not be determined. Please set USER environment variable or pass username explicitly.";

  # Platform detection
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  unsupported = builtins.abort "Unsupported platform";
in

{
  # Imports
  imports = [
    ./modules/general.nix
    ./modules/tmux.nix
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/vscode.nix
    ./modules/sway.nix
    ./modules/i3.nix
  ];

  # Username and home directory
  home.username = detectedUsername;
  home.homeDirectory =
    if isLinux then "/home/${detectedUsername}" else
    if isDarwin then "/Users/${detectedUsername}" else unsupported;

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

  # Allow unfree packages system-wide
  nixpkgs.config.allowUnfree = true;

  # Disable fontconfig to avoid cache warnings
  fonts.fontconfig.enable = false;

  # Nix configuration
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Home Manager configuration
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}