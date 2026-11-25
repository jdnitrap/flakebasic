#auto-update.nix

{ config, pkgs, lib, ... }:

{
  system.autoUpgrade = {
    enable = true;
    persistent = true;
    dates = "Sun 03:00";
    randomizedDelaySec = "0";
    allowReboot = false;
    flake = "github:jdnitrap/flakebasic#${config.networking.hostName}";
    flags = [
      "--impure"
      "--no-write-lock-file"
      "--option" "build-cores" "1"
      "--option" "cores" "1"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  systemd.services.nixos-upgrade = {
    path = [ pkgs.libnotify pkgs.sudo pkgs.coreutils ];
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
      CPUSchedulingPolicy = "idle";
      # An old computer may build for hours. Do not stop the job on a timer.
      TimeoutStartSec = "infinity";
    };
    postStart = ''
      for uid in $(ls /run/user 2>/dev/null || true); do
        [ -S "/run/user/$uid/bus" ] || continue
        user=$(id -nu "$uid" 2>/dev/null || true)
        [ -n "$user" ] || continue
        sudo -u "$user" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
          notify-send "NixOS update" "The Sunday update finished. The computer will reboot in 30 minutes." || true
      done
      # This runs only after nixos-rebuild exits successfully. The reboot
      # waits another 30 minutes so a slow machine is not restarted mid-build.
      ${pkgs.systemd}/bin/shutdown -r +30
    '';
  };
}
