{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "nvim";
  };
in

{
  imports = [
    ../../home/git.nix
  ];

  home.username = "lauser";
  home.homeDirectory = "/home/lauser";
  programs.git.enable = true;
  home.stateVersion = "25.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
      #      resw = "nixos-rebuild switch --flakes ~/nixos-dotfiles#nix-gaming";
    };
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
    protonup-ng
    discord-ptb
    (prismlauncher.override {
      additionalPrograms = [ ffmpeg ];
    })
    keepassxc
    nextcloud-client
    thunderbird
    signal-desktop
  ];

  home.sessionVariables = {
    STEAM_EXTRAA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";
  };
}
