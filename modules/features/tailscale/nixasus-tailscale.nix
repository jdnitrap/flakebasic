# nixasus Tailscale details. --accept-dns=false stops Tailscale from replacing 127.0.0.1.
{
  flake.modules.nixos."nixasus-tailscale" = {
    services.tailscale.extraSetFlags = [ "--ssh" "--accept-dns=false" ];
    networking.networkmanager.unmanaged = [ "interface-name:tailscale0" ];

    # This laptop does not use Tailscale DNS. The hosts entry lets local
    # programs open Nextcloud by its tailnet name.
    networking.extraHosts = ''
      100.98.170.29 inixos.tail6cea4d.ts.net
    '';
  };
}
