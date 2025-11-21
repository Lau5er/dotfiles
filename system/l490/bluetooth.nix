{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
    };
  };
  # Erzwingt Bluetooth-Blockade beim Start (KDE-Override)
  systemd.services.bluetooth-kill-on-boot = {
    description = "Block Bluetooth on boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill block bluetooth";
    };
  };

}
