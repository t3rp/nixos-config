{ config, pkgs, ... }:

{
  # General applications and utilities
  home.packages = with pkgs; [
    neofetch # for reddit points
    adwaita-qt # Adwaita dark theme for QT
    zip # zip/unzip
    xz # xz compression
    unzip # unzip
    p7zip # 7z compression
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    mtr # A network diagnostic tool
    iperf3 # A tool for active measurements of the maximum achievable bandwidth
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses
    tcpdump # A powerful command-line packet analyzer
    file # A command-line file type identifier
    which # A command-line utility to locate a command
    tree # A recursive directory listing command that produces a depth-indented listing of files
    gnused # GNU version of the s command
    gnutar # GNU version of the tar command
    gawk # GNU version of the awk command
    zstd # Zstandard compression
    gnupg # GNU Privacy Guard
    nix-output-monitor # A tool to monitor the output of a Nix build
    glow # markdown previewer in terminal
    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files
    sysstat # system performance monitoring
    lm_sensors # for `sensors` command
    ethtool # for `ethtool` command
    pciutils # lspci
    usbutils # lsusb
    nemo # A file manager for the Cinnamon desktop environment
    ranger # A console file manager with VI key bindings
    neovim # A text editor based on Vim
    nnn # terminal file manager
    discord # A VoIP and instant messaging social platform
    signal-desktop # A cross-platform encrypted messaging service for Congress
    python3 # Python 3, latest stable version
    obsidian # A note-taking and knowledge management application
    spotify # A digital music service that gives you access to millions of songs
    bitwarden # A password manager
    firefox # A web browser
    slack # A collaboration hub
    zoom-us # A video conferencing tool
    vlc # A video conferencing tool
    act # a tool to run GitHub Actions locally
  ];
}