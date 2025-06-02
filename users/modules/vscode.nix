{ 
  config, 
  pkgs, 
  lib, 
  ... 
}:

{
  # VSCode configuration
  # Also as a module soon under development
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
}