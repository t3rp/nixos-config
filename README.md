# NixOS Multiple Systems Configuration Flake

- I don't know what I'm doing
- This setup has been stable for me, running this for over a year
- I do most of my work within a VM, e.g. Debian, Kali
- My system configuration philosophy is to keep it simple, defaults where possible
- Copy and paste at your own peril

## Resources

I typically use these references when looking for answers, in order:

- [NixOS & Flakes by Ryan Yin](https://nixos-and-flakes.thiscute.world/)
- [MyNixOS](https://mynixos.com/)
- [Official NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Reference Manual (Language)](https://nix.dev/manual/nix/2.26/language/)

## Lessons Learned

- Home-manager may fail if it finds a file that already exist, but when running `nixos-rebuild` the output does not show what file/s need moved. The command `journalctl -xe --unit home-manager-terp.service` provides more complete output and allows you to find the offending files. If running in standalone mode you can add `-b backup` and it will backup the file in place.