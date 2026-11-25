#hosts/nixasus.nix
# This computer. The hostname becomes nixasus when the flake is applied.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../gnome.nix
    ../dns-lock.nix
    ../system-filter.nix
    ../local-ai.nix
    ../containers-vms.nix
  ];

  networking.hostName = "nixasus";

  # Do not refresh cached downloads. The lock already names the inputs.
  system.autoUpgrade.flags = lib.mkForce [
    "--impure"
    "--no-write-lock-file"
    "--option" "build-cores" "1"
    "--option" "cores" "1"
  ];

  # Sign John in when GDM starts. The greeter does not ask for a password.
  services.displayManager.autoLogin = {
    enable = true;
    user = "John";
  };

  # xserver installs XTerm and its launcher unless it is excluded.
  services.xserver.excludePackages = [ pkgs.xterm ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # This machine's bluetoothd profile is disabled. The shared profiles stay.
  security.apparmor.policies."bin.bluetoothd" = {
    state = "disable";
    profile = ''
      include <tunables/global>
      profile bluetoothd /run/current-system/sw/bin/bluetoothd flags=(attach_disconnected) {
        include <abstractions/base>
        include <abstractions/nameservice>
        /run/current-system/sw/bin/bluetoothd mr,
      }
    '';
  };

  # OpenSSH stays up for the local network, but it accepts no passwords
  # and no keyboard-interactive logins. Tailscale SSH is the remote login.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.KbdInteractiveAuthentication = false;

  # Loose mode keeps a VPN working. Packets that match no route are still dropped.
  networking.firewall.checkReversePath = "loose";

  # Tailscale client. Log in once with:
  #   pkexec tailscale up --accept-dns=false
  # --accept-dns=false keeps AdGuard as the resolver.
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
  services.tailscale.extraSetFlags = [ "--ssh" ];
  networking.networkmanager.unmanaged = [ "interface-name:tailscale0" ];

  # This laptop does not use Tailscale DNS. The hosts entry lets local
  # programs open Nextcloud by its tailnet name.
  networking.extraHosts = ''
    100.112.170.12 hostname.tail6cea4d.ts.net
    100.98.170.29 inixos.tail6cea4d.ts.net
  '';
}
