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

  # Create a user-local wrapper that forces a usable locale for snapmaker-orca
  home.file = {
    ".local/bin/snapmaker-orca".text = ''
#!/bin/sh
export LC_ALL=C.utf8
export LANG=C.utf8
exec /run/current-system/sw/bin/snapmaker-orca "$@"
'';
    ".local/bin/snapmaker-orca".mode = "0755";

    ".local/share/applications/snapmaker-orca.desktop".text = ''
[Desktop Entry]
Name=Snapmaker Orca
GenericName=3D Slicer
Comment=Snapmaker Orca slicer (starts with C.utf8 locale)
Exec=$HOME/.local/bin/snapmaker-orca %U
Terminal=false
Type=Application
Categories=Graphics;Science;
Icon=snapmaker-orca
StartupWMClass=OrcaSlicer
'';
  };
}
