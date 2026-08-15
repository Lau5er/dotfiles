{ pkgs, ... }:

{
  imports = [
    ./libvirt.nix
  ];

  environment.systemPackages = with pkgs; [
    qemu_kvm
    libosinfo
    (pkgs.writeShellScriptBin "kali-vm" ''
      # Helper to create/start a Kali Linux VM under libvirt/KVM.
      #
      # Usage:
      #   kali-vm                 create (first run) or start (later runs) the VM
      #   kali-vm <name>          use a custom VM/disk name
      #
      # Env overrides: RAM_MB, CPUS, DISK_SIZE_GB
      #
      # First run downloads the Kali netinst ISO and boots the installer.
      # The graphical console (virt-viewer) opens automatically.
      # Later runs just start the existing VM and open the console.
      set -euo pipefail

      VM_NAME="''${1:-kali-linux}"
      KALI_DIR="''${HOME}/VMs/kali"
      ISO_URL="https://cdimage.kali.org/current"
      ISO_FILE="kali-linux-netinst-amd64.iso"
      ISO_PATH="''${KALI_DIR}/''${ISO_FILE}"
      DISK_FILE="''${KALI_DIR}/''${VM_NAME}.qcow2"
      DISK_SIZE_GB="''${DISK_SIZE_GB:-40}"
      RAM_MB="''${RAM_MB:-4096}"
      CPUS="''${CPUS:-4}"

      mkdir -p "''${KALI_DIR}"

      # --- 1. Kali netinst ISO -------------------------------------------
      if [[ ! -f "''${ISO_PATH}" ]]; then
        echo "==> Resolving latest Kali netinst ISO from ''${ISO_URL}/ ..."
        remote="$(curl -fsSL "''${ISO_URL}/" \
          | grep -oE 'kali-linux-[0-9]+\.[0-9]+-installer-netinst-amd64\.iso' \
          | sort -uV | tail -n 1)"
        if [[ -z "''${remote}" ]]; then
          echo "ERROR: could not resolve a Kali ISO from ''${ISO_URL}/" >&2
          exit 1
        fi
        echo "==> Downloading ''${remote} (this can take a while) ..."
        curl -fL --progress-bar "''${ISO_URL}/''${remote}" -o "''${ISO_PATH}"
      fi

      # --- 2. Disk image ---------------------------------------------------
      if [[ ! -f "''${DISK_FILE}" ]]; then
        echo "==> Creating ''${DISK_SIZE_GB}G disk image ..."
        qemu-img create -f qcow2 "''${DISK_FILE}" "''${DISK_SIZE_GB}G"
      fi

      # --- 3. Create / start the VM ---------------------------------------
      # Use the system libvirt (qemu:///system) everywhere: the NAT "default"
      # network (192.168.122.0/24) is only defined there (see libvirt.nix).
      # virt-install/virsh default to the user session URI otherwise, which
      # has no "default" network -> "Network not found" errors.
      if virsh --connect qemu:///system dominfo "''${VM_NAME}" >/dev/null 2>&1; then
        if [[ "$(virsh --connect qemu:///system domstate "''${VM_NAME}")" != "running" ]]; then
          echo "==> Starting existing VM: ''${VM_NAME}"
          virsh --connect qemu:///system start "''${VM_NAME}"
        else
          echo "==> VM ''${VM_NAME} is already running."
        fi
      else
        echo "==> Creating VM ''${VM_NAME} ..."
        virt-install \
          --connect qemu:///system \
          --name "''${VM_NAME}" \
          --memory "''${RAM_MB}" \
          --vcpus "''${CPUS}" \
          --disk path="''${DISK_FILE}",format=qcow2,bus=virtio \
          --cdrom "''${ISO_PATH}" \
          --network network=default,model=virtio \
          --graphics spice \
          --video virtio \
          --osinfo detect=on,require=off \
          --noautoconsole
        echo "==> VM created."
        echo "==> Complete the Kali installer, reboot the VM and eject the ISO"
        echo "    (in virt-manager: click the CD icon -> Boot disk)."
      fi

      # --- 4. Open the graphical console -----------------------------------
      echo "==> Opening display for ''${VM_NAME} ..."
      virt-viewer --wait --connect qemu:///system "''${VM_NAME}" >/dev/null 2>&1 &
    '')
  ];
}
