{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    platformio
    avrdude

    python3
    python3Packages.virtualenv
  ];

  programs.vscode = {
    enable = true;
    package = pkgs-unstable.vscode; # Das offizielle VS Code (Microsoft)

    profiles.default = {

      # -----------------------------------------------------------
      # Der Datenschutz-Block (Telemetrie aus)
      # -----------------------------------------------------------
      userSettings = {
        # Telemetrie & Crash-Reports deaktivieren
        "telemetry.telemetryLevel" = "off";
        # Automatische Updates deaktivieren (macht NixOS)
        "update.mode" = "none";

        # Startseite nicht anzeigen (nervt oft und lädt Content nach)
        "workbench.startupEditor" = "newUntitledFile";

        # -----------------------------------------------------------
        # PlatformIO Einstellungen
        # -----------------------------------------------------------
        "platformio-ide.useBuiltinPIOCore" = true;

        "platformio-ide.useBuiltinPython" = false;

        # Optik (optional)
        "editor.fontSize" = 14;
      };

      # -----------------------------------------------------------
      # Erweiterungen
      # -----------------------------------------------------------
      extensions = with pkgs-unstable.vscode-extensions; [
        # Diese sind in NixOS vorverpackt - sehr bequem:
        ms-vscode.cpptools # C++ Support (Microsoft Original)
        bbenoist.nix # Nix Highlighting
        mkhl.direnv # Direnv Support

        ms-vscode.cpptools
        twxs.cmake

        github.copilot
        github.copilot-chat
      ]
      # Hier holen wir PlatformIO direkt vom Marktplatz
      ++ pkgs-unstable.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "platformio-ide";
          publisher = "platformio";
          version = "3.3.4";
          # Beim ersten Mal hier "lib.fakeSha256" eintragen, Fehler abwarten, Hash kopieren!
          sha256 = "sha256-qfNz4IYjCmCMFLtAkbGTW5xnsVT8iDnFWjrgkmr2Slk=";
        }
      ];
    };
  };
}
