{ pkgs, ... }:

let
  defaultNetworkXml = pkgs.writeText "libvirt-default-network.xml" ''
    <network>
      <name>default</name>
      <forward mode='nat'/>
      <bridge name='virbr0' stp='on' delay='0'/>
      <ip address='192.168.122.1' netmask='255.255.255.0'>
        <dhcp>
          <range start='192.168.122.2' end='192.168.122.254'/>
        </dhcp>
      </ip>
    </network>
  '';
in
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  # virt-manager (GTK) needs dconf to persist its settings.
  programs.dconf.enable = true;

  users.users.lauser.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice-gtk
    curl
  ];

  # libvirtd does not auto-create the default NAT network on NixOS,
  # so ensure it exists, starts and autostarts.
  systemd.services.libvirt-default-network = {
    description = "Ensure the libvirt default (NAT) network exists and is active";
    wantedBy = [ "libvirtd.service" ];
    after = [ "libvirtd.service" ];
    path = with pkgs; [ libvirt gnused gnugrep ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'virsh net-list --all | grep -q \" default \" || virsh net-define ${defaultNetworkXml}; virsh net-start default 2>/dev/null || true; virsh net-autostart default 2>/dev/null || true'";
    };
  };
}
