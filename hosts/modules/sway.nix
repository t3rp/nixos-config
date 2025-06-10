{
  config,
  pkgs,
  ...
}:

{
  # SwayWM
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      xdg-desktop-portal-wlr  # Required for screen sharing
      xdg-desktop-portal-gtk  # Required for file dialogs
    ];
  # https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start
  # https://github.com/swaywm/sway/issues/5732
  # https://utcc.utoronto.ca/~cks/space/blog/linux/XdgDesktopPortalSlownessWhy
    extraSessionCommands = ''
      eval "$(${pkgs.openssh}/bin/ssh-agent -s)"
      exec ${pkgs.sway}/bin/sway --unsupported-gpu
    '';
  };
}
