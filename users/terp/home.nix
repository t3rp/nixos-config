# Home manager configuration

{ 
  config,
  pkgs,
  ... 
}:

let
  # Define shell aliases
  myShellAliases = {
    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    nixswitch = "sudo nixos-rebuild switch --flake .#$(hostname)";
    nixbuild = "sudo nixos-rebuild build --flake .#$(hostname)";
    nixcommit = "nixcommit.sh";
  };
in
{
  # Required Home Manager configuration
  home.username = "terp";
  home.homeDirectory = "/home/terp";
  
  # Allow unfree packages (for VSCode)
  nixpkgs.config.allowUnfree = true;

  # Imports
  imports = [
    ./tmux.nix
  ];

  # Home Manager configuration
    home.file = {
    ".config/sway/config" = { source = ./config/sway/config; };
    ".config/mako/config" = { source = ./config/alacritty/alacritty.toml; };
    ".config/wofi/config" = { source = ./config/wofi/config; };
    ".config/wofi/style.css" = { source = ./config/wofi/style.css; };
    ".config/waybar/config" = { source = ./config/waybar/config; };
    ".config/alacritty/alacritty.toml" = { source = ./config/alacritty/alacritty.toml; };
  };

  # Link script files
  home.file.".bin" = {
    source = ./scripts;
    recursive = true;   # link recursively
    executable = true;  # make all files executable
  };

  # Link script files
  home.file.".bash_functions" = {
    source = ./functions;
    recursive = true;   # link recursively
    executable = true;  # make all files executable
  };

  # Environment variables
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "Adwaita-Dark";
  };

  # GTK and icon theme
    gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
  };

  # QT Adwaita Dark
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  # User profile packages, not on root
  # If you need to run as root use sudo so that it's on path
  home.packages = with pkgs; [
    neofetch # for reddit points
    adwaita-qt # Adwaita dark theme for QT
    tmux # terminal multiplexer
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
    alacritty # A terminal emulator
    firefox # A web browser
    slack # A collaboration hub
    zoom-us # A video conferencing tool
    vlc # A video conferencing tool
    act # a tool to run GitHub Actions locally
  ];

  # GitHub.com configuration for t3rp
  programs.git = {
    enable = true;
    userName = "t3rp";
    userEmail = "190659213+t3rp@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519_sk.pub";
    };
  };

  # VSCode configuration
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python # Python support
      redhat.vscode-yaml # YAML support
      ms-vscode.cpptools # C/C++ support
      ms-vscode.cmake-tools # CMake support
      ms-vscode.makefile-tools # Makefile support
      golang.go # Go support
      rust-lang.rust-analyzer # Rust support
      jnoortheen.nix-ide # Nix IDE support
    ];
    userSettings = {
      "editor.rulers" = [ 80 120 ];
    };
  };

  # Starship fancy PS1
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
    };
  };

  # Bash
   programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      # Add custom bin directories to PATH
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.bin"
      # Load bash functions
      for f in $HOME/.bash_functions/*.sh; do
        [ -e "$f" ] && source "$f"
      done
    '';
    profileExtra = ''
      # Source Nix profile for login shells
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
      # Source .bashrc for login shells
      if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
      fi
    '';
    shellAliases = myShellAliases;
  };

  # ZSH
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      # Add custom bin directories to PATH
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.bin"
      # Load bash functions (works in zsh too)
      for f in $HOME/.bash_functions/*.sh; do
        [ -e "$f" ] && source "$f"
      done
    '';
    profileExtra = ''
      # Source Nix profile for login shells
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
      # Source .zshrc for login shells
      if [ -f "$HOME/.zshrc" ]; then
        . "$HOME/.zshrc"
      fi
    '';
    shellAliases = myShellAliases;
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}