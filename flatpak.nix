#flatpak.nix

{ config, lib, pkgs, ... }:

{
  services.flatpak.enable = true;

  # System installs. Available to every account.
  services.flatpak.packages = [
    { appId = "app.zen_browser.zen"; origin = "flathub"; }
    { appId = "org.mozilla.firefox"; origin = "flathub"; }
  ];

  # User install for the test account only. Runs in the background at login.
  systemd.user.services.flatpak-user-install = {
    description = "Install user Flatpaks";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig.Type = "oneshot";
    script = ''
      [ "$(id -un)" = "test" ] || exit 0
      flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      flatpak install --user -y flathub org.gnome.Calculator || true
    '';
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.Flatpak.app-update" ||
          action.id == "org.freedesktop.Flatpak.runtime-update") {
        return polkit.Result.YES;
      }

      # GNOME Software metadata refresh.
      if (action.id == "org.freedesktop.packagekit.system-sources-refresh" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }

      if (action.id.indexOf("org.freedesktop.Flatpak.") == 0) {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.AUTH_ADMIN_KEEP;
        }
        return polkit.Result.NO;
      }
    });
  '';
}
