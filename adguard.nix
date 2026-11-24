#adguard.nix

{ config, pkgs, lib, ... }:

{

  # Local DNS blocker. Covers every app that uses the system DNS.
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = 3000;
    mutableSettings = true;

    settings = {
      dns = {
        bind_hosts = [
          "127.0.0.1"
          "::1"
        ];
        port = 53;
        # Resolver IPs, not hostnames. Proton times out DoH to
        # dns.quad9.net / cloudflare-dns.com and takes down all DNS.
        # DoH-by-IP stays encrypted; plain IP DNS is the fallback.
        upstream_dns = [
          "https://9.9.9.9/dns-query"
          "https://149.112.112.112/dns-query"
        ];
        fallback_dns = [
          "9.9.9.9"
          "1.1.1.1"
        ];
        bootstrap_dns = [
          "9.9.9.9"
          "1.1.1.1"
        ];
        disable_ipv6 = true;
      };

      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        safe_search.enabled = false;
        # AdGuard refuses a local filter path unless it matches this list.
        safe_fs_patterns = [
          "/var/lib/adguard-duckduckgo/duckduckgo.txt"
        ];
      };

      filters = [
        {
          enabled = true;
          id = 1;
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
        }
        {
          enabled = true;
          id = 2;
          name = "AdGuard DNS popup filter";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt";
        }
        {
          enabled = true;
          id = 3;
          name = "Malicious URL Blocklist (URLHaus)";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
        }
        {
          enabled = true;
          id = 4;
          name = "Dandelion Sprout's Anti-Malware List";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt";
        }
        {
          enabled = true;
          id = 5;
          name = "Phishing URL Blocklist (PhishTank and OpenPhish)";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt";
        }
        {
          enabled = true;
          id = 6;
          name = "NoCoin Filter List";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt";
        }
        {
          enabled = true;
          id = 7;
          name = "Phishing Army";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt";
        }
        {
          enabled = true;
          id = 8;
          name = "Scam Blocklist by DurableNapkin";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_10.txt";
        }
        {
          enabled = true;
          id = 9;
          name = "Stalkerware Indicators List";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_31.txt";
        }
        # Ads, trackers, push hosts, and badware sites.
        # HaGeZi Pro is the balanced tier. The VPN/Tor/proxy bypass
        # list (filter_52) is not included. Pro does not block
        # proton.me, protonvpn.com, or vpn-api.proton.me.
        {
          enabled = true;
          id = 10;
          name = "Peter Lowe's Blocklist";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt";
        }
        {
          enabled = true;
          id = 11;
          name = "Dan Pollock's List";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt";
        }
        {
          enabled = true;
          id = 12;
          name = "Dandelion Sprout's Anti Push Notifications";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_39.txt";
        }
        {
          enabled = true;
          id = 13;
          name = "uBlock filters – Badware risks";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_50.txt";
        }
        {
          enabled = true;
          id = 14;
          name = "ShadowWhisperer Tracking List";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_69.txt";
        }
        {
          enabled = true;
          id = 15;
          name = "HaGeZi's Pro Blocklist";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt";
        }
        {
          enabled = true;
          id = 16;
          name = "DuckDuckGo Web Tracker Blocklist";
          url = "/var/lib/adguard-duckduckgo/duckduckgo.txt";
        }
      ];

      # Public resolver names only. A browser that cannot open its own
      # secure DNS falls back to this machine's DNS. VPN, Tor, and proxy
      # services are not listed here.
      user_rules = [
        "||dns.google^"
        "||dns.google.com^"
        "||dns.quad9.net^"
        "||dns9.quad9.net^"
        "||dns10.quad9.net^"
        "||dns11.quad9.net^"
        "||dns12.quad9.net^"
        "||dns.cloudflare.com^"
        "||cloudflare-dns.com^"
        "||one.one.one.one^"
        "||dns.nextdns.io^"
        "||dns.adguard-dns.com^"
        "||doh.opendns.com^"
        "||dns.opendns.com^"
        "||dns.cleanbrowsing.org^"
        "||doh.cleanbrowsing.org^"
        "||dns.switch.ch^"
      ];
    };
  };

  # Point the system at the local blocker.
  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];
  networking.networkmanager.dns = "none";

  # DuckDuckGo's list is JSON for a browser, not a DNS blocklist.
  # Keep domains whose default action is block, plus CNAME cloaks.
  # Leave Proton and duckduckgo.com itself out so Mail, Pass, VPN,
  # and search still resolve. This machine's DNS lock sends every
  # lookup through AdGuard, so the refresh runs after AdGuard is up.
  # A changed file restarts AdGuard so the new rules load.
  systemd.services.adguard-duckduckgo-list = {
    description = "Refresh the DuckDuckGo tracker list for AdGuard";
    wantedBy = [ "multi-user.target" ];
    wants = [ "adguardhome.service" "network-online.target" ];
    after = [ "adguardhome.service" "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "adguard-duckduckgo";
    };
    script = ''
      set -eu
      umask 022
      dir=/var/lib/adguard-duckduckgo
      tmp=$(mktemp)
      rules=$(mktemp)
      trap 'rm -f "$tmp" "$rules"' EXIT
      i=0
      until ${pkgs.curl}/bin/curl -fsSL --max-time 30 -o "$tmp" \
        https://raw.githubusercontent.com/duckduckgo/tracker-blocklists/main/web/v6/extension-tds.json
      do
        i=$((i + 1))
        if [ "$i" -ge 8 ]; then
          echo "could not download the DuckDuckGo tracker list" >&2
          exit 1
        fi
        ${pkgs.coreutils}/bin/sleep 2
      done
      ${pkgs.jq}/bin/jq -r '
        [
          (.trackers // {} | to_entries[] | select(.value.default == "block") | .value.domain),
          ((.cnames // {}) | keys[])
        ]
        | .[]
        | select(type == "string")
        | select(test("^[A-Za-z0-9._-]+$"))
        | select(test("(^|\\.)(proton\\.me|protonvpn\\.com|protonvpn\\.net|protonvpn\\.ch|protonmail\\.com|duckduckgo\\.com)$") | not)
        | "||" + . + "^"
      ' "$tmp" | ${pkgs.coreutils}/bin/sort -u > "$rules"
      lines=$(${pkgs.coreutils}/bin/wc -l < "$rules")
      if [ "$lines" -lt 300 ]; then
        echo "DuckDuckGo tracker list has only $lines rules" >&2
        exit 1
      fi
      {
        echo "! Title: DuckDuckGo Web Tracker Blocklist"
        echo "! Homepage: https://github.com/duckduckgo/tracker-blocklists"
        echo "! Source: web/v6/extension-tds.json"
        echo "! Domains with default action block, plus CNAME cloaks"
        ${pkgs.coreutils}/bin/cat "$rules"
      } > "$dir/duckduckgo.txt.tmp"
      ${pkgs.coreutils}/bin/mv "$dir/duckduckgo.txt.tmp" "$dir/duckduckgo.txt.new"
      ${pkgs.coreutils}/bin/chmod 644 "$dir/duckduckgo.txt.new"
      if [ -f "$dir/duckduckgo.txt" ] && ${pkgs.diffutils}/bin/cmp -s "$dir/duckduckgo.txt" "$dir/duckduckgo.txt.new"; then
        ${pkgs.coreutils}/bin/rm -f "$dir/duckduckgo.txt.new"
      else
        ${pkgs.coreutils}/bin/mv "$dir/duckduckgo.txt.new" "$dir/duckduckgo.txt"
        ${pkgs.systemd}/bin/systemctl try-restart adguardhome.service
      fi
    '';
  };

  systemd.timers.adguard-duckduckgo-list = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

}
