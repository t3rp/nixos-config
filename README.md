# NixOS Multiple Systems Configuration Flake

- I don't know what I'm doing
- This setup has been stable for me, running this for over a year
- I do most of my work within a VM, e.g. Debian, Kali
- My system configuration philosophy is to keep it simple, defaults where possible
- Copy and paste at your own peril

![Is it worth it? - XKCD](xkcd_is_it_worth_it.png)
[XKCD Source](https://xkcd.com/1205/)

## Configuration Structure

```
nixos-config on  main [?] took 6s ❯ tree
├── flake.lock
├── flake.nix
├── hosts
│   └── ares
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── README.md
├── users
│   └── terp
│       ├── home.nix
│       ├── sway.conf
│       └── tmux.conf
└── xkcd_is_it_worth_it.png
```

## Resources that have helped

I typically use these references when looking for answers, in order:

- [NixOS & Flakes by Ryan Yin](https://nixos-and-flakes.thiscute.world/)
- [Official NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Reference Manual (Language)](https://nix.dev/manual/nix/2.26/language/)