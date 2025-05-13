{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    historyLimit = 1337000;
    # Plugins
    # https://search.nixos.org/packages?channel=unstable&show=tmuxPlugins&from=0&size=50&sort=relevance&type=packages&query=tmuxPlugins
    plugins = with pkgs.tmuxPlugins; [
        yank
        logging
        onedark-theme
    ];
    # Extra options
    extraConfig = ''
        # Mouse support
        set -g mouse on

        # Easier reload of config
        bind r source-file ~/.config/tmux/tmux.conf
    '';
  };
}