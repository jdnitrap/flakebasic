#auto-login.nix
# Auto-login is not set here. Settings -> System -> Users owns the switch.

{ config, pkgs, lib, ... }:

{
  services.accounts-daemon.enable = true;
  users.mutableUsers = true;

  # Do not set services.displayManager.autoLogin. That would lock the switch.
  # GDM then follows AccountsService, which the Users panel writes.

  # Any logged-in local user may toggle automatic login.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.accounts.user-administration" &&
          subject.active && subject.local) {
        return polkit.Result.YES;
      }
    });
  '';
}
