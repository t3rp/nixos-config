# Home manager configuration

{ 
  config,
  pkgs,
  lib,
  username ? "terp",
  system ? null,
  ... 
}:

let
  # Use passed system or fall back to builtins.currentSystem
  actualSystem = if system != null then system else builtins.currentSystem;
  isDarwin = builtins.match ".*-darwin" actualSystem != null;
  isLinux = builtins.match ".*-linux" actualSystem != null;
  
  # Get home directory from environment (renamed to avoid conflicts)
  envHomeDirectory = builtins.getEnv "HOME";
  
  # Use the passed username parameter directly
  effectiveUsername = username;
  
  # NixOS detection
  isNixOS = builtins.pathExists /etc/os-release && 
    (builtins.match ".*ID=nixos.*" (builtins.readFile /etc/os-release) != null);
in
{
  # Username/HomeDir - use mkDefault so flake config can override
  home.username = lib.mkDefault effectiveUsername;
  home.homeDirectory = lib.mkDefault (
    if envHomeDirectory != "" then envHomeDirectory else 
    (if isDarwin then "/Users/${effectiveUsername}" else "/home/${effectiveUsername}")
  );
  
  # Allow unfree packages (for VSCode)
  nixpkgs.config.allowUnfree = true;
  
  imports = [
    ./modules/general.nix
    ./modules/tmux.nix
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/vscode.nix
  ] ++ lib.optionals isDarwin [
    # Darwin/macOS-specific
  ] ++ lib.optionals (isLinux && !isNixOS) [
    # Standalone Linux systems (Debian, Ubuntu, Kali, etc.)
    ./modules/i3.nix
  ] ++ lib.optionals isNixOS [
    # NixOS-specific integration
  ];

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

  # MERGED: Single sessionVariables definition
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  } // lib.optionalAttrs isLinux {
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "Adwaita-Dark";
  } // lib.optionalAttrs isDarwin {
    # Darwin-specific environment variables if needed
    # HOMEBREW_NO_AUTO_UPDATE = "1";
  };

  # Desktop integration for GNOME/other DEs
  targets.genericLinux.enable = lib.mkIf (isLinux && !isNixOS) true;
  
  # XDG integration - crucial for desktop environments
  xdg = {
    enable = true;
    
    # Ensure desktop files are properly linked
    desktopEntries = lib.mkIf isLinux {
      # This ensures .desktop files are created/linked properly
    };
  };

  # GTK and icon theme - only enable on Linux
  gtk = lib.mkIf isLinux {
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

  # QT Adwaita Dark - only enable on Linux
  qt = lib.mkIf isLinux {
    enable = true;
    platformTheme.name = "gtk";
  };

  # Services that require D-Bus - disable on Darwin
  services = lib.mkIf isLinux {
    ssh-agent = {
      enable = true;
    };
  } // lib.optionalAttrs isDarwin {
    ssh-agent = {
      enable = true;
    };
  };

  # Packages that vary by platform/system
  home.packages = with pkgs; [
    # Universal packages (work everywhere)
  ] ++ lib.optionals isDarwin [
    # macOS-specific packages
  ] ++ lib.optionals (isLinux && !isNixOS) [
    # Non-NixOS Linux specific packages
  ] ++ lib.optionals isNixOS [
    # NixOS-specific packages (if any)
  ];

  # Nix configuration for user
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}