{ config, pkgs, ... }:

{
  # Enable libvirt
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [
      virtiofsd
    ];
    qemu = {
      runAsRoot = false;
      # Enable software TPM support
      swtpm.enable = true;
    };
  };
}
