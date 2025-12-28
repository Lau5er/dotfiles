{ pkgs, pkgs-unstable, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode;

    profiles.default = {

      # Allgemeine Einstellungen (Optik, Datenschutz)
      userSettings = {
        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";
        "workbench.startupEditor" = "newUntitledFile";
        "editor.fontSize" = 14;
      };

      # Allgemeine Erweiterungen
      extensions = with pkgs-unstable.vscode-extensions; [
        bbenoist.nix # Nix Syntax Highlighting
        mkhl.direnv # Direnv Integration


        github.copilot
        github.copilot-chat
      ];
    };
  };
}
