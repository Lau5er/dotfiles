{ pkgs, ... }:

{
  home.packages = with pkgs; [
    platformio
    avrdude
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode; # Das offizielle VS Code (Microsoft)

    # -----------------------------------------------------------
    # Der Datenschutz-Block (Telemetrie aus)
    # -----------------------------------------------------------
    userSettings = {
      # Telemetrie & Crash-Reports deaktivieren
      "telemetry.telemetryLevel" = "off";
      "redhat.telemetry.enabled" = false; # Falls du RedHat Extensions nutzt
      "application.telemetry.enabled" = false;

      # Automatische Updates deaktivieren (macht NixOS)
      "update.mode" = "none";
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;

      # Keine "Experimente" im UI
      "workbench.enableExperiments" = false;
      "workbench.settings.enableNaturalLanguageSearch" = false;

      # Startseite nicht anzeigen (nervt oft und lädt Content nach)
      "workbench.startupEditor" = "newUntitledFile";

      # -----------------------------------------------------------
      # PlatformIO Einstellungen
      # -----------------------------------------------------------
      "platformio-ide.useBuiltinPIOCore" = false;
      "platformio-ide.useBuiltinPython" = false;
      "platformio-ide.customPATH" = "${pkgs.platformio}/bin/platformio";

      # Optik (optional)
      "editor.fontSize" = 14;
    };

    # -----------------------------------------------------------
    # Erweiterungen
    # -----------------------------------------------------------
    extensions = with pkgs.vscode-extensions; [
      # Diese sind in NixOS vorverpackt - sehr bequem:
      ms-vscode.cpptools # C++ Support (Microsoft Original)
      bbenoist.nix # Nix Highlighting
      mkhl.direnv # Direnv Support
    ]
    # Hier holen wir PlatformIO direkt vom Marktplatz
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "platformio-ide";
        publisher = "platformio";
        version = "6.1.17";
        # Beim ersten Mal hier "lib.fakeSha256" eintragen, Fehler abwarten, Hash kopieren!
        sha256 = "sha256-RbfTjGg1zH+qU9gfr78k3O8swSoxz+/f0N6jU6D33aE=";
      }
    ];
  };
}
