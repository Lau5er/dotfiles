{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../system/hardware.graphics.intel.nix
      ../../system/docker.nix
      #../../system/laptop.performance.nix
      ../../system/numlock.nix
      ../../system/gaming/steam.nix
      ../../system/l490/bluetooth.nix
      ../../system/general/generationCleanup.nix
      ../../system/services/tailscale.nix
      ../../system/general/desktop.nix
      ../../system/general/iscsi.nix

      ../../system/development/platformio.nix
    ];

  #services.power-profiles-daemon.enable = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nix-pad";
  networking.networkmanager.enable = true;
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  services = { };


  users.users.lauser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "dialout" ]; # Enable ‘sudo’ for the user.
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

  #  programs.adb.enable = true;


  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    wayland-utils
    wl-clipboard
    alacritty
    git
    #   mangohud
    direnv
    pika-backup
    prusa-slicer
    kdePackages.partitionmanager
    brave
  ];

  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocales = [
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05"; # Did you read the comment?
}

