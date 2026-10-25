#user-accounts.nix

{config, lib, pkgs, inputs, ... }:

{

users.users."user1" = {
    isNormalUser = true;
    description = "user1";
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
  };

# No wheel. Used to test user-level Flatpak installs.
users.users."test" = {
    isNormalUser = true;
    description = "test";
    extraGroups = [ "networkmanager" ];
  };

}
