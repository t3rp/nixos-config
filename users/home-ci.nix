{ 
  config,
  pkgs,
  lib,
  ... 
}:

let
  username = builtins.getEnv "USER";
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  unsupported = builtins.abort "Unsupported platform";
in

{
  # Minimal imports for CI testing
  imports = [
    ./modules/general.nix
    ./modules/tmux.nix
    ./modules/shell.nix
    ./modules/git.nix
  ];

  # Username and home directory
  home.username = username;
  home.homeDirectory =
    if isLinux then "/home/${username}" else
    if isDarwin then "/Users/${username}" else unsupported;

  # Essential files only
  home.file.".bin" = {
    source = ./scripts;
    recursive = true;
    executable = true;
  };

  home.file.".bash_functions" = {
    source = ./functions;
    recursive = true;
    executable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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