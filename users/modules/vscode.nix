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
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-vscode.cpptools
      bbenoist.nix
      redhat.vscode-yaml
      ms-vscode.cmake-tools
      ms-vscode.makefile-tools
      golang.go
      rust-lang.rust-analyzer
    ];
    userSettings = {
      "editor.rulers" = [ 80 120 ];
    };
  };
}