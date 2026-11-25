# Podman for containers, Distrobox on top of Podman, and QEMU/libvirt for virtual machines.

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    distrobox
    qemu
  ];

  virtualisation.podman = {
    enable = true;
    # Distrobox talks to Podman directly. Leave the Docker CLI alias off.
    dockerCompat = false;
    # Rootless containers resolve names through the host resolver (AdGuard on 127.0.0.1).
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
  programs.virt-manager.enable = true;

  # kvm lets these users open /dev/kvm for QEMU.
  users.users.John.extraGroups = [ "libvirtd" "kvm" ];
  users.users.admin.extraGroups = [ "libvirtd" "kvm" ];
}
