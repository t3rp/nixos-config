# Home manager configuration

{ 
  config,
  pkgs,
  lib,
  ... 
}:

let
  # Username detection
  username = builtins.getEnv "USER";

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

  # Username and home directoryh
  home.username = username;
  home.homeDirectory =
    if isLinux then "/home/${username}" else
    if isDarwin then "/Users/${username}" else unsupported;

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