#dns-lock.nix
# Force outbound DNS through AdGuard. Port 53 may go to localhost, or leave
# the machine only as the adguardhome user (its plain-DNS fallback). Port 853
# (DNS-over-TLS) is refused. HTTPS is left to each program.

{ pkgs, ... }:

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

  # Installed by the firewall when the AdGuard user already exists, and again
  # by nixos-dns-lock.service once that user has been created at boot.
  install-dns-lock = pkgs.writeShellScriptBin "install-dns-lock" ''
    export PATH="${pkgs.iptables}/bin:${pkgs.coreutils}/bin:$PATH"
    aguid=$(id -u adguardhome 2>/dev/null || true)
    if [ -z "$aguid" ]; then
      echo "adguardhome user is not available yet; DNS lock was not installed" >&2
      exit 0
    fi
    iptables -w -N nixos-dns-lock 2>/dev/null || true
    iptables -w -F nixos-dns-lock
    iptables -w -A nixos-dns-lock -o lo -j RETURN
    iptables -w -A nixos-dns-lock -m owner --uid-owner "$aguid" -p udp --dport 53 -j RETURN
    iptables -w -A nixos-dns-lock -m owner --uid-owner "$aguid" -p tcp --dport 53 -j RETURN
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
    ip6tables -w -A nixos-dns-lock -p udp --dport 53 -j REJECT
    ip6tables -w -A nixos-dns-lock -p tcp --dport 53 -j REJECT
    ip6tables -w -A nixos-dns-lock -p udp --dport 853 -j REJECT
    ip6tables -w -A nixos-dns-lock -p tcp --dport 853 -j REJECT
    ip6tables -w -C OUTPUT -j nixos-dns-lock 2>/dev/null || ip6tables -w -A OUTPUT -j nixos-dns-lock
  '';
in
{
  environment.systemPackages = [ restore-network ];

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
