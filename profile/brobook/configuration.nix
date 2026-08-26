{ config, lib, pkgs, pkgs-unstable, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../system/common/base.nix
      ../../system/general/fingerprint.nix
      ../../system/services/wifi.nix
      ../../system/services/moonlight.nix

    #  ../../system/development/stm32.nix
    ];

  #For Bios update
  services.fwupd.enable = true;
  boot.kernelModules = [ "sg" ];

  boot.initrd.luks.devices."luks-2e946b90-1c34-4930-a20c-0d7cd0bc654e".device = "/dev/disk/by-uuid/2e946b90-1c34-4930-a20c-0d7cd0bc654e";
  networking.hostName = "brobook"; # Define your hostname.

  networking.firewall.allowedTCPPorts = [ 3923 8081 ];

  hardware.graphics.enable = true;

  services.sunshine = {
    enable = true;
    openFirewall = true;
    settings = {
      encoder = "vaapi";
      file_apps = "/etc/sunshine/apps.json";
    };
  };

  environment.etc."sunshine/apps.json".text = builtins.toJSON {
    apps = [
      {
        name = "Virtual Monitor";
        "prep-cmd" = [
          {
            do = "kscreen-doctor output.HDMI-A-1.enable";
            undo = "kscreen-doctor output.HDMI-A-1.disable";
          }
        ];
        "auto-detach" = "true";
      }
    ];
  };

  services.languagetool = {
    enable = true;
    public = true;
    allowOrigin = "*";
  };

  services.ollama-custom = {
    enable = false;
    backend = "rocm";
    contextLength = 65536;
    numParallel = 1;
  };

  users.users.lauser = {
    extraGroups = [ "networkmanager" "docker" "dialout" "plugdev" "video" "input" ]; # Enable 'sudo' for the user.
  };

  programs.firefox = {
    package = pkgs.firefox;
  };
  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };
  #  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    direnv
    pika-backup
    kdePackages.partitionmanager
    brave
    ntfs3g
    keepassxc
    kdePackages.kwallet
    libsecret
    pkgs-unstable.github-copilot-cli
    pkgs-unstable.winboat
    bash #fix for copilot
    opencode
    iw
    aider-chat
    copyparty
  ];

  environment.sessionVariables = {
  XDG_CURRENT_DESKTOP = "KDE";
  KDE_SESSION_VERSION = "6";
  };

  nixpkgs.config.packageOverrides = pkgs: {
  keepassxc = pkgs.keepassxc.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      wrapProgram $out/bin/keepassxc \
        --set XDG_CURRENT_DESKTOP KDE \
        --set KDE_FULL_SESSION true
    '';
  });
  };

  security.pam.services.login.enableKwallet = true;
  security.pam.services.kde.enableKwallet = true;

  environment.variables = {
    LANG = "de_DE.UTF-8";
  };

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

  # Limit build parallelism to ~28 GB RAM (7 cores * 4 GB per core)
  nix.settings.cores = 7;

  nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" "electron-40.10.5" ];

  # Temporäre Site-Sperre: true = YouTube + Instagram blockiert
  networking.extraHosts = lib.mkIf false ''
    127.0.0.1 youtube.com www.youtube.com m.youtube.com
    127.0.0.1 instagram.com www.instagram.com
  '';

  system.stateVersion = "25.11"; # Did you read the comment?

}
