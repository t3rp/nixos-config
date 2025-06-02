{ 
  config, 
  pkgs, 
  lib, 
  ... 
}:

let
  isCI = builtins.getEnv "CI" == "true" || builtins.getEnv "GITHUB_ACTIONS" == "true";
in

{
  # Only enable VSCode if not in CI
  programs.vscode = lib.mkIf (!isCI) {
    enable = true;
    
    # NEW: Use profiles instead of direct extensions/userSettings
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-vscode.cpptools
        bbenoist.nix
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
  };
}