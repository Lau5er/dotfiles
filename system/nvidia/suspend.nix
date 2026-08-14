{ config, lib, pkgs, ... }:

{
  # --- NVIDIA suspend/resume fixes -------------------------------------
  # Problem: after waking from standby the screen stays black.
  #
  # Diagnosis (journalctl):
  #   kwin_wayland: Atomic modeset test failed! Permission denied
  #   kwin_wayland: Applying output configuration failed!
  #
  # KWin loses its DRM master during suspend/resume and - at least on
  # NVIDIA with the proprietary driver - never re-acquires it, leaving a
  # permanent black screen. See KDE bugs 477738 and 516038.

  # 2) NVIDIA recommends a real disk location for the VRAM snapshot written
  #    by nvidia-sleep.sh (see NVreg_PreserveVideoMemoryAllocations).
  #    The default tmpfs location can be too small, causing resume to fail.
  hardware.nvidia.moduleParams.nvidia.NVreg_TemporaryFilePath = "/var/tmp";

  # 3) systemd >= 256 freezes user sessions (cgroup freeze) before sleeping.
  #    With the NVIDIA driver this can time out or leave the session in a
  #    half-frozen state, which breaks resume. NVIDIA itself ships a drop-in
  #    that disables this freezing
  #    (/usr/lib/systemd/system/systemd-suspend.service.d/10-nvidia-no-freeze-session.conf).
  #    NixOS does not ship it, so we apply the same setting here.
  systemd.services = lib.mkMerge [
    (lib.genAttrs [
      "systemd-suspend"
      "systemd-hibernate"
      "systemd-hybrid-sleep"
      "systemd-suspend-then-hibernate"
    ]
      (name: {
        environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
      }))

    # 4) Workaround for KDE bugs 477738 / 516038: KWin on Wayland can lose DRM
    #    master during suspend and never re-acquires it -> black screen after
    #    resume. Restarting the compositor after wake re-acquires DRM master.
    #    This follows the canonical systemd.special(7) "hook after sleep"
    #    pattern (ExecStop + StopWhenUnneeded + Before=sleep.target).
    {
      kwin-restart-on-resume = {
        description = "Restart KWin after resume (NVIDIA DRM master workaround)";
        wantedBy = [ "sleep.target" ];
        before = [ "sleep.target" ];
        unitConfig = {
          DefaultDependencies = "no";
          StopWhenUnneeded = "yes";
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
          ExecStart = "${pkgs.coreutils}/bin/true";
          ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/sleep 3; exec ${pkgs.util-linux}/bin/runuser -u lauser -- env XDG_RUNTIME_DIR=/run/user/$(${pkgs.coreutils}/bin/id -u lauser) ${config.systemd.package}/bin/systemctl --user restart plasma-kwin_wayland.service || true'";
        };
      };
    }
  ];
}
