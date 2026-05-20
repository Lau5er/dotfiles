{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ... deine anderen Pakete ...

    # Ersetze "orca-slicer" durch diesen Block:
    (symlinkJoin {
      name = "orca-slicer";
      paths = [ orca-slicer ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/orca-slicer \
          --set LC_ALL en_US.UTF-8
      '';
    })

  ];

  # Create a user-level wrapper via writeShellScriptBin so it is placed in $HOME/.nix-profile/bin
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "snapmaker-orca" ''
      #!/bin/sh
      export LC_ALL=C.utf8
      export LANG=C.utf8
      exec /run/current-system/sw/bin/snapmaker-orca "$@"
    '')
  ] ++ (home.packages or []);

  # Desktop entry to point to the wrapper in the user profile
  home.file.".local/share/applications/snapmaker-orca.desktop".text = ''
[Desktop Entry]
Name=Snapmaker Orca
GenericName=3D Slicer
Comment=Snapmaker Orca slicer (starts with C.utf8 locale)
Exec=$HOME/.nix-profile/bin/snapmaker-orca %U
Terminal=false
Type=Application
Categories=Graphics;Science;
Icon=snapmaker-orca
StartupWMClass=OrcaSlicer
'';
}
