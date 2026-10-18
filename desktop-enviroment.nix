#desktop_enviroment.nix

{ config, pkgs, lib, ... }:

let
  # Must not be indented. A desktop file with leading spaces is ignored.
  hiddenDesktop = name: pkgs.writeText name ''
[Desktop Entry]
Type=Application
Name=Extensions
Icon=org.gnome.Shell.Extensions
Exec=false
OnlyShowIn=GNOME;
NoDisplay=true
Hidden=true
'';
  hideExtensions = lib.hiPrio (pkgs.runCommand "hide-gnome-extensions-app" { } ''
    install -Dm644 ${hiddenDesktop "shell"} $out/share/applications/org.gnome.Shell.Extensions.desktop
    install -Dm644 ${hiddenDesktop "app"} $out/share/applications/org.gnome.Extensions.desktop
  '');
in
{
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
    gnome-shell-extensions
  ];

  # Trash, mounts, and network locations for any file manager.
  services.gvfs.enable = true;

  # FileChooser portal does not require Nautilus. GTK backend works with other managers.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.gnome = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = "gtk";
    };
  };

  # Terminal=true desktop files and GLib terminal launches use this instead of Console.
  xdg.terminal-exec.enable = true;

  environment.systemPackages = [ hideExtensions ];

  system.activationScripts.hideGnomeExtensions.text = ''
    for home in /home/*; do
      [ -d "$home" ] || continue
      dir="$home/.local/share/applications"
      mkdir -p "$dir"
      cp -f ${hiddenDesktop "shell"} "$dir/org.gnome.Shell.Extensions.desktop"
      cp -f ${hiddenDesktop "app"} "$dir/org.gnome.Extensions.desktop"
      chown --reference="$home" "$dir" "$dir/org.gnome.Shell.Extensions.desktop" "$dir/org.gnome.Extensions.desktop"
    done
  '';
}
