{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    platformio
    avrdude
    python3
    python3Packages.virtualenv
  ];

  # 2. VS Code Ergänzungen
  programs.vscode.profiles.default = {

    # PlatformIO spezifische Settings
    userSettings = {
      "platformio-ide.useBuiltinPIOCore" = true;
      "platformio-ide.useBuiltinPython" = false;
    };

    # C++ und PlatformIO Extensions
    extensions = with pkgs-unstable.vscode-extensions; [
      ms-vscode.cpptools # C++ Support
      twxs.cmake # CMake Support
    ]
    # PlatformIO Extension vom Marketplace
    ++ pkgs-unstable.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "platformio-ide";
        publisher = "platformio";
        version = "3.3.4";
        sha256 = "sha256-qfNz4IYjCmCMFLtAkbGTW5xnsVT8iDnFWjrgkmr2Slk=";
      }
    ];
  };
}
