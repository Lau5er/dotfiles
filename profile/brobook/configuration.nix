{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../system/docker.nix
      #../../system/laptop.performance.nix
      ../../system/numlock.nix
      ../../system/gaming/steam.nix
      ../../system/l490/bluetooth.nix
      ../../system/general/generationCleanup.nix
      ../../system/services/tailscale.nix
      ../../system/general/desktop.nix
      ../../system/general/iscsi.nix
      ../../system/general/printing.nix

      ../../system/development/platformio.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "sg" ];

  boot.initrd.luks.devices."luks-2e946b90-1c34-4930-a20c-0d7cd0bc654e".device = "/dev/disk/by-uuid/2e946b90-1c34-4930-a20c-0d7cd0bc654e";
  networking.hostName = "brobook"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  services = { };


  users.users.lauser = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" ]; # Enable ‘sudo’ for the user.
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
    vim
    wget
    wayland-utils
    wl-clipboard
    alacritty
    git
    direnv
    pika-backup
    prusa-slicer
    kdePackages.partitionmanager
    brave
    ntfs3g
  ];

  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocales = [
    "en_US.UTF-8/UTF-8"
    "de_DE.UTF-8/UTF-8"
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11"; # Did you read the comment?

}
