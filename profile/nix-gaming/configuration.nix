{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../system/common/base.nix
      ../../system/nvidia/suspend.nix
      ../../system/virtualisation/kali.nix
      ../../system/loq/wifi.nix
      ../../system/loq/backlight.nix
      ../../system/services/moonlight.nix
    ];

  # s2idle (S0ix) is the only sleep state on this LOQ (see /sys/power/mem_sleep).
  # The officially recommended NVIDIA setting for S0ix is
  # NVreg_EnableS0ixPowerManagement=1 (see ArchWiki "Lenovo LOQ 15ARP9").
  # NVreg_PreserveVideoMemoryAllocations belongs to S3/deep sleep only and
  # conflicts with S0ix, so it must NOT be set (not even via the nvidia module,
  # which is why powerManagement.enable is disabled below).
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_EnableS0ixPowerManagement=1"
    "nvidia.NVreg_EnableGpuFirmware=0"
    # This LOQ exposes only s2idle, so `deep` is useless here and just adds a
    # failed suspend attempt each time. Re-add if S3 becomes available in BIOS:
    # "mem_sleep_default=deep"
    "amd_pstate=active"
    # Virtual display on HDMI-A-1 for Sunshine/Moonlight streaming
    "video=HDMI-A-1:1920x1080@60D"
  ];

  networking.hostName = "nix-gaming";

  networking.firewall.allowedTCPPorts = [ 8081 ];

  i18n.defaultLocale = "en_US.UTF-8";

  services.ollama-custom = {
    enable = true;
    backend = "cuda";
    enableOpenWebUI = true;
    contextLength = 8192;
    numParallel = 1;
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_7_1;

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    # powerManagement.enable would force NVreg_PreserveVideoMemoryAllocations=1
    # plus nvidia-sleep.sh services - both belong to S3/deep sleep and break
    # S0ix. The nvidia module does not provide an option for NVreg_EnableS0ixPowerManagement,
    # so it is set as a kernel param above instead.
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    dynamicBoost.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

  };
  systemd.services.nvidia-power-limit = {
    description = "Set NVIDIA GPU power limit";
    wantedBy = [ "multi-user.target" ];
    after = [ "nvidia-powerd.service" "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pm 1 && ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pl 115'";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  hardware.enableRedistributableFirmware = true;

  services.sunshine = {
    enable = true;
    openFirewall = true;
    settings = {
      encoder = "nvenc";
      output_name = 0;
      global_prep_cmd = ''[{"do":"kscreen-doctor output.HDMI-A-1.enable","undo":"kscreen-doctor output.HDMI-A-1.disable"}]'';
    };
  };

  services.languagetool = {
    enable = true;
    public = true;
    allowOrigin = "*";
  };

  environment.systemPackages = with pkgs; [
    mangohud
    opencode
    aider-chat
    pkgs-unstable.github-copilot-cli
    bash #fix for copilot
  ];

}
