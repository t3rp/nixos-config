{ config, pkgs, ... }:

{
  # SwayWM
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      swaylock # screen locker
      swayidle # screen locker
      wl-clipboard # clipboard manager
      wf-recorder # screen recorder
      mako # notification daemon
      grim # screenshot tool
      slurp # screenshot tool
      wmenu # menu for sway
      wofi # dmenu replacement
      dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
      waybar # Status bar for sway
      xdg-user-dirs # xdg user directories -> for screenshots
      jq # required for screenshots
      libnotify # required for notifications on screenshots
      feh # image viewer for sway screenshots
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