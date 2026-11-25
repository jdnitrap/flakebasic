#networking.nix

{config, pkgs, lib, ...}:

{

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
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
