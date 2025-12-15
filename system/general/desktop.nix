{ pkgs, ... }:

{
  services = {
    desktopManager.plasma6.enable = true;

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    xserver.xkb.layout = "de";

    xserver.enable = true;
  };
  security.pam.services.sddm.enableKwallet = true;

  networking.networkmanager = {
    enable = true;

    plugins = with pkgs; [
      networkmanager-openconnect
    ];
  };
}
