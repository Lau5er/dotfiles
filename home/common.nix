{ pkgs, ... }:

{
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

  home.packages = with pkgs; [
    neovim
    ripgrep
    nil
    nixpkgs-fmt
    nodejs
    gcc
    discord-ptb
    (prismlauncher.override {
      additionalPrograms = [ ffmpeg ];
    })
    nextcloud-client
    thunderbird
    signal-desktop
    spotify
    vlc
  ];
}
