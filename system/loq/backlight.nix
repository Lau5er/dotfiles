{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    xorg.xbacklight
  ];
}
