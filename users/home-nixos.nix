{ 
  config,
  pkgs,
  lib,
  username ? "terp",
  ... 
}:

{
  # NixOS-specific imports (Sway for NixOS)
  imports = [
    ./modules/general.nix
    ./modules/tmux.nix
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/vscode.nix
    ./modules/sway.nix
    ./modules/mako.nix
  ];

  # Fixed username for NixOS
  home.username = username;
  home.homeDirectory = "/home/${username}";

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