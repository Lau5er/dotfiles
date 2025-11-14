{ pkgs-unstable, ... }:

{
  home.packages = with pkgs-unstable; [
    jetbrains-toolbox
  ];

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/jetbrains" = "jetbrains-toolbox.desktop";
  };

  xdg.desktopEntries.jetbrains-toolbox = {
    name = "JetBrains Toolbox";
    exec = "jetbrains-toolbox %u";
    type = "Application";
    terminal = false;
    categories = [ "Development" ];
    comment = "Manage JetBrains IDEs";
    mimeType = [ "x-scheme-handler/jetbrains" ];
  };
}
