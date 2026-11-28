# NetworkManager, the firewall, and the OpenSSH default.
{
  flake.modules.nixos."networking" =
  {config, pkgs, lib, ...}:

  {

    networking.networkmanager.enable = true;
    networking.networkmanager.plugins = with pkgs; [
      networkmanager-openvpn
    ];

    # Enable the OpenSSH daemon. A host can turn it on.
    services.openssh.enable = lib.mkDefault false;

    # NixOS firewall.
    networking.firewall.enable = true;
    # Required for Proton VPN and other WireGuard clients. A host can set loose mode.
    networking.firewall.checkReversePath = lib.mkDefault false;

  }
;
}
