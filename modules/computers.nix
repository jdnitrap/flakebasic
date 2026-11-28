# This is the menu. Each computer is a list of feature names.
# A feature file under modules/features does nothing until a computer lists it.
{ config, inputs, lib, ... }:
let
  features = config.flake.modules.nixos;

  # Same path on every computer. Written by nixos-generate-config.
  # Nix can read it only when the rebuild uses --impure.
  hardwareFile = /etc/nixos/hardware-configuration.nix;
  hardwareCheck = builtins.tryEval (builtins.pathExists hardwareFile);
  hardwareFound = hardwareCheck.success && hardwareCheck.value;

  everyComputer =
  [
    features.fallback-root
    features.hardware-support
    features.printing
    features.locale
    features.sound
    features.state-version
    features.packages
    features.boot
    features.networking
    features.users
    features.flatpak
    features.flakes
    features.laptop
  ];

  computer = hostName: extras:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        hermes-agent = inputs.hermes-agent;
      };
      modules =
        [ inputs.nix-flatpak.nixosModules.nix-flatpak ]
        ++ everyComputer
        ++ extras
        ++ [ { networking.hostName = hostName; } ]
        ++ lib.optional hardwareFound hardwareFile;
    };
in
{
  flake.nixosConfigurations = {
    nixasus = computer "nixasus"
    [
      features.gnome
      features.nixasus-desktop
      features.autologin
      features.bluetooth
      features.openssh
      features.loose-reverse-path
      features.tailscale
      features.nixasus-tailscale
      features.assistants
      features.adguard
      features.dns-lock
      features.opensnitch
      features.local-ai
      features.containers
    ];

    ilenovo = computer "ilenovo"
    [
      features.gnome
    ];

    inixos = computer "inixos"
    [
      features.cinnamon
      features.lightdm
      features.autologin
      features.bluetooth
      features.loose-reverse-path
      features.tailscale
      features.nextcloud
      features.onlyoffice
      features.inixos-host
    ];



  };
}
