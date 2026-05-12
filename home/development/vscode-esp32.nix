{ pkgs-unstable, vscode-extensions, ... }:

{
  programs.vscode.profiles.default.extensions =
    with vscode-extensions.vscode-marketplace; [
      espressif.esp-idf-extension
    ] ++ (with pkgs-unstable.vscode-extensions; [
      # Optional: Complementary extensions for embedded development
      ms-vscode.cmake-tools
      ms-vscode.makefile-tools
    ]);
}
