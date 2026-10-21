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
  # firewalld uses nftables by default.
  networking.nftables.enable = true;

  services.firewalld.enable = true;
  # Printer discovery only on the home zone. Public stays closed.
  services.firewalld.zones.home.services = [ "mdns" ];

  # Desktop entry so the GUI shows in the app grid.
  environment.etc."xdg/applications/firewall-config.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Firewall
    Comment=Configure the firewall
    Exec=${pkgs.firewalld}/bin/firewall-config
    Icon=security-high
    Terminal=false
    Categories=System;Settings;Security;
    StartupNotify=true
  '';

}
