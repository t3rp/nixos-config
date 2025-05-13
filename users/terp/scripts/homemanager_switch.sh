home-manager switch \
  --option home.username "terp" \
  --option home.homeDirectory "/home/terp" \
  -f $HOME/nixos-config/users/terp/home.nix \
  -b backup