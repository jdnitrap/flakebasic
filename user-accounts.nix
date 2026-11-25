#user-accounts.nix

{config, lib, pkgs, inputs, ... }:

{
  users.mutableUsers = true;

  users.users.admin = {
    isNormalUser = true;
    description = "Admin";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  users.users.John = {
    isNormalUser = true;
    description = "John";
    uid = 1002;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "changeme";
  };

  # Both accounts can sudo without a password on every host.
  security.sudo.extraRules = [
    {
      users = [ "admin" "John" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
