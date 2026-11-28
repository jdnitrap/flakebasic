# Send DNS through AdGuard, with a Nix exception.
{
  flake.modules.nixos."dns-lock" =
  # Force outbound DNS through AdGuard. Port 53 may go to localhost, or leave
  # the machine only as the adguardhome user (its plain-DNS fallback). Port 853
  # (DNS-over-TLS) is refused. HTTPS is left to each program.

  { pkgs, lib, ... }:

  let
    # Immediate, offline undo. A firewall reload or reboot puts the lock back.
    # Lasting undo from the local keyboard: run0 nixos-rebuild switch --rollback
    restore-network = pkgs.writeShellScriptBin "restore-network" ''
      systemctl stop mitmproxy-redirect.service 2>/dev/null || true
      systemctl stop mitmproxy.service 2>/dev/null || true
      systemctl stop opensnitchd.service 2>/dev/null || true
      iptables -w -t nat -D OUTPUT -j nixos-tls-proxy 2>/dev/null || true
      iptables -w -t nat -F nixos-tls-proxy 2>/dev/null || true
      iptables -w -t nat -X nixos-tls-proxy 2>/dev/null || true
      iptables -w -D OUTPUT -j nixos-quic-reject 2>/dev/null || true
      iptables -w -F nixos-quic-reject 2>/dev/null || true
      iptables -w -X nixos-quic-reject 2>/dev/null || true
      iptables -w -D OUTPUT -j nixos-dns-lock 2>/dev/null || true
      iptables -w -F nixos-dns-lock 2>/dev/null || true
      iptables -w -X nixos-dns-lock 2>/dev/null || true
      ip6tables -w -D OUTPUT -j nixos-dns-lock 2>/dev/null || true
      ip6tables -w -F nixos-dns-lock 2>/dev/null || true
      ip6tables -w -X nixos-dns-lock 2>/dev/null || true
      echo "Proxy redirect, OpenSnitch, and the DNS lock are off until reboot or the next firewall start."
      echo "Lasting undo, from this keyboard, with no network: run0 nixos-rebuild switch --rollback"
      echo "Or pick the previous generation in the boot menu."
    '';

    # nix and nixos-rebuild are the only programs that may skip AdGuard.
    # Their wrappers are setgid to this group. The nix daemon is a member too.
    # Nobody else is. The resolvers are IPs, so this path still works when
    # AdGuard is down and no other name can be looked up.
    nix-resolv = pkgs.writeText "nix-resolv.conf" ''
      nameserver 1.1.1.1
      nameserver 9.9.9.9
    '';

    # A user namespace makes the process a fake root. Nix then fails with
    # "remounting /nix/store writable: Operation not permitted". Only a real
    # root process may mount the direct resolver. Everyone else uses AdGuard.
    wrap-nix = real: pkgs.writeShellScriptBin (baseNameOf real) ''
      set +e
      status=86
      if [ "$(${pkgs.coreutils}/bin/id -u)" -eq 0 ]; then
        ${pkgs.util-linux}/bin/unshare --mount --propagation private ${pkgs.bash}/bin/bash -c '
          if ! mount --bind "$1" /etc/resolv.conf; then
            exit 86
          fi
          shift
          exec "$@"
        ' _ ${nix-resolv} ${real} "$@"
        status=$?
      fi
      set -e
      if [ "$status" -eq 86 ]; then
        echo "nix direct DNS was not available; using the system resolver" >&2
        exec ${real} "$@"
      fi
      exit "$status"
    '';

    # Installed by the firewall when the AdGuard user already exists, and again
    # by nixos-dns-lock.service once that user has been created at boot.
    install-dns-lock = pkgs.writeShellScriptBin "install-dns-lock" ''
      export PATH="${pkgs.iptables}/bin:${pkgs.coreutils}/bin:$PATH"
      aguid=$(id -u adguardhome 2>/dev/null || true)
      if [ -z "$aguid" ]; then
        echo "adguardhome user is not available yet; DNS lock was not installed" >&2
        exit 0
      fi
      ngid=$(${lib.getOutput "getent" pkgs.glibc}/bin/getent group nix-direct | cut -d: -f3 || true)

      allow_nix_dns() {
        family="$1"
        shift
        if [ -z "$ngid" ]; then
          return 0
        fi
        for ip in "$@"; do
          "$family" -w -A nixos-dns-lock -m owner --gid-owner "$ngid" --suppl-groups -d "$ip" -p udp --dport 53 -j RETURN
          "$family" -w -A nixos-dns-lock -m owner --gid-owner "$ngid" --suppl-groups -d "$ip" -p tcp --dport 53 -j RETURN
        done
      }

      iptables -w -N nixos-dns-lock 2>/dev/null || true
      iptables -w -F nixos-dns-lock
      iptables -w -A nixos-dns-lock -o lo -j RETURN
      iptables -w -A nixos-dns-lock -m owner --uid-owner "$aguid" -p udp --dport 53 -j RETURN
      iptables -w -A nixos-dns-lock -m owner --uid-owner "$aguid" -p tcp --dport 53 -j RETURN
      allow_nix_dns iptables 1.1.1.1 9.9.9.9
      iptables -w -A nixos-dns-lock -p udp --dport 53 -j REJECT
      iptables -w -A nixos-dns-lock -p tcp --dport 53 -j REJECT
      iptables -w -A nixos-dns-lock -p udp --dport 853 -j REJECT
      iptables -w -A nixos-dns-lock -p tcp --dport 853 -j REJECT
      iptables -w -C OUTPUT -j nixos-dns-lock 2>/dev/null || iptables -w -A OUTPUT -j nixos-dns-lock

      ip6tables -w -N nixos-dns-lock 2>/dev/null || true
      ip6tables -w -F nixos-dns-lock
      ip6tables -w -A nixos-dns-lock -o lo -j RETURN
      ip6tables -w -A nixos-dns-lock -m owner --uid-owner "$aguid" -p udp --dport 53 -j RETURN
      ip6tables -w -A nixos-dns-lock -m owner --uid-owner "$aguid" -p tcp --dport 53 -j RETURN
      allow_nix_dns ip6tables 2606:4700:4700::1111 2620:fe::fe
      ip6tables -w -A nixos-dns-lock -p udp --dport 53 -j REJECT
      ip6tables -w -A nixos-dns-lock -p tcp --dport 53 -j REJECT
      ip6tables -w -A nixos-dns-lock -p udp --dport 853 -j REJECT
      ip6tables -w -A nixos-dns-lock -p tcp --dport 853 -j REJECT
      ip6tables -w -C OUTPUT -j nixos-dns-lock 2>/dev/null || ip6tables -w -A OUTPUT -j nixos-dns-lock
    '';
  in
  {
    environment.systemPackages = [ restore-network ];

    users.groups.nix-direct = {};

    # /run/wrappers/bin is ahead of the normal path, including for sudo.
    # The wrapper file is setgid, so only that process may use the direct resolvers.
    security.wrappers.nix = {
      source = "${wrap-nix "${pkgs.nix}/bin/nix"}/bin/nix";
      owner = "root";
      group = "nix-direct";
      setgid = true;
      permissions = "u+rx,g+rx,o+rx";
    };
    security.wrappers.nixos-rebuild = {
      source = "${wrap-nix "${pkgs.nixos-rebuild}/bin/nixos-rebuild"}/bin/nixos-rebuild";
      owner = "root";
      group = "nix-direct";
      setgid = true;
      permissions = "u+rx,g+rx,o+rx";
    };

    systemd.services.nix-daemon.serviceConfig = {
      SupplementaryGroups = [ "nix-direct" ];
      BindReadOnlyPaths = [ "${nix-resolv}:/etc/resolv.conf" ];
    };

    # The firewall starts before the network. AdGuard starts after the network
    # and creates its user then. Waiting for AdGuard from the firewall makes a
    # systemd ordering loop, so the DNS lock is a later oneshot. If the user is
    # still missing, the firewall continues without the lock.
    systemd.services.nixos-dns-lock = {
      description = "Install the AdGuard DNS lock";
      after = [ "firewall.service" "adguardhome.service" ];
      wants = [ "adguardhome.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${install-dns-lock}/bin/install-dns-lock";
      };
    };

    networking.firewall.extraCommands = "${install-dns-lock}/bin/install-dns-lock";

    networking.firewall.extraStopCommands = ''
      iptables -w -D OUTPUT -j nixos-dns-lock 2>/dev/null || true
      iptables -w -F nixos-dns-lock 2>/dev/null || true
      iptables -w -X nixos-dns-lock 2>/dev/null || true
      ip6tables -w -D OUTPUT -j nixos-dns-lock 2>/dev/null || true
      ip6tables -w -F nixos-dns-lock 2>/dev/null || true
      ip6tables -w -X nixos-dns-lock 2>/dev/null || true
    '';
  }
;
}
