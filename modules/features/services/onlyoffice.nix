# OnlyOffice Document Server for the Nextcloud app on inixos.
# The editor is published on the tailnet at port 8443. It does not listen on the LAN.
{
  flake.modules.nixos."onlyoffice" =
  { config, pkgs, lib, ... }:

  {
    services.onlyoffice = {
      enable = true;
      hostname = "onlyoffice.local";
      port = 8000;
      # Nextcloud is reached at the tailnet address, which is a private range.
      allowLocalConnections = true;
      securityNonceFile = "/etc/onlyoffice/secure-link.conf";
      jwtSecretFile = "/etc/onlyoffice/jwt-secret";
    };

    services.nginx.virtualHosts."onlyoffice.local".listen = [
      {
        addr = "127.0.0.1";
        port = 8088;
        ssl = false;
      }
    ];

    systemd.services.nextcloud-onlyoffice-setup = {
      description = "Point the Nextcloud OnlyOffice app at the local document server";
      after = [
        "nextcloud-setup.service"
        "onlyoffice-docservice.service"
        "nginx.service"
      ];
      wants = [ "nextcloud-setup.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        secret=$(cat /etc/onlyoffice/jwt-secret)
        occ=${lib.getExe config.services.nextcloud.occ}
        $occ config:app:set onlyoffice DocumentServerUrl --value="https://inixos.tail6cea4d.ts.net:8443/"
        $occ config:app:set onlyoffice DocumentServerInternalUrl --value="http://127.0.0.1:8088/"
        $occ config:app:set onlyoffice StorageUrl --value="https://inixos.tail6cea4d.ts.net/"
        $occ config:app:set onlyoffice jwt_secret --value="$secret"
        $occ config:app:set onlyoffice jwt_header --value="Authorization"
      '';
    };
  };
}
