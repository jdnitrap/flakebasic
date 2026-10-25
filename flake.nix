{
  description = "NixOS configurations by hostname";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
  };

  outputs = { self, nixpkgs, nix-flatpak, ... }:
    let
      system = "x86_64-linux";
      hosts = [ "Asus" "minilap" ];
    in {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (hostName:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nix-flatpak.nixosModules.nix-flatpak
            ./configuration.nix
            ./hosts/${hostName}.nix
          ];
        });
    };
}
