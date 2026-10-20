#networking.nxi

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

 # Enable the OpenSSH daemon.
   services.openssh.enable = false;

  # firewalld replaces the built-in firewall. Do not enable both.
  networking.firewall.enable = false;

  services.firewalld.enable = true;
  # Printer discovery only on the home zone. Public stays closed.
  services.firewalld.zones.home.services = [ "mdns" ];

}
