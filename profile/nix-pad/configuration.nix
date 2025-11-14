{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  #  boot.kernelModules = [
  #   "rtw89_8852be"
  #];

  networking.hostName = "nix-pad";
  networking.networkmanager.enable = true;
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;

    xserver.xkb.layout = "de";

    # xserver.videoDrivers = [ "nvidia" ];

    tailscale.enable = true;
    tailscale.useRoutingFeatures = "client";

  };

  # hardware.nvidia.modesetting.enable = true;
  # hardware.nvidia.open = true;

  users.users.lauser = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox = {
    enable = true;
    policies = {
      "PasswordManagerEnabled" = false;
      "OfferToSaveLogins" = false;
    };
  };
  # programs.steam = {
  #  enable = true;
  #  remotePlay.openFirewall = true;
  #  dedicatedServer.openFirewall = true;
  #  };
  # programs.gamemode.enable = true;


  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    wayland-utils
    wl-clipboard
    alacritty
    git
    #   mangohud
    xorg.xbacklight
    direnv
    pika-backup
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
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
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05"; # Did you read the comment?
}

