#nextcloud.nix

{ config, pkgs, lib, ... }:

let
  hostName = "inixos.tail6cea4d.ts.net";
  # Nextcloud login that owns the instance. John's files live in his own folder.
  ncUser = "John";
in
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = hostName;
    # Tailscale Serve terminates HTTPS and forwards plain HTTP to localhost.
    https = true;
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = "/var/lib/secrets/nextcloud-admin-pass";
    };
    extraApps = {
      inherit (pkgs.nextcloud33Packages.apps) calendar contacts notes tasks;
    };
    # Keep the store available. The four apps above stay read-only Nix packages.
    appstoreEnable = true;
    settings = {
      overwriteprotocol = "https";
      trusted_proxies = [
        "127.0.0.1"
        "::1"
      ];
      # A file dropped in through the home symlink shows up when the folder is opened.
      filesystem_check_changes = 1;
    };
  };

  # The home network cannot open this. Tailscale Serve is the front door.
  services.nginx.virtualHosts.${hostName}.listen = [
    {
      addr = "127.0.0.1";
      port = 80;
    }
  ];

  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;

  # John opens his files through a symlink in his home directory.
  # The nextcloud user still owns them.
  systemd.services.nextcloud-john-files-access = {
    description = "Let John read and write his Nextcloud files";
    after = [ "systemd-tmpfiles-setup.service" "nextcloud-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      chmod 750 /var/lib/nextcloud/data/*/
      ${pkgs.acl}/bin/setfacl -m u:${ncUser}:--x \
        /var/lib/nextcloud \
        /var/lib/nextcloud/data \
        /var/lib/nextcloud/data/${ncUser}
      ${pkgs.acl}/bin/setfacl -R -m u:${ncUser}:rwX /var/lib/nextcloud/data/${ncUser}/files
      ${pkgs.acl}/bin/setfacl -R -d -m u:${ncUser}:rwX /var/lib/nextcloud/data/${ncUser}/files
      ${pkgs.acl}/bin/setfacl -R -d -m u:nextcloud:rwX /var/lib/nextcloud/data/${ncUser}/files
    '';
  };

  systemd.services.tailscale-serve-nextcloud = {
    description = "Publish Nextcloud on the tailnet";
    after = [
      "tailscaled.service"
      "nginx.service"
      "nextcloud-setup.service"
    ];
    wants = [
      "tailscaled.service"
      "nginx.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve --bg --yes http://127.0.0.1:80";
    };
  };
}
