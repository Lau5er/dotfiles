{ pkgs, ... }:

{
  home.username = "lauser";
  home.homeDirectory = "/home/lauser";
  home.stateVersion = "25.05";

  programs.bash = {
    enable = true;
    initExtra = ''
      emu() {
        DRI_DRIVER_PATH="$(dirname "$(readlink -f "$NIX_LD_LIBRARY_PATH/libEGL_mesa.so.0")")/dri"
        LD_LIBRARY_PATH="$(ls -d /nix/store/mesa-libgbm-*/lib 2>/dev/null | sort -V | tail -n1):$LD_LIBRARY_PATH"
        export DRI_DRIVER_PATH LD_LIBRARY_PATH QT_QPA_PLATFORM=xcb
        exec ~/Android/Sdk/emulator/emulator -avd Pixel_10_Pro_XL
      }
    '';
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
