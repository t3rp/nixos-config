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
    homeswitch = "cd ${configPath}/users && home-manager switch -f common.nix";
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

  # Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      # Source Nix profiles
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
      
      # Load bash functions
      if [ -d "$HOME/.bash_functions" ]; then
        for f in "$HOME/.bash_functions"/*.sh; do
          [ -e "$f" ] && source "$f"
        done
      fi
    '';
    shellAliases = myShellAliases;
  };

  # ZSH - REVERT: Use initExtra for older Home Manager versions
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # CHANGED BACK: initContent -> initExtra for compatibility
    initExtra = ''
      # Source Nix profile
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
      if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi
      
      # Add custom bin directories to PATH
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.bin"
      # Load bash functions (works in zsh too)
      for f in $HOME/.bash_functions/*.sh; do
        [ -e "$f" ] && source "$f"
      done
    '';
    
    shellAliases = myShellAliases;
  };
}