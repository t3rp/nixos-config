{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable VSCode
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      # Languages
      ms-python.python
      ms-vscode.cpptools
      rust-lang.rust-analyzer
      golang.go
      ms-dotnettools.csharp

      # Web Development
      bradlc.vscode-tailwindcss
      esbenp.prettier-vscode

      # Configuration & Markup
      jnoortheen.nix-ide
      redhat.vscode-yaml
      ms-vscode.cmake-tools
      ms-vscode.makefile-tools

      # Git & Version Control
      mhutchie.git-graph
      eamodio.gitlens

      # Docker & Container Support
      ms-vscode-remote.remote-containers
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh

      # Themes & UI
      pkief.material-icon-theme
      zhuangtongfa.material-theme
    ];

    userSettings = {
      # Editor Settings
      "editor.rulers" = [ 80 120 ];
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.detectIndentation" = true;
      "editor.wordWrap" = "on";
      "editor.minimap.enabled" = false;
      "editor.renderWhitespace" = "boundary";
      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = true;
      "editor.cursorBlinking" = "smooth";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 14;
      "editor.lineHeight" = 1.5;
      
      # Fix fonts and icons
      "editor.fontFamily" = "'FiraCode Nerd Font', 'FiraMono Nerd Font', 'FontAwesome 6 Free'";
      "terminal.integrated.fontFamily" = "'FiraCode Nerd Font', 'FiraMono Nerd Font', 'FontAwesome 6 Free'";
      
      # Enable font ligatures for better icon rendering
      "terminal.integrated.fontLigatures" = true;

      # Workbench Settings
      "workbench.colorTheme" = "Material Theme Darker High Contrast";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.startupEditor" = "none";
      "workbench.tree.indent" = 20;

      # Security & Telemetry
      "telemetry.telemetryLevel" = "off";
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
    };

    keybindings = [
      {
        key = "ctrl+shift+t";
        command = "workbench.action.terminal.new";
      }
      {
        key = "ctrl+shift+e";
        command = "workbench.view.explorer";
      }
      {
        key = "ctrl+shift+g";
        command = "workbench.view.scm";
      }
    ];
  };
}
