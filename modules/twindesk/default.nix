{ config, pkgs, inputs, ... }:

let
  twindesk = inputs.twindesk.packages.${config.system}.default;
in {
  # Enable TwinDesk phone bridge
  programs.twindesk = {
    enable = true;
    # TwinDesk typically runs on port 5114 for phone bridge
    # The app will auto-detect and configure
  };

  # Allow port 5114 through firewall for phone bridge
  networking.firewall.allowedTCPPorts = [
    ... (if config.networking.firewall then config.networking.firewall.allowedTCPPorts else []) ++ [ 5114 ]
  ];

  # Add TwinDesk to home packages if using home-manager
  # This will be overridden by profile-level configurations
};