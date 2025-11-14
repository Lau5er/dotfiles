{ config, pkgs, pkgs-unstable, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "nvim";
  };
in

{
  imports = [
    ../../home/jetbrains-toolbox.nix
    ../../home/git.nix
  ];

  home.username = "lauser";
  home.homeDirectory = "/home/lauser";
  home.stateVersion = "25.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
      #      resw = "nixos-rebuild switch --flakes ~/nixos-dotfiles#nix-gaming";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
    })
    configs;

  home.packages = with pkgs; [
    neovim
    ripgrep
    nil
    nixpkgs-fmt
    nodejs
    gcc
    #    protonup
    discord-ptb
    (prismlauncher.override {
      additionalPrograms = [ ffmpeg ];
    })
    keepassxc
    nextcloud-client
    thunderbird
    signal-desktop
    teams-for-linux
    #pkgs-unstable.jetbrains-toolbox
    spotify
    notepadqq
  ];

  #  home.sessionVariables = {
  #    STEAM_EXTRAA_COMPAT_TOOLS_PATHS =
  #      "\${HOME}/.steam/root/compatibilitytools.d";
  #  };

  #programs.git = {
  #  enable = true;
  #  extraConfig = {
  #    user.name = "Lau5er";
  #    user.email = "lau5er@icloud.com";
  #    core = {
  #      autocrlf = "input";
  #    };
  #  };
  #};

  xsession.numlock.enable = true;

  # xdg.mimeApps.defaultApplications = {
  #   "x-scheme-handler/jetbrains" = "jetbrains-toolbox.desktop";
  # };

  # xdg.desktopEntries.jetbrains-toolbox = {
  #   name = "JetBrains Toolbox";
  #   exec = "jetbrains-toolbox %u";
  #   type = "Application";
  #   terminal = false;
  #   categories = [ "Development" ];
  #   comment = "Manage JetBrains IDEs";
  #   mimeType = [ "x-scheme-handler/jetbrains" ];
  # };
}
