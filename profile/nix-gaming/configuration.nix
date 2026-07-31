{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../system/common/base.nix
      ../../system/loq/wifi.nix
      ../../system/loq/backlight.nix
    ];

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_EnableGpuFirmware=0"
    "mem_sleep_default=deep"
    "amd_pstate=active"
  ];

  networking.hostName = "nix-gaming";

  i18n.defaultLocale = "en_US.UTF-8";

  services.ollama-custom = {
    enable = true;
    backend = "cuda";
    enableOpenWebUI = true;
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    powerManagement.enable = true;
    powerManagement.finegrained = false;
    dynamicBoost.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

  };
  systemd.services.nvidia-suspend.serviceConfig.ExecStart = lib.mkForce "${pkgs.bash}/bin/bash ${config.hardware.nvidia.package.out}/bin/nvidia-sleep.sh 'suspend'";
  systemd.services.nvidia-resume.serviceConfig.ExecStart = lib.mkForce "${pkgs.bash}/bin/bash ${config.hardware.nvidia.package.out}/bin/nvidia-sleep.sh 'resume'";
  systemd.services.nvidia-power-limit = {
    description = "Set NVIDIA GPU power limit";
    wantedBy = [ "multi-user.target" ];
    after = [ "nvidia-powerd.service" "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${config.hardware.nvidia.package.out}/bin/nvidia-smi -pm 1 && ${config.hardware.nvidia.package.out}/bin/nvidia-smi -pl 115'";
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

  environment.systemPackages = with pkgs; [
    mangohud
    opencode
    aider-chat
    pkgs-unstable.github-copilot-cli
    bash #fix for copilot
  ];

}
