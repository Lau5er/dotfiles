{ config, pkgs, lib, ... }:

{

  #Fingerabdruck-Dienst aktivieren
  services.fprintd.enable = true;

  #Authentifizierung via PAM erlauben (Login, Sudo, KDE Sperrbildschirm)
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;

  #Wichtig für HP EliteBooks: Firmware erlauben
  hardware.enableRedistributableFirmware = true;

  # Hier kommt das mkForce zum Einsatz:
  security.pam.services.kde.fprintAuth = lib.mkForce true;

  # Verhindert, dass der Fingerabdrucksensor schlafen geht
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="06cb", ATTR{idProduct}=="00f0", ATTR{power/control}="on"
  '';
}
