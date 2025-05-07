{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  # Connect to both `qemu:///system` and `qemu:///session` in virt-manager
}