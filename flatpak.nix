#flatpak.nix

{ config, lib, pkgs, ... }:

{
  services.flatpak.enable = true;

  # Declarative installs. Add app IDs here.
  services.flatpak.packages = [
    # { appId = "org.mozilla.firefox"; origin = "flathub"; }
    # "com.spotify.Client"
  ];

  # Updates run with nobody at the keyboard. New installs still ask.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.Flatpak.app-update" ||
          action.id == "org.freedesktop.Flatpak.runtime-update") {
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
