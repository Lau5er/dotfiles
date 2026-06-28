{ config, pkgs, ... }:
{
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="DE"
    options mt7921e disable_aspm=y
    options rtw89_pci disable_aspm=y
  '';

  networking.networkmanager.settings = {
    connection."wifi.mach-address-randomization" = 1;
    wifi = {
      powersave = false;
      "scan-rand-mac-address" = "no";
    };
  };
  hardware.wirelessRegulatoryDatabase = true;
  networking.networkmanager.wifi.powersave = false;
}
