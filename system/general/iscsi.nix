{ pkgs, ... }:

{
  # ---------------------------------------------------------
  # iSCSI & NAS Konfiguration (Laptop-freundlich)
  # ---------------------------------------------------------

  boot.kernelModules = [ "iscsi_tcp" ];

  services.openiscsi = {
    enable = true;
    # WICHTIG: Dieser Name muss immer gleich bleiben!
    # Wenn du NixOS neu installierst, darf sich dieser Name nicht ändern,
    # sonst erkennt das NAS dich nicht mehr.
    name = "iqn.2024-11.com.nixos:laptop-client";
    discoverPortal = "192.168.0.100";

    # HIER IST DER FIX FÜR WLAN / ABBRÜCHE:
    extraConfig = ''
      # Wenn die Verbindung weg ist: Warte 120 Sekunden, bevor du die Festplatte "tötest".
      # Standard ist oft nur 5-15 Sekunden, was bei WLAN zu wenig sein kann.
      node.session.timeo.replacement_timeout = 120

      # Prüfe die Verbindung alle 5 Sekunden (Heartbeat)
      node.conn[0].timeo.noop_out_interval = 5
      
      # Wenn 5 Sekunden keine Antwort auf Heartbeat kommt, versuche Neuverbindung
      node.conn[0].timeo.noop_out_timeout = 5
    '';
  };

  # Der Login-Service (leicht angepasst, damit er nicht nervt, wenn du weg bist)
  systemd.services.iscsi-login-ugreen = {
    description = "Login to UGREEN iSCSI target";
    # Warte auf Netzwerk, aber blockiere den Boot nicht, wenn es fehlt
    after = [ "network-online.target" "iscsid.service" ];
    wants = [ "network-online.target" "iscsid.service" ];

    serviceConfig = {
      Type = "oneshot";

      RemainAfterExit = true;

      # Wir prüfen kurz, ob die IP überhaupt erreichbar ist (Timeout 2 Sek).
      # Wenn nicht (du bist nicht zuhause), bricht der Service sofort ab (exit 1) 
      # und versucht gar nicht erst, iscsiadm auszuführen. Das spart Zeit & Logs.
      ExecStartPre = "${pkgs.iputils}/bin/ping -c 1 -W 2 192.168.0.100";

      # Die eigentlichen Befehle (Discovery + Login)
      ExecStart = "${pkgs.openiscsi}/bin/iscsiadm -m node -T iqn.2025-03.com.ugreen:backup -p 192.168.0.100 --login";
      ExecStop = "${pkgs.openiscsi}/bin/iscsiadm -m node -T iqn.2025-03.com.ugreen:backup -p 192.168.0.100 --logout";

      # Wichtig für Laptops: Nicht ewig neustarten, wenn wir unterwegs sind
      Restart = "on-failure";
      RestartSec = "10s";
      StartLimitBurst = 3; # Nur 3 Versuche, dann aufgeben
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Der Mount-Point (Das Herzstück der Strategie)
  fileSystems."/home/lauser/NAS-Backup" = {
    device = "/dev/disk/by-uuid/01cbd554-e74b-4851-862e-cf0fda499ad9"; # <-- Deine UUID von vorhin!
    fsType = "ext4";
    options = [
      "_netdev" # Sagt: Das ist ein Netzwerkgerät
      "nofail" # Sagt: Boot weiter, auch wenn es fehlt! (WICHTIG)
      "x-systemd.automount" # Sagt: Verbinde erst, wenn ich draufklicke!
      "x-systemd.idle-timeout=600" # Trennt die Verbindung nach 60 Sek Inaktivität (spart Strom)
      "x-systemd.device-timeout=5s" # Wenn Gerät nicht da, gib nach 5 Sek auf (statt 90)
      "errors=remount-ro"
    ];
  };
}
