#auto-login.nix
# Settings -> System -> Users owns the switch.
# A service copies that choice into GDM before the login screen starts.

{ config, pkgs, lib, ... }:

{
  services.accounts-daemon.enable = true;
  users.mutableUsers = true;

  # Do not set services.displayManager.autoLogin. That would lock the switch.

  # Any logged-in local user may toggle automatic login.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.accounts.user-administration" &&
          subject.active && subject.local) {
        return polkit.Result.YES;
      }
    });
  '';

  # Read AccountsService and write the chosen user into GDM.
  systemd.services.gdm-autologin-bridge = {
    description = "Apply AccountsService auto-login to GDM";
    before = [ "display-manager.service" ];
    wantedBy = [ "display-manager.service" ];
    serviceConfig.Type = "oneshot";
    path = [ pkgs.gawk pkgs.gnugrep pkgs.coreutils ];
    script = ''
      conf=/etc/gdm/custom.conf
      [ -f "$conf" ] || exit 0

      user=""
      for f in /var/lib/AccountsService/users/*; do
        [ -f "$f" ] || continue
        if grep -q '^AutomaticLogin=true' "$f"; then
          user=$(basename "$f")
          break
        fi
      done

      # Drop any previous bridge lines, then add the current choice.
      tmp=$(mktemp)
      grep -v -E '^(AutomaticLoginEnable|AutomaticLogin)=' "$conf" > "$tmp" || true
      if [ -n "$user" ]; then
        awk -v u="$user" '
          /^\[daemon\]/ { print; print "AutomaticLoginEnable=true"; print "AutomaticLogin=" u; next }
          { print }
        ' "$tmp" > "$conf"
      else
        cat "$tmp" > "$conf"
      fi
      rm -f "$tmp"
    '';
  };
}
