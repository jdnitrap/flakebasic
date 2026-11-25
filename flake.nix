{
  description = "NixOS configurations by hostname";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.8.0";
    apparmor-gui.url = "github:jdnitrap/apparmor-gui";
    apparmor-gui.inputs.nixpkgs.follows = "nixpkgs";
    # Newest stable release. A newer tag is adopted by updating this pin.
    hermes-agent.url = "github:NousResearch/hermes-agent/v0.23.4";
  };

  outputs = { self, nixpkgs, nix-flatpak, apparmor-gui, hermes-agent, ... }:
    let
      system = "x86_64-linux";
      hosts = [ "nixasus" "minilap" "inixos" ];
    in {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (hostName:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit hermes-agent; };
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
