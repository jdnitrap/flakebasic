#auto-login.nix
# Settings -> System -> Users owns the switch.
# AccountsService writes /etc/gdm/custom.conf. Nix makes that file read-only,
# so we keep a writable copy mounted over it.

{ config, pkgs, lib, ... }:

{
  services.accounts-daemon.enable = true;
  users.mutableUsers = true;

  # Do not set services.displayManager.autoLogin. That would lock the switch.

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
    description = "Writable GDM config for the Users panel auto-login switch";
    before = [ "display-manager.service" "accounts-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.gawk pkgs.gnugrep pkgs.coreutils pkgs.util-linux ];
    script = ''
      mkdir -p /run/gdm
      live=/run/gdm/custom.conf
      target=/etc/gdm/custom.conf

      # Start from the Nix file if we do not already have a runtime copy.
      if [ ! -f "$live" ]; then
        if [ -f "$target" ]; then
          cat "$target" > "$live"
        else
          printf '%s\n' '[daemon]' 'WaylandEnable=true' '[security]' '[xdmcp]' '[greeter]' '[chooser]' '[debug]' > "$live"
        fi
      fi

      # Apply any AccountsService flag that was saved by hand or by a previous panel write.
      user=""
      for f in /var/lib/AccountsService/users/*; do
        [ -f "$f" ] || continue
        if grep -q '^AutomaticLogin=true' "$f"; then
          user=$(basename "$f")
          break
        fi
      done

      if [ -n "$user" ]; then
        tmp=$(mktemp)
        grep -v -E '^(AutomaticLoginEnable|AutomaticLogin)=' "$live" > "$tmp" || true
        awk -v u="$user" '
          /^\[daemon\]/ { print; print "AutomaticLoginEnable=true"; print "AutomaticLogin=" u; next }
          { print }
        ' "$tmp" > "$live"
        rm -f "$tmp"
      fi

      # AccountsService must be able to write this file when the switch is flipped.
      mountpoint -q "$target" || mount --bind "$live" "$target"
      chmod 644 "$live"
      logger -t gdm-autologin-bridge "mounted writable custom.conf; auto-login user: ''${user:-none}"
    '';
  };
}
