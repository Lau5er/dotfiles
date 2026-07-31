{ config, pkgs, pkgs-unstable, plasma-manager, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "profile/brobook/config/nvim";
  };
  kp-unlock-script = pkgs.writeShellScriptBin "kp-unlock" ''
    ${pkgs.libsecret}/bin/secret-tool lookup database keepass | ${pkgs.keepassxc}/bin/keepassxc --pw-stdin "$HOME/Nextcloud/Keepass/Linus-21.kdbx"
  '';
in

{
  imports = [
    ../../home/common.nix
    ../../home/jetbrains-toolbox.nix
    ../../home/git.nix
    ../../home/office/libreOffice.nix
    ../../home/3d/orca.nix

    ../../home/development/vscode.nix
    ../../home/development/vscode-esp32.nix
    ../../home/office/latex.nix
    ../../home/development/platformio.nix
    plasma-manager.homeModules.plasma-manager
    ./plasma.nix
  ];

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
    clang-tools
    teams-for-linux
    deezer-enhanced
    pkgs-unstable.makemkv
    pkgs.freecad
    openscad

    kp-unlock-script
  ];

  xdg.desktopEntries.keepass-fingerprint = {
    name = "KeePass Fingerprint";
    genericName = "Passwort-Manager";
    # Wir nutzen hier den Pfad zum Skript aus dem Nix-Store
    exec = "${kp-unlock-script}/bin/kp-unlock";
    icon = "keepassxc";
    terminal = false;
    categories = [ "Utility" ];
  };

  xsession.numlock.enable = true;
}
