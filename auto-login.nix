#auto-login.nix
# Settings -> System -> Users owns the switch.
# A service overlays GDM's config with that choice before the login screen.

{ config, pkgs, lib, ... }:

{
  services.accounts-daemon.enable = true;
  users.mutableUsers = true;

  # Do not set services.displayManager.autoLogin. That would lock the switch.

  # The panel uses set-login-option, not user-administration, to save the switch.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.accounts.user-administration" ||
           action.id == "org.freedesktop.accounts.set-login-option") &&
          subject.active && subject.local) {
        return polkit.Result.YES;
      }
    });
  '';

  systemd.services.gdm-autologin-bridge = {
    description = "Apply AccountsService auto-login to GDM";
    before = [ "display-manager.service" ];
    wantedBy = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.gawk pkgs.gnugrep pkgs.coreutils pkgs.util-linux ];
    script = ''
      mkdir -p /run/gdm
      conf=/run/gdm/custom.conf

      user=""
      for f in /var/lib/AccountsService/users/*; do
        [ -f "$f" ] || continue
        if grep -q '^AutomaticLogin=true' "$f"; then
          user=$(basename "$f")
          break
        fi
      done

      {
        echo "[daemon]"
        echo "WaylandEnable=true"
        if [ -n "$user" ]; then
          echo "AutomaticLoginEnable=true"
          echo "AutomaticLogin=$user"
        fi
        echo "[security]"
        echo "[xdmcp]"
        echo "[greeter]"
        echo "[chooser]"
        echo "[debug]"
      } > "$conf"

      # Nix owns /etc/gdm/custom.conf. Cover it with the runtime file.
      mountpoint -q /etc/gdm/custom.conf || mount --bind "$conf" /etc/gdm/custom.conf
      logger -t gdm-autologin-bridge "auto-login user: ''${user:-none}"
    '';
  };
}
