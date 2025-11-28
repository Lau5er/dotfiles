{ pkgs, ... }:

{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
  ];

  services.udev.packages = with pkgs; [
    platformio-core.udev
    openocd
  ];
}
