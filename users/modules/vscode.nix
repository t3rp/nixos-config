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
      bbenoist.nix
      redhat.vscode-yaml
      ms-vscode.cmake-tools
      ms-vscode.makefile-tools

      # Git & Version Control
      mhutchie.git-graph
      eamodio.gitlens

      # Productivity
      ms-vscode-remote.remote-ssh
      ms-vscode.live-server
      formulahendry.code-runner

      # Themes & UI
      pkief.material-icon-theme
      dracula-theme.theme-dracula
      zhuangtongfa.material-theme
      enkia.tokyo-night

      # Utilities
      ms-vsliveshare.vsliveshare
      streetsidesoftware.code-spell-checker
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
      "editor.fontFamily" = "'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 14;
      "editor.lineHeight" = 1.5;

      # File Settings
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;

      # Workbench Settings
      "workbench.colorTheme" = "One Dark Pro";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.startupEditor" = "none";
      "workbench.editor.enablePreview" = false;
      "workbench.tree.indent" = 20;

      # Terminal Settings
      "terminal.integrated.fontFamily" = "'JetBrains Mono', monospace";
      "terminal.integrated.fontSize" = 14;
      "terminal.integrated.shell.linux" = "${pkgs.zsh}/bin/zsh";

      # Git Settings
      "git.enableSmartCommit" = true;
      "git.confirmSync" = false;
      "git.autofetch" = true;

      # Language-specific Settings
      "[nix]" = {
        "editor.tabSize" = 2;
        "editor.insertSpaces" = true;
      };
      "[python]" = {
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.organizeImports" = true;
        };
      };
      "[javascript]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[typescript]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };

      # Search Settings
      "search.exclude" = {
        "**/node_modules" = true;
        "**/bower_components" = true;
        "**/.git" = true;
        "**/result" = true;
        "**/target" = true;
      };

      # Explorer Settings
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "explorer.compactFolders" = false;

      # Security & Telemetry
      "telemetry.telemetryLevel" = "off";
      "update.mode" = "none";
      "extensions.autoUpdate" = false;

      # Performance
      "files.watcherExclude" = {
        "**/.git/objects/**" = true;
        "**/.git/subtree-cache/**" = true;
        "**/node_modules/**" = true;
        "**/result/**" = true;
      };
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
