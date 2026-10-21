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

  # Port firewall stays on. OpenSnitch asks per app on top of it.
  networking.firewall.enable = true;
  # Required for Proton VPN and other WireGuard clients.
  networking.firewall.checkReversePath = false;

  services.opensnitch.enable = true;

  # Desktop entry so the UI shows in the app grid.
  environment.etc."xdg/applications/opensnitch-ui.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=OpenSnitch
    Comment=Application firewall
    Exec=${pkgs.opensnitch-ui}/bin/opensnitch-ui
    Icon=security-high
    Terminal=false
    Categories=System;Settings;Security;
    StartupNotify=true
  '';

  # Start the UI for every logged-in user.
  environment.etc."xdg/autostart/opensnitch-ui.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=OpenSnitch
    Comment=Application firewall
    Exec=${pkgs.opensnitch-ui}/bin/opensnitch-ui
    Icon=security-high
    Terminal=false
    X-GNOME-Autostart-enabled=true
  '';

}
