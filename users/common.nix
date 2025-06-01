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
  
  # Define shell aliases
  myShellAliases = {
    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    nixswitch = "sudo nixos-rebuild switch --flake .#$(hostname)";
    homeswitch = "cd /home/terp/nixos-config/users && home-manager switch -f home.nix";
    nixfull = "nixswitch && homeswitch";
  };
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
  ];

  # Home Manager configuration
  #   home.file = {
  #   ".config/sway/config" = { source = ./config/sway/config; };
  #   ".config/mako/config" = { source = ./config/alacritty/alacritty.toml; };
  #   ".config/wofi/config" = { source = ./config/wofi/config; };
  #   ".config/wofi/style.css" = { source = ./config/wofi/style.css; };
  #   ".config/waybar/config" = { source = ./config/waybar/config; };
  #   ".config/alacritty/alacritty.toml" = { source = ./config/alacritty/alacritty.toml; };
  # };

  # Link script files
  home.file.".bin" = {
    source = ./scripts;
    recursive = true;   # link recursively
    executable = true;  # make all files executable
  };

  # Link script files
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

  # GitHub.com configuration for t3rp
  # Split this into a module soon
  programs.git = {
    enable = true;
    userName = "t3rp";
    userEmail = "190659213+t3rp@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519_sk.pub";
    };
  };

  # VSCode configuration
  # Also as a module soon under development
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python # Python support
      redhat.vscode-yaml # YAML support
      ms-vscode.cpptools # C/C++ support
      ms-vscode.cmake-tools # CMake support
      ms-vscode.makefile-tools # Makefile support
      golang.go # Go support
      rust-lang.rust-analyzer # Rust support
      jnoortheen.nix-ide # Nix IDE support
    ];
    userSettings = {
      "editor.rulers" = [ 80 120 ];
    };
  };

  # Starship fancy PS1
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
    };
  };

  # Bash
  # Clean these up, don't need the recurse reference, handle above
   programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      # Add custom bin directories to PATH
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.bin"
      # Load bash functions
      for f in $HOME/.bash_functions/*.sh; do
        [ -e "$f" ] && source "$f"
      done
    '';
    profileExtra = ''
      # Source Nix profile for login shells
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
      # Source .bashrc for login shells
      if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
      fi
    '';
    shellAliases = myShellAliases;
  };

  # ZSH
  # Same as bash
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      # Add custom bin directories to PATH
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.bin"
      # Load bash functions (works in zsh too)
      for f in $HOME/.bash_functions/*.sh; do
        [ -e "$f" ] && source "$f"
      done
    '';
    profileExtra = ''
      # Source Nix profile for login shells
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
      # Source .zshrc for login shells
      if [ -f "$HOME/.zshrc" ]; then
        . "$HOME/.zshrc"
      fi
    '';
    shellAliases = myShellAliases;
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