{ config, lib, pkgs, ... }:

{
  # --- NVIDIA suspend/resume fixes -------------------------------------
  # Problem: after waking from standby the screen stays black.
  #
  # Primary fix (see profile/nix-gaming/configuration.nix): this LOQ only
  # supports s2idle/S0ix, so NVreg_EnableS0ixPowerManagement=1 is set as a
  # kernel param and powerManagement.enable is disabled (PreserveVideoMemoryAllocations
  # would conflict with S0ix).
  #
  # Note: a previous kwin-restart-on-resume workaround (restarting
  # plasma-kwin_wayland.service after wake to re-acquire DRM master) was
  # removed: with working S0ix it is unnecessary and caused a KWin/Xwayland
  # crash loop on resume. See ArchWiki "Lenovo LOQ 15ARP9".

  # systemd >= 256 freezes user sessions (cgroup freeze) before sleeping.
  # With the NVIDIA driver this can time out or leave the session in a
  # half-frozen state, which breaks resume. NVIDIA itself ships a drop-in
  # that disables this freezing
  # (/usr/lib/systemd/system/systemd-suspend.service.d/10-nvidia-no-freeze-session.conf).
  # NixOS does not ship it, so we apply the same setting here.
  systemd.services = lib.genAttrs [
    "systemd-suspend"
    "systemd-hibernate"
    "systemd-hybrid-sleep"
    "systemd-suspend-then-hibernate"
  ]
    (name: {
      environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
    });
}
