{ ... }:

{
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  systemd.timers.nix-gc.timerConfig.Persistent = true;
}
