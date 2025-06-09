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
      # bashrcExtra from Home Manager (NIX)
    '';
    shellAliases = myShellAliases;
  };

  # ZSH - REVERT: Use initExtra for older Home Manager versions
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # CHANGED BACK: initContent -> initExtra for compatibility
    initExtra = ''
      # initExtra from Home Manager (NIX)
    '';
    shellAliases = myShellAliases;
  };
}