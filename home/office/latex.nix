{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [ texlive.combined.scheme-full ];

  programs.vscode.profiles.default = {
    extensions = with pkgs-unstable.vscode-extensions; [
      james-yu.latex-workshop
    ];
    userSettings = {
      "latex-workshop.view.pdf.viewer" = "tab";
      "latex-workshop.latex.autoBuild.run" = "onFileChange";
    };
  };
}
