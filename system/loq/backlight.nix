{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    xbacklight
  ];
}
