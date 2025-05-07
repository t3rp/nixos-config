{ config, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    networks.default = {
      autostart = true;
      # Optionally, you can specify a custom XML file:
      # xml = builtins.readFile ./default-network.xml;
    };
  };
}