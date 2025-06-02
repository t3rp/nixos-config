{ 
  config, 
  pkgs, 
  lib, 
  ... 
}:

{
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
}