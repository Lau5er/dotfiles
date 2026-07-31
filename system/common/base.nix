{ config, lib, pkgs, ... }:

{
  imports = [
    ../docker.nix
    ../numlock.nix
    ../gaming/steam.nix
    ../l490/bluetooth.nix
    ../general/generationCleanup.nix
    ../services/tailscale.nix
    ../general/desktop.nix
    ../general/firefox.nix
    ../general/iscsi.nix
    ../general/printing.nix
    ../development/platformio.nix
    ../services/ollama.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  users.users.lauser = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    wayland-utils
    wl-clipboard
    alacritty
    git
  ];

  i18n.defaultLocale = lib.mkDefault "de_DE.UTF-8";

  i18n.supportedLocales = [
    "de_DE.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "C.UTF-8/UTF-8"
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = lib.mkDefault "25.05"; # Did you read the comment?
}
