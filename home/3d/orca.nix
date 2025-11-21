{ pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
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
}
