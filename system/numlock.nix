{ pkgs, ... }:

{
  services.displayManager.sddm = {
    enable = true;
    settings = {
      General = {
        Numlock = "on";
      };
    };
  };
}
