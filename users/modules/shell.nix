{ config, 
  lib, 
  pkgs, 
  ... 
}:

let
  # Get current user and config path dynamically
  username = config.home.username;
  configPath = "${config.home.homeDirectory}/nixos-config";
  
  # Define shell aliases with dynamic paths
  myShellAliases = {
    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    nixswitch = "sudo nixos-rebuild switch --flake ${configPath}#$(hostname)";
    homeswitch = "cd ${configPath}/users && home-manager switch -f home.nix";
    nixfull = "nixswitch && homeswitch";
  };
in
{
  
  # Starship fancy PS1
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
    };
  };

  # Bash with proper Home Manager integration
  programs.bash = {
    enable = true;
    enableCompletion = true;
    
    # Add to .bashrc
    bashrcExtra = ''
      # Source Home Manager session variables
      [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && \
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
    
    # Add to .bash_profile
    profileExtra = ''
      # Source Nix profile
      [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && \
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      
      # Source Home Manager session variables
      [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && \
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      
      # Export XDG paths for desktop integration
      export XDG_DATA_DIRS="$HOME/.nix-profile/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
      export XDG_CONFIG_DIRS="$HOME/.nix-profile/etc/xdg:''${XDG_CONFIG_DIRS:-/etc/xdg}"
    '';
    
    shellAliases = myShellAliases;
  };

  # ZSH with proper Home Manager integration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # Add to .zshrc
    initExtra = ''
      # Source Home Manager session variables
      [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && \
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
    
    # Add to .zprofile (login shell)
    # initExtra
    profileExtra = ''
      # Source Nix profile
      [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && \
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      
      # Source Home Manager session variables
      [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && \
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      
      # Export XDG paths for desktop integration
      export XDG_DATA_DIRS="$HOME/.nix-profile/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
      export XDG_CONFIG_DIRS="$HOME/.nix-profile/etc/xdg:''${XDG_CONFIG_DIRS:-/etc/xdg}"
    '';
    
    shellAliases = myShellAliases;
  };
}