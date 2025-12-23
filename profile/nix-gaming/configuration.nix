{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../system/loq/wifi.nix
      ../../system/loq/backlight.nix
      ../../system/general/generationCleanup.nix
      ../../system/services/tailscale.nix
      ../../system/general/desktop.nix
      ../../system/gaming/steam.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_EnableGpuFirmware=0"
    "mem_sleep_default=deep"
  ];

  networking.hostName = "nix-gaming";
  networking.networkmanager.enable = true;
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  services = {

    xserver.videoDrivers = [ "nvidia" ];
  };
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    powerManagement.enable = true;
    powerManagement.finegrained = false;
    package = config.boot.kernelPackages.nvidiaPackages.production;

  };
  systemd.services.nvidia-suspend.serviceConfig.ExecStart = lib.mkForce "${pkgs.bash}/bin/bash ${config.hardware.nvidia.package.out}/bin/nvidia-sleep.sh 'suspend'";
  systemd.services.nvidia-resume.serviceConfig.ExecStart = lib.mkForce "${pkgs.bash}/bin/bash ${config.hardware.nvidia.package.out}/bin/nvidia-sleep.sh 'resume'";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  users.users.lauser = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;


  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    wayland-utils
    wl-clipboard
    alacritty
    git
    mangohud
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05"; # Did you read the comment?

}

