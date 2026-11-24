{
  description = "NixOS configurations by hostname";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.8.0";
    apparmor-gui.url = "github:jdnitrap/apparmor-gui";
    apparmor-gui.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-flatpak, apparmor-gui, ... }:
    let
      system = "x86_64-linux";
      hosts = [ "Asus" "minilap" "inixos" ];
    in {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (hostName:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nix-flatpak.nixosModules.nix-flatpak
            apparmor-gui.nixosModules.default
            ./configuration.nix
            ./hosts/${hostName}.nix
            # Disks, firmware, and kernel modules for this computer.
            # Same path on every machine. Not stored in the flake.
            # nixos-rebuild needs --impure to read it.
            /etc/nixos/hardware.nix
          ];
        });
    };
}
