{ pkgs, ... }:
let
  panelConfig = {
    location = "bottom";
    widgets = [
      "org.kde.plasma.kickoff"
      "org.kde.plasma.pager"
      {
        iconTasks = {
          launchers = [
            "applications:org.kde.dolphin.desktop"
            "applications:firefox.desktop"
            "applications:org.keepassxc.KeePassXC.desktop"
            "applications:spotify.desktop"
            "applications:org.kde.plasma-systemmonitor.desktop"
            "applications:systemsettings.desktop"
            "applications:thunderbird.desktop"
          ];
          settings = {
            General = {
              sortingStrategy = 1;
            };
          };
        };
      }
      "org.kde.plasma.marginsseparator"
      "org.kde.plasma.systemtray"
      "org.kde.plasma.digitalclock"
      "org.kde.plasma.showdesktop"
    ];
  };
in
{
  programs.plasma = {
    enable = true;
    workspace = {
      clickItemTo = "select";
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    panels = [
      (panelConfig // { screen = 0; })
      (panelConfig // { screen = 1; })
      (panelConfig // { screen = 2; })
    ];
  };
}
