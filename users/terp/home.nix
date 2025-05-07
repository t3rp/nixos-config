{ config, pkgs, username ? builtins.getEnv "USER", ... }:

# Username is an optional argument, if not provided it will default to the current user
# This is useful for testing the configuration without needing to specify the username
# Or when moving the configuration to a different user on a different machine

{
  # User configuration
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Home Manager configuration
  home.file = {
    # Sway configuration
    ".config/sway/config" = { 
      source = ./config/sway/config;
    };
    # tmux configuration
    ".config/tmux/tmux.conf" = {
      source = ./config/tmux/tmux.conf;
    };
    # wofi launcher configuration
    ".config/wofi/config" = {
      source = ./config/wofi/config;
    };
    # wofi launcher configuration
    ".config/wofi/style.css" = {
      source = ./config/wofi/style.css;
    };
    # waybar configuration
    ".config/waybar/config" = {
      source = ./config/waybar/config;
    };
    # alacritty configuration
    ".config/alacritty/alacritty.toml" = {
      source = ./config/alacritty/alacritty.toml;
    };
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
    xfce.thunar # A file manager for the Xfce desktop environment
    nemo # A file manager for the Cinnamon desktop environment
    kdePackages.dolphin # A file manager for the KDE desktop environment
    ranger # A console file manager with VI key bindings
    neovim # A text editor based on Vim
    nnn # terminal file manager
    discord # A VoIP and instant messaging social platform
    signal-desktop # A cross-platform encrypted messaging service for Congress
    python3 # Python 3, latest stable version
    obsidian # A note-taking and knowledge management application
    spotify # A digital music service that gives you access to millions of songs
    discord # A VoIP and instant messaging social platform
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
  
  # VSCode
  # Manage plugins and settings for Visual Studio Code
  # Keeping extensions updated is a struggle
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      bbenoist.nix
    ];
  };

  # Starship fancy PS1
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      line_break.disabled = true;
    };
  };

  # Bash and path configuration
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

    # Aliases for bash
    shellAliases = {
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      nixswitch = "sudo nixos-rebuild switch --flake .#$(hostname)";
      nixbuild = "sudo nixos-rebuild build --flake .#$(hostname)";
    };
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
