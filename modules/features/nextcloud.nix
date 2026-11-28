# Nextcloud on inixos, reachable only through the tailnet.
# Nginx listens on 127.0.0.1. Tailscale Serve publishes HTTPS to the mesh.
# The admin password is read from /etc/nextcloud/admin-pass and is not stored here.
{
  flake.modules.nixos."nextcloud" =
  { config, pkgs, lib, ... }:

  {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud33;
      hostName = "localhost";
      https = true;

      # Enough for documents and photos. This also caps each PHP worker's memory.
      maxUploadSize = "512M";

      # The module default is sized for a 4 GB server and would start 12 PHP
      # workers. This iMac has 8 GB shared with the desktop.
      poolSettings = {
        "pm" = "dynamic";
        "pm.max_children" = "6";
        "pm.start_servers" = "2";
        "pm.min_spare_servers" = "1";
        "pm.max_spare_servers" = "3";
        "pm.max_requests" = "500";
      };

      database.createLocally = true;

      config = {
        dbtype = "pgsql";
        adminuser = "John";
        adminpassFile = "/etc/nextcloud/admin-pass";
      };

      settings = {
        overwriteprotocol = "https";
        overwritehost = "inixos.tail6cea4d.ts.net";
        "overwrite.cli.url" = "https://inixos.tail6cea4d.ts.net";
        # The document server calls back to this machine over the tailnet address.
        allow_local_remote_servers = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
        trusted_domains = lib.mkForce [
          "inixos.tail6cea4d.ts.net"
          "100.98.170.29"
          "localhost"
          "127.0.0.1"
        ];
      };
    };

    # Do not listen on the LAN address or on all interfaces.
    services.nginx.defaultListenAddresses = [ "127.0.0.1" ];
    services.nginx.virtualHosts."localhost".listenAddresses = [ "127.0.0.1" ];

    systemd.services.tailscale-nextcloud-serve = {
      description = "Publish Nextcloud on the tailnet only";
      after = [
        "tailscaled.service"
        "nginx.service"
      ];
      wants = [
        "tailscaled.service"
        "nginx.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # tailscaled.service is active before the node is logged in. A serve
        # command at that moment exits with "unexpected state: NoState".
        ExecStart = pkgs.writeShellScript "tailscale-nextcloud-serve" ''
          set -eu
          deadline=$(( $(date +%s) + 180 ))
          until ${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.gnugrep}/bin/grep -q '"BackendState": *"Running"'; do
            if [ "$(date +%s)" -ge "$deadline" ]; then
              echo "tailscaled did not reach BackendState Running within 180s" >&2
              exit 1
            fi
            sleep 2
          done
          ${pkgs.tailscale}/bin/tailscale serve --bg --yes http://127.0.0.1:80
          ${pkgs.tailscale}/bin/tailscale serve --bg --yes --https=8443 http://127.0.0.1:8088
        '';
        ExecStop = "${pkgs.tailscale}/bin/tailscale serve reset";
      };
    };
  };
}
